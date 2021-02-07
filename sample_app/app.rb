require "dotenv/load"
require "sinatra"
require 'json'
require_relative "../lib/formsg/sdk"
# require "byebug"

get '/' do
  'Hello world!'
end

Formsg::Sdk.configure do |config|
  config.default_public_key = ENV["FORMSG_PUBLIC_KEY"]
  config.default_form_secret_key = ENV["FORMSG_FORM_SECRET_KEY"]
  config.default_post_uri = ENV["FORMSG_POST_URI"]
end

post '/submissions' do
  signature_status = Formsg::Sdk::Webhook.new.authenticate(header: env["HTTP_X_FORMSG_SIGNATURE"])
  if signature_status
    request.body.rewind
    payload = JSON.parse(request.body.read, symbolize_names: true)
    logger.info "POST params: #{payload.inspect}"

    # Get just the responses as a Hash
    result_hash = Formsg::Sdk::Crypto.new.decrypt(data: payload[:data])
    logger.info "Submission Result (Hash): #{result_hash.inspect}"

    # Get the Submission & Responses as an object
    submission = Formsg::Sdk::Models::Submission.build_from(data: payload[:data])
    logger.info "Submission Result (Object): #{submission.inspect}"
  else
    logger.error "Invalid signature"
  end

  'OK'
end
