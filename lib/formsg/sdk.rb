require "rbnacl"
require "formsg/sdk/config"
require "formsg/sdk/version"
require "formsg/sdk/auth_header"
require "formsg/sdk/webhook"
require "formsg/sdk/crypto"
require "formsg/sdk/models/response"
require "formsg/sdk/models/submission"

module Formsg
  module Sdk
    class Error < StandardError; end
    class WebhookAuthenticateError < StandardError; end
  end
end
