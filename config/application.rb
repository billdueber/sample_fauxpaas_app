require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SampleFauxpaasApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Tell rails to look for code in places we're actually going to keep code
    config.autoload_paths << Rails.root.join("lib")
    config.autoload_paths << Rails.root.join("app/presenters")
    config.eager_load_paths << Rails.root.join("app/presenters")


    # Now we can actually load the config and make it available
    require 'sample_fauxpaas_app/config'

    config.relative_url_root                   = SampleFauxpaasApp::Config.relative_url_root
    config.action_controller.relative_url_root = config.relative_url_root


    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.



  end
end
