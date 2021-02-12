module Formsg
  module Sdk
    class SubmissionService
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

      def self.decrypt_for(data:, form_secret_key: nil, public_signing_key: nil)
        form_secret_key = ::Formsg::Sdk.config.default_form_secret_key if form_secret_key.nil?
        public_signing_key = Formsg::Sdk.config.default_public_key if public_signing_key.nil?

        ::Formsg::Sdk::Crypto.new(public_signing_key: public_signing_key)
                             .decrypt(data: data, form_secret_key: form_secret_key)
      end
    end
  end
end
