#encoding: utf-8
require "spec_helper"

describe RailsLocaleSorter::LocaleManager do
  FIXTURE_DIR = "resources/locale_fixtures"
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

  it "writes blank keys for new values" do
    @lm.parse_to_yaml "src.yml"

    result = File.open("#{OUT_DIR}/out.yml").read
    result.should include "source_only: ~"
    result.should include "src_only: ~"
    result.should include "both: Both"
    result.should include "exotic: 下一页！След"
    result.should include "out:"
  end
end
