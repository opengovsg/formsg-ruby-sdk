require 'date'

module Formsg
  module Sdk
    module Models
      # Used to capture the submission data so it can be interacted in an OOP way in your application.
      #
      # @attr_reader form_id [String] ID of the Formsg form
      # @attr_reader submission_id [String] ID of the submission entry from Formsg
      # @attr_reader version [String] Version number of the webhook. Defaults to 1 right now.
      # @attr_reader created_at [DateTime] DateTime of the submission. No TZ info. Just GMT time.
      # @attr_reader responses [Array<Response>] List of all the responses as {Response}
      class Submission
        attr_reader :form_id, :submission_id, :version, :created_at, :responses

        KEY_MAP = {
          :formId => :form_id,
          :submissionId => :submission_id,
          :version => :version,
          :created => :created_at,
          :responses => :responses,
        }

        # @param options [Hash] Values to be used to initialize the Responses and other attributes. Refer to the KEY_MAP for key name translation.
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
      end
    end
  end
end