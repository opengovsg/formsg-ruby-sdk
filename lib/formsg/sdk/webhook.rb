require "uri"
require "base64"

module Formsg
  module Sdk
    class Webhook
      SIGNATURE_KEYS = %w[v1 t s f]

      def initialize(public_key:, secret_key:)
        @public_key = public_key
        @secret_key = secret_key
      end

      def generate_signature(uri:, submission_id:, form_id:, epoch:)
        unless uri && submission_id && form_id && epoch
          raise ArgumentError.new("Signature could not be generated for uri=#{uri} submissionId=#{submission_id} formId=#{form_id} epoch=#{epoch}")
        end

        base_string = base_string_with(uri: uri,
                                       submission_id: submission_id,
                                       form_id: form_id,
                                       epoch: epoch)

        sign(base_string)
      end

      def construct_header(epoch:, submission_id:, form_id:, signature:)
        "t=#{epoch},s=#{submission_id},f=#{form_id},v1=#{signature}"
      end

      def authenticate(header_str, uri)
        signature_header = parse_signature_header(header_str)

        if !signature_header_valid?(uri, signature_header)
          raise WebhookAuthenticateError.new("Signature could not be verified for uri=#{uri} submissionId=#{signature_header["s"]} formId=#{signature_header["f"]} epoch=#{signature_header["t"]} signature=#{signature_header["v1"]}")
        end

        if epoch_expired?(epoch: signature_header["t"])
          raise WebhookAuthenticateError.new("Signature is not recent for uri=#{uri} submissionId=#{signature_header["s"]} formId=#{signature_header["f"]} epoch=#{signature_header["t"]} signature=#{signature_header["v1"]}")
        end

        true
      end

      private

      def signing_key
        @signing_key ||= ::Ed25519::SigningKey.from_keypair(Base64.decode64(@secret_key))
      rescue => e
        raise WebhookAuthenticateError.new(e.message)
      end

      def base_href(uri)
        URI.parse(uri)&.to_s
      end

      def base_string_with(uri:, submission_id:, form_id:, epoch:)
        "#{base_href(uri)}.#{submission_id}.#{form_id}.#{epoch}"
      end

      def sign(base_string)
        Base64.encode64(
          signing_key.sign(base_string)
        )&.gsub("\n", "")
      end

      def verify(base_string, signature)
        signing_key.verify_key.verify(
          Base64.decode64(signature),
          base_string
        )
      end

      def parse_signature_header(signature_string)
        return if signature_string.nil? || signature_string.empty?

        signature_string.split(',')
                        .map{ |kv| kv.split('=') }
                        .to_h
      rescue => e
        raise WebhookAuthenticateError.new(e.message)
      end

      def signature_header_valid?(uri, signature_header)
        if signature_header.keys.sort != SIGNATURE_KEYS.sort
          raise WebhookAuthenticateError.new("X-FormSG-Signature header is invalid")
        end

        base_string = base_string_with(uri: uri,
                         submission_id: signature_header["s"],
                         form_id: signature_header["f"],
                         epoch: signature_header["t"])

        verify(base_string, signature_header["v1"])
      end

      def epoch_expired?(epoch:, expiry: 300000)
        difference = (Time.now.strftime('%s%L').to_i - epoch.to_i).abs
        difference > expiry
      end
    end
  end
end