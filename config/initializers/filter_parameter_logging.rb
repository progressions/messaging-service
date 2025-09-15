# Be sure to restart your server when you modify this file.

# Configure parameters to be filtered from the log file. Use this to filter out
# sensitive information such as passwords and credentials.
Rails.application.config.filter_parameters += [
  :password, :password_confirmation, :secret, :token, :api_key, :authorization
]

