module Formsg
  module Sdk
    class AuthHeader
      attr_reader :epoch, :submission_id, :form_id, :signature

      KEY_MAP = {
        epoch: "t",
        submission_id: "s",
        form_id: "f",
        signature: "v1"
      }

      def initialize(epoch:, submission_id:, form_id:, signature:)
        @epoch = epoch.is_a?(Integer) ? epoch : epoch.to_i
        @submission_id = submission_id
        @form_id = form_id
        @signature = signature
      end

      def self.from_header(header_str)
        values = self.parse_signature_header(header_str)

        new(KEY_MAP.map { |k,v| [k, values[v]] }.to_h)
      end

      def valid?
        @epoch && @submission_id && @form_id && @signature
      end

      private

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
