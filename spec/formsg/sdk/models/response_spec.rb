RSpec.describe Formsg::Sdk::Models::Response do
  describe "#initialize" do
    it "builds a text field" do
      response = {
        _id: "5e7479a086eaf2002488a20e",
        question: "Email",
        fieldType: "email",
        answer: "test@open.gov.sg",
      }
      result = Formsg::Sdk::Models::Response.new(response)

      expect(result.question).to eq("Email")
      expect(result.field_type).to eq("email")
      expect(result.answer).to eq("test@open.gov.sg")
    end

    it "builds a header" do
      response = {
        _id: "5e7479c786eaf2002488a211",
        question: "Header",
        fieldType: "section",
        isHeader: true,
        answer: "",
      }
      result = Formsg::Sdk::Models::Response.new(response)

      expect(result.question).to eq("Header")
      expect(result.field_type).to eq("section")
      expect(result).to be_header
    end

    it "builds an array answer" do
      response = {
        _id: "5e771c7a6b3c5100240368e0",
        question: "Checkbox",
        fieldType: "checkbox",
        answerArray: ["Option 2"],
      }
      result = Formsg::Sdk::Models::Response.new(response)

      expect(result.question).to eq("Checkbox")
      expect(result.field_type).to eq("checkbox")
      expect(result.answer).to include("Option 2")
    end
  end
end