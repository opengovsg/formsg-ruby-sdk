RSpec.describe Formsg::Sdk::Models::Submission do
  describe "#initialize" do
    it "builds a submission" do
      data = {
        formId: "5fa0e7880ABCD",
        submissionId: "601fd2e720ebf3ABCD",
        encryptedContent: "some_encrypted_data",
        version: 1,
        created: "2021-02-07T11:45:43.740Z",
        responses: [
          {
            _id: "5e7479c786eaf2002488a211",
            question: "Header",
            fieldType: "section",
            isHeader: true,
            answer: "",
          },
          {
            _id: "5e7479a086eaf2002488a20e",
            question: "Email",
            fieldType: "email",
            answer: "test@open.gov.sg",
          },
          {
            _id: "5e771c246b3c5100240368d8",
            question: "Mobile Number",
            fieldType: "mobile",
            answer: "+6598765432",
          }
        ]
      }

      submission = Formsg::Sdk::Models::Submission.new(data)

      expect(submission.form_id).to eq("5fa0e7880ABCD")
      expect(submission.submission_id).to eq("601fd2e720ebf3ABCD")
      expect(submission.version).to eq(1)
      expect(submission.created_at).to eq(DateTime.parse("2021-02-07T11:45:43.740Z"))

      expect(submission.responses.count).to eq(3)
      expect(submission.responses.first).to be_a(Formsg::Sdk::Models::Response)

      first_response = submission.responses.first
      expect(first_response).to be_header
    end
  end

  describe ".build_from" do
    let(:decrypted_data) do
      {
        responses: [
          {
            _id: "5e7479c786eaf2002488a211",
            question: "Header",
            fieldType: "section",
            isHeader: true,
            answer: "",
          },
          {
            _id: "5e7479a086eaf2002488a20e",
            question: "Email",
            fieldType: "email",
            answer: "test@open.gov.sg",
          },
          {
            _id: "5e771c246b3c5100240368d8",
            question: "Mobile Number",
            fieldType: "mobile",
            answer: "+6598765432",
          }
        ]
      }
    end

    it "builds a submission" do
      crypto = double
      allow(crypto).to receive(:decrypt).and_return(decrypted_data)

      data = {
        formId: "5fa0e7880ABCD",
        submissionId: "601fd2e720ebf3ABCD",
        encryptedContent: "some_encrypted_data",
        version: 1,
        created: "2021-02-07T11:45:43.740Z"
      }

      submission = Formsg::Sdk::Models::Submission.build_from(data: data, crypto: crypto)

      expect(submission).to be_a(Formsg::Sdk::Models::Submission)
      expect(submission.form_id).to eq("5fa0e7880ABCD")
      expect(submission.submission_id).to eq("601fd2e720ebf3ABCD")
      expect(submission.version).to eq(1)
      expect(submission.created_at).to eq(DateTime.parse("2021-02-07T11:45:43.740Z"))

      expect(submission.responses.count).to eq(3)
      expect(submission.responses.first).to be_a(Formsg::Sdk::Models::Response)

      first_response = submission.responses.first
      expect(first_response).to be_header
    end
  end
end