require "rbnacl"
require "formsg/sdk/version"
require "formsg/sdk/auth_header"
require "formsg/sdk/webhook"

module Formsg
  module Sdk
    class Error < StandardError; end
    class WebhookAuthenticateError < StandardError; end
  end
end
