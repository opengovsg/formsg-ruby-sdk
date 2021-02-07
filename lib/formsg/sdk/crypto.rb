require "base64"
require "json"

module Formsg
  module Sdk
    class Crypto
      attr_reader :public_signing_key

      def initialize(public_signing_key: nil)
        @public_signing_key = public_signing_key || Formsg::Sdk.config.default_public_key
      end

      def decrypt(form_secret_key: Formsg::Sdk.config.default_form_secret_key, data:)
        decrypted_content = decrypt_content(form_secret_key, data['encryptedContent'])

        { responses: ::JSON.parse(decrypted_content, symbolize_names: true) }
      end

      private

      def decrypt_content(form_secret_key, encrypted_content = nil)
        submission_public_key, nonce_encrypted = encrypted_content.split(';')
        nonce, encrypted = nonce_encrypted.split(':').map{ |txt| Base64.decode64(txt) }

        box = RbNaCl::Box.new(Base64.decode64(submission_public_key), Base64.decode64(form_secret_key))
        box.decrypt(nonce, encrypted)
      end
    end
  end
end
