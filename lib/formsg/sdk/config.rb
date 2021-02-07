module Formsg
  module Sdk
    def self.configure(&block)
      yield @config ||= Configuration.new
    end

    def self.config
      @config
    end

    class Configuration
      attr_accessor :default_public_key, :default_secret_key, :default_form_secret_key, :default_post_uri

      def initialize
        @default_public_key = "rjv41kYqZwcbe3r6ymMEEKQ+Vd+DPuogN+Gzq3lP2Og=" # Staging Public Key
      end
    end
  end
end
