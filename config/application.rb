# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_mailbox/engine'
# require "action_text/engine"
require 'action_view/railtie'
# require "action_cable/engine"
require 'rails/test_unit/railtie'
require_relative '../lib/rate_limit/rate_request'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ApiGateway
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.eager_load_paths << Rails.root.join('lib')
    config.eager_load_paths << Rails.root.join('lib/reverse_proxy')
    config.eager_load_paths << Rails.root.join('lib/rate_limit')

    config.middleware.use ActionDispatch::Cookies

    config.action_controller.raise_on_open_redirects = false

    config.navigational_formats = [:json]

    config.middleware.use RateRequest do |r|
      store = if ENV['REDIS_RATE_LIMIT_URL'].present?
                Redis.new(url: ENV['REDIS_RATE_LIMIT_URL']) # use a separate redis DB
              elsif ENV['REDIS_PROVIDER'].present?
                Redis.new(url: ENV[ENV['REDIS_PROVIDER']]) # no separate redis DB available, share primary redis DB
              elsif (redis = Redis.new) && begin
                redis.client.connect
              rescue StandardError
                false
              end
                redis
              elsif Rails.application.config.cache_store != :null_store
                Rails.cache
              end

      r.set_cache(store) if store.present?

      #  Add your rules here, ex:
      #  rpm: Request per minute
      #  rph: Request per hours
      #  rpd: Request per day

      if ENV['RATE_LIMIT'] && ENV['RATE_LIMIT_TYPE'].present? && ENV['RATE_LIMIT_SIZE'].present?
        r.define_rule(match: '/api/v1/cards',
                      metric: ENV['RATE_LIMIT_TYPE'].to_sym,
                      type: :fixed,
                      limit: ENV['RATE_LIMIT_SIZE'].to_i,
                      per_url: true)

        Rails.logger.debug "=> Rate Limiting Store Configured: #{r.cache}"
      end
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*',
                 headers: :any, methods: %w[:get :put :delete :post :options]
      end
    end
  end
end
