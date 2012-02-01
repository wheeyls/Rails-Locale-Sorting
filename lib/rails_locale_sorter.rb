require "rails_locale_sorter/version"
require 'rubygems'
require 'active_support'
require 'ya2yaml'

module RailsLocaleSorter
  class OrderFact
    def self.returning(value)
      yield(value)
      value
    end

    def self.convert_and_sort(object, deep = false)
      # from http://seb.box.re/2010/1/15/deep-hash-ordering-with-ruby-1-8/
      if object.is_a?(Hash)
        # Hash is ordered in Ruby 1.9! 
        res = self.returning(RUBY_VERSION >= '1.9' ? Hash.new : ActiveSupport::OrderedHash.new) do |map|
          object.each {|k, v| map[k] = deep ? convert_and_sort(v, deep) : v }
        end
        return res.class[res.sort {|a, b| a[0].to_s <=> b[0].to_s } ]
      elsif deep && object.is_a?(Array)
        array = Array.new
        object.each_with_index {|v, i| array[i] = convert_and_sort(v, deep) }
        return array
      else
        return object
      end
    end
  end

  class LocaleManager
    MERGER = proc do |key, v1, v2| 
      if(Hash === v1 && Hash === v2)
        v1.merge(v2, &MERGER)
      else
        v2 
      end
    end

    def initialize(source_dir, out_dir)
      @source = source_dir
      @out = out_dir
    end

    def parse_to_yaml(truth = "en.yml")
      # for ya2yaml
      $KCODE="UTF8"
      Dir::mkdir(@out) unless File.exists? @out

      translations = YAML::load_file("#{@source}/#{truth}")
      mergee = create_blank_copy(translations)

      with_each_file do |f, filename|
        me = YAML::load(f)
        unless filename == truth
          me = create_missing_keys(me, mergee)
        end

        me = OrderFact.convert_and_sort(me, true)
        File.open("#{@out}/#{filename}", "w+") do |fw|
          fw.puts me.ya2yaml(:syck_compatible => true)
        end
      end

    end

  private

    def with_file(filename, &block)
      leafname = filename.scan(/([a-zA-Z_-]*.yml)/).first.to_s
      File.open("#{filename}", "r+") do |f|
        block.call(f, leafname) unless block.nil?
      end
    end

    def with_each_file(&block)
      Dir[@source+"/*.yml"].each do |filename|
        with_file(filename, &block)
      end
    end

    def create_missing_keys(object, all_keys)
      ak_lang = all_keys.first[0]
      ob_lang = object.first[0]

      new_values = object[ob_lang].merge(all_keys[ak_lang], &MERGER)

      return {ob_lang => new_values}
    end

    def blank_out_object(object)
      unless(Hash === object)
        return;
      end

      object.each do |k, v|
        Hash === v ? object[k]=blank_out_object(v) : object[k]=nil
      end

      object
    end

    def create_blank_copy(object)
      obj = object.clone
      blank_out_object(obj)
    end
  end
end
