require "sidekiq"
require "openssl"

redis_config = {
  url: ENV.fetch("REDIS_URL", nil)
}

if Rails.env.production? && redis_config[:url]&.start_with?("rediss://")
  redis_config[:ssl_params] = {
    verify_mode: OpenSSL::SSL::VERIFY_NONE
  }
end

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end