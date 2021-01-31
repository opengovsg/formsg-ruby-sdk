require "uri"
require "base64"

module Formsg
  module Sdk
    class Webhook
      def initialize(public_key:, secret_key:)
        @public_key = public_key
        @secret_key = secret_key

        @signing_key = ::Ed25519::SigningKey.from_keypair(Base64.decode64(@secret_key))
      end

      def generate_signature(uri:, submission_id:, form_id:, epoch:)
        base_string = "#{base_href(uri)}.#{submission_id}.#{form_id}.#{epoch}"
        sign(base_string)
      end

      def construct_header(epoch:, submission_id:, form_id:, signature:)
        "t=#{epoch},s=#{submission_id},f=#{form_id},v1=#{signature}"
      end

      private

      def base_href(uri)
        URI.parse(uri)&.to_s
      end

      def sign(base_string)
        Base64.encode64(
          @signing_key.sign(base_string)
        )&.gsub("\n", "")
      end
    end
  end
end