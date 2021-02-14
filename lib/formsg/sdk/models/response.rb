module Formsg
  module Sdk
    module Models
      # Used to capture each of the submission responses.
      #
      # @attr_reader question [String] Question asked of the submitter
      # @attr_reader answer [String, Array] Answer response from the submitter
      # @attr_reader field_type [String] Type of field this is
      class Response
        attr_reader :question, :answer, :field_type

        KEY_MAP = {
          :_id => :formsg_id,
          :fieldType => :field_type,
          :question => :question,
          :answer => :answer,
          :answerArray => :answer_array,
          :isHeader => :is_header,
        }

        # @param options [Hash] Refer to KEY_MAP for the key name translation from camelCase to underscore_case
        def initialize(options = {})
          KEY_MAP.each do |k,v|
            instance_variable_set("@#{v}".to_sym, options[k]) unless options[k].nil?
          end

          if @answer.nil? && @answer_array.is_a?(Array) && !@answer_array.empty?
            @answer = @answer_array
          end
        end

        # @return [Boolean] Lets us know if this was a header field - with no answer you need
        def header?
          @is_header
        end

        # @return [Boolean] Returns true if the answer comes as a list of many options
        def many_answers?
          @answer_array.is_a?(Array) && !@answer_array.empty?
        end
      end
    end
  end
end