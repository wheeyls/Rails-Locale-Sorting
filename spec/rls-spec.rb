#encoding: utf-8
require "spec_helper"

describe RailsLocaleSorter::LocaleManager do
  FIXTURE_DIR = "resources/locale_fixtures"
  TEST_DIR = "resources/locale_tests"
  SRC_DIR = "resources/src"
  OUT_DIR = "resources/out"

  before do
    # setup test folders
    FileUtils.rm_r(SRC_DIR) if File.exists? SRC_DIR
    FileUtils.cp_r(FIXTURE_DIR, SRC_DIR)
    FileUtils.rm_r(OUT_DIR) if File.exists? OUT_DIR
  end

  before :each do
    @lm = RailsLocaleSorter::LocaleManager.new SRC_DIR, OUT_DIR
  end

  describe "create missing nodes" do
    it "writes blank keys for new values" do
      @lm.create_missing_nodes "src.yml"

      result = File.open("#{OUT_DIR}/out.yml").read
      result.should include "source_only: ~"
      result.should include "src_only: ~"
      result.should include "both: Both"
      result.should include "exotic: 下一页！След"
      result.should include "out:"
    end
  end

  describe "create_patches" do
    it "creates a file of differences only" do
      @lm.create_patches "src.yml"

      result = File.open("#{OUT_DIR}/out.yml").read
      result.should include "out:"
      result.should include "text:"
      result.should include "source_only: "
      result.should include "date:"
      result.should include "src_only: "
      result.should_not include "both: Both"
      result.should_not include "exotic: 下一页！След"
    end

    it "allows for filtering of sections" do
      @lm.create_patches "src.yml", "date"

      result = File.open("#{OUT_DIR}/out.yml").read
      result.should include "out:"
      result.should include "text:"
      result.should include "source_only: "
      result.should_not include "date:"
      result.should_not include "src_only: "
      result.should_not include "both: Both"
      result.should_not include "exotic: 下一页！След"
    end
  end

  describe "poop and scoop" do
    before :each do
      # setup test folders
      FileUtils.rm_r(SRC_DIR) if File.exists? SRC_DIR
      FileUtils.cp_r(TEST_DIR, SRC_DIR)
      FileUtils.rm_r(OUT_DIR) if File.exists? OUT_DIR
      @lm = RailsLocaleSorter::LocaleManager.new SRC_DIR, OUT_DIR
    end

    it "goes through the full cycle" do
      @lm.create_patches "en.yml"

      result = File.open("#{OUT_DIR}/en-target.yml").read
      result.should include "en:"
      result.should include "text:"
      result.should include "invalid: "
      result.should include "shared:"
      result.should include "oops:"
      result.should_not include "fixed:"
      result.should_not include "provide:"

      @lm.apply_patches true
      patched = File.open("#{SRC_DIR}/en-target.yml").read
      source = File.open("#{SRC_DIR}/en.yml").read

      patched.should == source
    end
  end
end
