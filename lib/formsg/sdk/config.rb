module Formsg
  module Sdk
    # @param block [Proc] Configuration block
    # @return [Formsg::Sdk::Configuration]
    def self.configure(&block)
      yield @config ||= Configuration.new
    end

    # @return [Formsg::Sdk::Configuration]
    def self.config
      @config
    end

    # @attr_accessor default_public_key [String] Default public key for the Formsg service
    # @attr_accessor default_secret_key [String] Default secret key for the Formsg service
    # @attr_accessor default_form_secret_key [String] Default Form secret key for the specific form in Formsg
    # @attr_accessor default_post_uri [String] Default webhook callback URI for the specific form in Formsg
    class Configuration
      attr_accessor :default_public_key, :default_secret_key, :default_form_secret_key, :default_post_uri

      def initialize
        @default_public_key = "rjv41kYqZwcbe3r6ymMEEKQ+Vd+DPuogN+Gzq3lP2Og=" # Staging Public Key
      end
    end
  end
end
