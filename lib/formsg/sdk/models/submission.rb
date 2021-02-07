require 'date'

module Formsg
  module Sdk
    module Models
      class Submission
        attr_reader :form_id, :submission_id, :version, :created_at
        attr_accessor :responses

        def initialize(options = {})
          @form_id = options["formId"]
          @submission_id = options["submissionId"]
          @version = options["version"]
          @created_at = ::DateTime.parse(options["created"]) unless options["created"].nil?
          @responses = options["responses"]
        end

        def self.build_from(data:, crypto: Crypto.new)
          decrypted_data = crypto.decrypt(data: data)

          data["responses"] = decrypted_data[:responses].map do |qn|
            Question.new(qn)
          end

          new(data)
        end
      end
    end
  end
end