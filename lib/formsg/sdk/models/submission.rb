require 'date'

module Formsg
  module Sdk
    module Models
      class Submission
        attr_reader :form_id, :submission_id, :version, :created_at, :responses

        KEY_MAP = {
          :formId => :form_id,
          :submissionId => :submission_id,
          :version => :version,
          :created => :created_at,
          :responses => :responses,
        }

        def initialize(options = {})
          KEY_MAP.each do |k,v|
            instance_variable_set("@#{v}".to_sym, options[k]) unless options[k].nil?
          end

          @created_at = ::DateTime.parse(@created_at) unless @created_at.nil?

          if !@responses.nil? && @responses&.count > 0
            @responses = @responses.map do |qn|
              Response.new(qn)
            end
          end
        end

        def self.build_from(data:, crypto: Crypto.new, form_secret_key: nil)
          opts = { data: data }
          opts[:form_secret_key] = form_secret_key unless form_secret_key.nil?

          data[:responses] = crypto.decrypt(opts).dig(:responses)

          new(data)
        end
      end
    end
  end
end