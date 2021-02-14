module Formsg
  module Sdk
    # Helper class for working with the X-FormSG-Signature HTTP header string.
    #
    # @attr_reader epoch [Integer] Seconds since epoch time
    # @attr_reader submission_id [String] Formsg submission ID
    # @attr_reader form_id [String] Formsg form ID
    # @attr_reader signature [String] Signed string from the base string
    class AuthHeader
      attr_reader :epoch, :submission_id, :form_id, :signature

      KEY_MAP = {
        epoch: "t",
        submission_id: "s",
        form_id: "f",
        signature: "v1"
      }

      # @param epoch [Integer] Seconds since epoch time
      # @param submission_id [String] Formsg submission ID
      # @param form_id [String] Formsg form ID
      # @param signature [String] Signed string from the base string
      def initialize(epoch:, submission_id:, form_id:, signature:)
        @epoch = epoch.is_a?(Integer) ? epoch : epoch.to_i
        @submission_id = submission_id
        @form_id = form_id
        @signature = signature
      end

      # Convenience method to parse the header string and build a AuthHeader object.
      #
      # @param header_str [String] String retrieved from the X-FormSG-Signature header HTTP header
      # @return [Formsg::Sdk::AuthHeader]
      def self.from_header(header_str)
        values = self.parse_signature_header(header_str)

        new(KEY_MAP.map { |k,v| [k, values[v]] }.to_h)
      end

      # Lets you know if the parsed header is valid.
      #
      # @return [Boolean]
      def valid?
        @epoch && @submission_id && @form_id && @signature
      end

      private

      # @param signature_string [String] String retrieved from the X-FormSG-Signature header HTTP header.
      # @return [Hash] Converted from the `key1=value1,key2=value2` string to a hash.
      # @raise [Formsg::Sdk::WebhookAuthenticateError]
      def self.parse_signature_header(signature_string)
        return if signature_string.nil? || signature_string.empty?

        signature_string.split(',')
                        .map{ |kv| kv.split(/=(.*)/) }
                        .to_h
      rescue => e
        raise WebhookAuthenticateError.new(e.message)
      end
    end
  end
end
