require "teaspoon/exceptions"

module Teaspoon
  module Environment

    def self.load(options = {})
      require_environment(options[:environment])
      raise "Rails environment not found." unless rails_loaded?

      require "teaspoon"
      require "teaspoon/suite"
      require "teaspoon/server"

      Teaspoon.configuration.override_from_options(options)
      Teaspoon::ExceptionHandling.add_rails_handling
    end

    def self.require_environment(override = nil)
      return require_env(File.expand_path(override, Dir.pwd)) if override

      standard_environments.each do |filename|
        file = File.expand_path(filename, Dir.pwd)
        return require_env(file) if File.exists?(file)
      end

      raise Teaspoon::EnvironmentNotFound
    end

    def self.standard_environments
      ["spec/teaspoon_env.rb", "test/teaspoon_env.rb", "teaspoon_env.rb"]
    end

    def self.require_env(file)
      require(file)
    end

    def self.rails_loaded?
      defined?(Rails)
    end
  end
end
