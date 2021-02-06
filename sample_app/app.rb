require "dotenv/load"
require "sinatra"
require 'json'
require_relative "../lib/formsg/sdk"
# require "byebug"

get '/' do
  'Hello world!'
end

post '/submissions' do
  webhook = Formsg::Sdk::Webhook.new(public_key: ENV["FORMSG_PUBLIC_KEY"])

  signature_status = webhook.authenticate(env["HTTP_X_FORMSG_SIGNATURE"], ENV["FORMSG_POST_URI"])
  if signature_status
    payload = JSON.parse(request.body.read)
    logger.info "POST params: #{payload.inspect}"

    crypto = Formsg::Sdk::Crypto.new(public_signing_key: ENV["FORMSG_PUBLIC_KEY"])
    result = crypto.decrypt(form_secret_key: ENV["FORMSG_FORM_SECRET_KEY"],
                   data: payload["data"])

    logger.info "Submission Result: #{result.inspect}"
  else
    logger.error "Invalid signature"
  end

  'OK'
end
