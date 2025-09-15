require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Code is reloaded between requests.
  config.cache_classes = false
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true
  config.server_timing = true
  # Provide a development secret_key_base without requiring credentials
  config.secret_key_base = ENV["SECRET_KEY_BASE"] || "dev-secret-key-base-1c5fd2d1e6e24a899c1a5e2b7e1d62c4b9c0ea3c3c4c8f1e9b6d0d6b8c1f2a3"

  # Log to STDOUT in container-friendly environments
  logger           = ActiveSupport::Logger.new($stdout)
  logger.formatter = ::Logger::Formatter.new
  config.logger    = ActiveSupport::TaggedLogging.new(logger)
  config.log_level = :debug
end
