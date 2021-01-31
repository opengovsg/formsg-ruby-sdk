module Formsg
  module Sdk
    class Webhook
      def initialize(public_key:, secret_key:)
        @public_key = public_key
        @secret_key = secret_key
      end
    end
  end
end