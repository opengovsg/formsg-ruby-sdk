require "base64"
require "json"

module Formsg
  module Sdk
    # Class for handling the decryption of LibSodium encrypted string.
    #
    # @attr_reader public_signing_key [String] Public signing key of the Formsg service
    class Crypto
      attr_reader :public_signing_key

      # @param public_signing_key [String] Public signing key of the Formsg service. If nil, then defaults to Formsg::Sdk.config.default_public_key.
      def initialize(public_signing_key: nil)
        @public_signing_key = public_signing_key || Formsg::Sdk.config.default_public_key
      end

      # Decrypt the form submission content
      #
      # @param form_secret_key [String] Form secret key for the specific form in Formsg
      # @param data [Hash] Hash of the `data` field from the JSON post from the webhook callback
      # @return [Hash{Symbol->Array}] Hash with a `responses` key. Its an array of user responses.
      def decrypt(form_secret_key: Formsg::Sdk.config.default_form_secret_key, data:)
        decrypted_content = decrypt_content(form_secret_key, data[:encryptedContent])

        { responses: ::JSON.parse(decrypted_content, symbolize_names: true) }
      end

      private

      # Convenience method for decrypting the given encrypted content
      #
      # @param form_secret_key [String]
      # @param encrypted_content [String]
      # @return [String]
      def decrypt_content(form_secret_key, encrypted_content = nil)
        submission_public_key, nonce_encrypted = encrypted_content.split(';')
        nonce, encrypted = nonce_encrypted.split(':').map{ |txt| Base64.decode64(txt) }

        box = RbNaCl::Box.new(Base64.decode64(submission_public_key), Base64.decode64(form_secret_key))
        box.decrypt(nonce, encrypted)
      end
    end
  end
end
