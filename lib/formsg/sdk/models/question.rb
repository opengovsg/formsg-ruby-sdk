module Formsg
  module Sdk
    module Models
      class Question
        attr_reader :question, :answer, :field_type

        def initialize(_id:,
                       fieldType:,
                       question:,
                       answer: nil,
                       answerArray: nil,
                       isHeader: false)
          @_id = _id
          @field_type = fieldType
          @question = question
          @is_header = isHeader

          @answer = answer
          if answer.nil? && answerArray.is_a?(Array) && !answerArray.empty?
            @answer = answerArray
          end
        end

        def header?
          @is_header
        end
      end
    end
  end
end