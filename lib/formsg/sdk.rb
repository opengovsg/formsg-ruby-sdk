require "rbnacl"
require "ed25519"
require "formsg/sdk/version"
require "formsg/sdk/webhook"

module Formsg
  module Sdk
    class Error < StandardError; end
    class WebhookAuthenticateError < StandardError; end
  end
end
