require "uri"
require "base64"

module Formsg
  module Sdk
    # Used to authenticate the webhook header payload
    class Webhook
      def initialize(public_key: nil, secret_key: nil)
        @public_key = public_key || Formsg::Sdk.config.default_public_key
        @secret_key = secret_key || Formsg::Sdk.config.default_secret_key
      end

      # @param uri [String] Webhook callback URI for the specific form in Formsg
      # @param submission_id [String] Formsg submission ID
      # @param form_id [String] Formsg form ID
      # @param epoch [Integer] Seconds since epoch time
      # @return [String] Signed base string
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

      # @param epoch [Integer] Seconds since epoch time
      # @param submission_id [String] Formsg submission ID
      # @param form_id [String] Formsg form ID
      # @param signature [String] Signed string from the base string
      # @return [String]
      def construct_header(epoch:, submission_id:, form_id:, signature:)
        "t=#{epoch},s=#{submission_id},f=#{form_id},v1=#{signature}"
      end

      # @param header [String] String retrieved from the X-FormSG-Signature header HTTP header
      # @param post_uri [String] Webhook callback URI for the specific form in Formsg
      # @return [Boolean] Returns true if the webhook is authenticated
      # @raise [WebhookAuthenticateError] If unable to authenticate, an exception will be raised
      def authenticate(header:, post_uri: Formsg::Sdk.config.default_post_uri)
        signature_headers = AuthHeader.from_header(header)

        if !signature_header_valid?(post_uri, signature_headers)
          raise WebhookAuthenticateError.new("Signature could not be verified for uri=#{post_uri} submissionId=#{signature_headers.submission_id} formId=#{signature_headers.form_id} epoch=#{signature_headers.epoch} signature=#{signature_headers.signature}")
        end

        if epoch_expired?(epoch: signature_headers.epoch)
          raise WebhookAuthenticateError.new("Signature is not recent for uri=#{post_uri} submissionId=#{signature_headers.submission_id} formId=#{signature_headers.form_id} epoch=#{signature_headers.epoch} signature=#{signature_headers.signature}")
        end

        true
      end

      private

      # @return [RbNaCl::Signatures::Ed25519::SigningKey]
      def signing_key
        @signing_key ||= RbNaCl::SigningKey.new(Base64.decode64(@secret_key)[0, 32])
      rescue => e
        raise WebhookAuthenticateError.new(e.message)
      end

      # @return [RbNaCl::Signatures::Ed25519::VerifyKey]
      def verify_key
        @verify_key ||= RbNaCl::VerifyKey.new(Base64.decode64(@public_key)[0, 32])
      rescue => e
        raise WebhookAuthenticateError.new(e.message)
      end

      # @param uri [String] Webhook callback URI for the specific form in Formsg
      # @return [String] Fully qualified URI string
      def base_href(uri)
        URI.parse(uri)&.to_s
      end

      # Builds the base string
      #
      # @param uri [String] Webhook callback URI for the specific form in Formsg
      # @param submission_id [String] Formsg submission ID
      # @param form_id [String] Formsg form ID
      # @param epoch [Integer] Seconds since epoch time
      # @return [String]
      def base_string_with(uri:, submission_id:, form_id:, epoch:)
        "#{base_href(uri)}.#{submission_id}.#{form_id}.#{epoch}"
      end

      # Signs the base string
      #
      # @param base_string [String]
      # @return [String]
      def sign(base_string)
        Base64.encode64(
          signing_key.sign(base_string)
        )&.gsub("\n", "")
      end

      # Verifies the signature
      #
      # @param base_string [String] Base string as a Base64 encoded string
      # @param signature [String] Signature as a Base64 encoded byte string
      # @return [Boolean]
      def verify(base_string, signature)
        verify_key.verify(
          Base64.decode64(signature),
          base_string
        )
      end

      # Returns validity of signature header
      #
      # @param uri [String] Webhook callback URI for the specific form in Formsg
      # @param signature_header [AuthHeader] Parsed headers from the X-FormSG-Signature header HTTP header
      # @return [Boolean]
      def signature_header_valid?(uri, signature_header)
        raise WebhookAuthenticateError.new("X-FormSG-Signature header is invalid") unless signature_header.valid?

        base_string = base_string_with(uri: uri,
                         submission_id: signature_header.submission_id,
                         form_id: signature_header.form_id,
                         epoch: signature_header.epoch)

        verify(base_string, signature_header.signature)
      end

      def epoch_expired?(epoch:, expiry: 300000)
        difference = (Time.now.strftime('%s%L').to_i - epoch.to_i).abs
        difference > expiry
      end
    end
  end
end