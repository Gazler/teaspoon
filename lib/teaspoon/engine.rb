# require the controller, because it fails to load under some circumstances (unknown why)
require File.expand_path(__FILE__, "../../../app/controllers/teaspoon/spec_controller")

module Teaspoon
  class Engine < ::Rails::Engine

    isolate_namespace Teaspoon

    initializer :assets, group: :all do |app|
      default_root_path(app.root)                 # default the root if it's not set
      append_asset_paths(app.config.assets.paths) # append the asset paths from the configuration
    end

    config.after_initialize do |app|
      inject_instrumentation                      # inject our sprockets hack for instrumenting javascripts
      prepend_routes(app)                         # prepend routes so a catchall doesn't get in the way
    end

    private

    def default_root_path(root)
      Teaspoon.configuration.root ||= root
    end

    def append_asset_paths(paths)
      Teaspoon.configuration.asset_paths.each do |path|
        paths << Teaspoon.configuration.root.join(path).to_s
      end
    end

    def inject_instrumentation
      Sprockets::Environment.send(:include, Teaspoon::SprocketsInstrumentation)
    end

    def prepend_routes(app)
      app.routes do
        mount Teaspoon::Engine => Teaspoon.configuration.mount_at
      end
    end
  end
end
