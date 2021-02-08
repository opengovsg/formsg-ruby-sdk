module Formsg
  module Sdk
    module Models
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

        def initialize(options = {})
          KEY_MAP.each do |k,v|
            instance_variable_set("@#{v}".to_sym, options[k]) unless options[k].nil?
          end

          if @answer.nil? && @answer_array.is_a?(Array) && !@answer_array.empty?
            @answer = @answer_array
          end
        end

        def header?
          @is_header
        end

        def many_answers?
          @answer_array.is_a?(Array) && !@answer_array.empty?
        end
      end
    end
  end
end