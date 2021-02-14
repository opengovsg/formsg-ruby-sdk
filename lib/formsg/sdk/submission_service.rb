module Formsg
  module Sdk
    # Convenience service used to interact with the SDK
    class SubmissionService
      # @param data [Hash<Symbol, String>] Hash of the `data` field from the JSON post from the webhook callback
      # @param crypto [Crypto, nil] {Crypto} instance in case you wish to use a shared instance. Nil by default.
      # @param form_secret_key [String, nil] Your form secret key used to decrypt the encrypted content. Defaults to default_form_secret_key
      # @param public_signing_key [String, nil] Public key for the Formsg service. Defaults to default_public_key.
      # @return [Formsg::Sdk::Models::Submission]
      def self.build_from(data:, crypto: nil, form_secret_key: nil, public_signing_key: nil)
        if crypto.nil?
          public_signing_key = ::Formsg::Sdk.config.default_public_key if public_signing_key.nil?
          crypto = ::Formsg::Sdk::Crypto.new(public_signing_key: public_signing_key) if crypto.nil?
        end

        opts = { data: data }
        opts[:form_secret_key] = form_secret_key unless form_secret_key.nil?
        data[:responses] = crypto.decrypt(opts).dig(:responses)

        ::Formsg::Sdk::Models::Submission.new(data)
      end

      # @param data [Hash<Symbol, String>] Hash of the `data` field from the JSON post from the webhook callback
      # @param form_secret_key [String, nil] Your form secret key used to decrypt the encrypted content. Defaults to default_form_secret_key
      # @param public_signing_key [String, nil] Public key for the Formsg service. Defaults to default_public_key.
      def self.decrypt_for(data:, form_secret_key: nil, public_signing_key: nil)
        form_secret_key = ::Formsg::Sdk.config.default_form_secret_key if form_secret_key.nil?
        public_signing_key = Formsg::Sdk.config.default_public_key if public_signing_key.nil?

        ::Formsg::Sdk::Crypto.new(public_signing_key: public_signing_key)
                             .decrypt(data: data, form_secret_key: form_secret_key)
      end
    end
  end
end
