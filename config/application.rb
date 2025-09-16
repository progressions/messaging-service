require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"

module MessagingService
  class Application < Rails::Application
    # Require gems listed in Gemfile per environment
    Bundler.require(*Rails.groups)

    config.load_defaults 8.0
    config.api_only = true

    # Timezone/locale defaults can be set here if needed
    # config.time_zone = "UTC"

    # Ensure serializers are autoloaded/eager loaded
    config.autoload_paths << Rails.root.join('app/serializers')
    config.eager_load_paths << Rails.root.join('app/serializers')
    config.autoload_paths << Rails.root.join('app/services')
    config.eager_load_paths << Rails.root.join('app/services')
  end
end
