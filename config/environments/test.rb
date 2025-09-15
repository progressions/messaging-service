require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.action_dispatch.show_exceptions = false
  # Provide a test secret_key_base without requiring credentials
  config.secret_key_base = ENV["SECRET_KEY_BASE"] || "test-secret-key-base-7b3a2e1d5f6a4c8e9d0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f"

  # Use STDOUT for CI/logs
  logger           = ActiveSupport::Logger.new($stdout)
  logger.formatter = ::Logger::Formatter.new
  config.logger    = ActiveSupport::TaggedLogging.new(logger)
  config.log_level = :warn
end
