require "rails_locale_sorter/version"
require 'rubygems'
require 'active_support'
require 'yaml'
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
    attr_accessor :source, :out

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

      Dir::mkdir(@out) unless File.exists? @out
    end

    def create_missing_nodes(truth = "en.yml")
      translations = YAML::load_file("#{@source}/#{truth}")
      mergee = create_blank_copy(translations)

      process_each_file do |hash, file, filename|
        unless filename == truth
          hash = create_missing_keys(hash, mergee)
        end

        sort_and_write(filename, hash)
      end
    end

    def create_patches(truth = "en.yml", filters = [])
      translations = YAML::load_file("#{@source}/#{truth}")

      process_each_file do |hash, file, filename|
        unless filename == truth
          hash = list_missing_keys(translations, hash)
        end

        sort_and_write(filename, hash, filters)
      end
    end

    def apply_patches(reverse_dirs = false)
      swap_dirs if reverse_dirs

      process_each_file do |patch, file, filename|
        target = YAML::load_file("#{@out}/#{filename}")

        merged = target.merge(patch, &MERGER)

        sort_and_write(filename, merged)
      end

      swap_dirs if reverse_dirs
    end

    private

    def swap_dirs
      tmp = @source
      @source = @out
      @out = tmp
    end

    def with_file(filename, &block)
      leafname = filename.scan(/[a-zA-Z_-]*.yml/).first.to_s
      File.open("#{filename}", "r+") do |f|
        block.call(f, leafname) unless block.nil?
      end
    end

    def with_each_file(&block)
      Dir[@source+"/*.yml"].each do |filename|
        with_file(filename, &block)
      end
    end

    def process_each_file(&block)
      # for ya2yaml
      $KCODE="UTF8"

      puts 'Processing...'

      with_each_file do |f, filename|
        print " #{filename.split('.').first} "
        STDOUT.flush
        hash = YAML::load(f)

        block.call(hash, f, filename)
      end
      puts "Done!"
    end

    def sort_and_write(filename, hash, filters = [])
      hash = OrderFact.convert_and_sort(hash, true)

      filters.each { |filt| hash.first.last.delete(filt) }

      File.open("#{@out}/#{filename}", "w+") do |fw|
        fw.puts hash.ya2yaml(:syck_compatible => true).gsub(/ +$/, '')
      end
    end

    def create_missing_keys(object, all_keys)
      ak_lang = all_keys.first[0]
      ob_lang = object.first[0]

      new_values = all_keys[ak_lang].merge(object[ob_lang], &MERGER)

      {ob_lang => new_values}
    end

    def compare_keys(source, target)
      new_hash = {}

      source.each do |k, v|
        if Hash === target[k] && Hash === v
          res = compare_keys(v, target[k])
          new_hash[k] = res unless res.empty?
        elsif target[k].nil?
          new_hash[k] = v
        else
          # do nothing
          # puts "#{k} is deleted"
        end
      end

      new_hash
    end

    def list_missing_keys(source, target)
      source_lang = source.first[0]
      target_lang = target.first[0]

      new_values = compare_keys(source[source_lang], target[target_lang])
      {target_lang => new_values}
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
