require "spec_helper"

describe Teaspoon do

  subject { Teaspoon }

  it "has a configuration property" do
    expect(subject.configuration).to be(Teaspoon::Configuration)
  end

  describe ".setup" do

    it "yields configuration" do
      config = nil
      subject.setup { |c| config = c }
      expect(config).to be(Teaspoon::Configuration)
    end

    it "overrides configuration from ENV" do
      subject.configuration.should_receive(:override_from_env).with(ENV)
      subject.setup { }
    end

  end

end


describe Teaspoon::Configuration do

  subject { Teaspoon::Configuration }

  after do
    subject.mount_at = "/teaspoon"
    subject.suite_configs.delete("test_suite")
    subject.server = nil
  end

  it "has the default configuration" do
    expect(subject.mount_at).to eq("/teaspoon")
    expect(subject.root).to eq(Rails.root.join('..', '..'))
    expect(subject.asset_paths).to include("spec/javascripts")
    expect(subject.asset_paths).to include("spec/javascripts/stylesheets")
    expect(subject.asset_paths).to include("test/javascripts")
    expect(subject.asset_paths).to include("test/javascripts/stylesheets")
    expect(subject.fixture_path).to eq("spec/javascripts/fixtures")

    expect(subject.driver).to eq("phantomjs")
    expect(subject.driver_options).to eq(nil)
    expect(subject.driver_timeout).to eq(180)
    expect(subject.server).to be_nil
    expect(subject.server_port).to be_nil
    expect(subject.server_timeout).to eq(20)
    expect(subject.formatters).to eq(['dot'])
    expect(subject.fail_fast).to eq(true)
    expect(subject.suppress_log).to eq(false)
    expect(subject.color).to eq(true)

    expect(subject.suite_configs).to be_a(Hash)
    expect(subject.coverage_configs).to be_a(Hash)
  end

  it "allows setting various configuration options" do
    subject.mount_at = "/teaspoons_are_awesome"
    expect(subject.mount_at).to eq("/teaspoons_are_awesome")
    subject.server = :webrick
    expect(subject.server).to eq(:webrick)
  end

  it "allows defining suite configurations" do
    subject.suite(:test_suite) { }
    expect(subject.suite_configs["test_suite"]).to be_a(Proc)
  end

  it "allows defining coverage configurations" do
    subject.coverage(:test_coverage) { }
    expect(subject.coverage_configs["test_coverage"]).to be_a(Proc)
  end

  describe ".root=" do

    it "forces the path provided into a Pathname" do
      subject.root = "/path"
      expect(subject.root).to be_a(Pathname)
    end

  end

  describe ".formatters" do

    it "returns the default dot formatter if nothing was set" do
      expect(subject.formatters).to eq(["dot"])
    end

    it "returns an array of formatters if they were comma separated" do
      subject.formatters = "dot,swayze_or_oprah"
      expect(subject.formatters).to eq(["dot", "swayze_or_oprah"])
    end

  end

  describe ".override_from_options" do

    it "allows overriding from options" do
      subject.should_receive(:fail_fast=).with(true)
      subject.should_receive(:driver_timeout=).with(123)
      subject.should_receive(:driver=).with("driver")

      subject.send(:override_from_options, fail_fast: true, driver_timeout: 123, driver: "driver")
    end

  end

  describe ".override_from_env" do

    it "allows overriding from the env" do
      subject.should_receive(:fail_fast=).with(true)
      subject.should_receive(:driver_timeout=).with(123)
      subject.should_receive(:driver=).with("driver")

      subject.send(:override_from_env, "FAIL_FAST" => "true", "DRIVER_TIMEOUT" => "123", "DRIVER" => "driver")
    end

  end

end


describe Teaspoon::Configuration::Suite do

  subject { Teaspoon::Configuration::Suite.new &(@suite || proc{}) }

  it "has the default configuration" do
    expect(subject.matcher).to eq("{spec/javascripts,spec/dummy/app/assets/javascripts/specs}/**/*_spec.{js,js.coffee,coffee,js.coffee.erb}")
    expect(subject.helper).to eq("spec_helper")
    expect(subject.javascripts).to eq(["teaspoon/jasmine"])
    expect(subject.stylesheets).to eq(["teaspoon"])
  end

  it "accepts a block that can override defaults" do
    @suite = proc{ |s| s.helper = "helper_file" }
    expect(subject.helper).to eq("helper_file")
  end

end


describe Teaspoon::Configuration::Coverage do

  subject { Teaspoon::Configuration::Coverage.new &(@coverage || proc{}) }

  it "has the default configuration" do
    expect(subject.reports).to eq(["text-summary"])
    expect(subject.ignored).to eq([%r{/lib/ruby/gems/}, %r{/vendor/assets/}, %r{/support/}, %r{/(.+)_helper.}])
    expect(subject.output_path).to eq("coverage")
    expect(subject.statement_threshold).to be_nil
    expect(subject.function_threshold).to be_nil
    expect(subject.branch_threshold).to be_nil
    expect(subject.line_threshold).to be_nil
  end

  it "accepts a block that can override defaults" do
    @coverage = proc{ |s| s.reports = "report_format" }
    expect(subject.reports).to eq("report_format")
  end

end
