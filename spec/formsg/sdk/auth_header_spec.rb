RSpec.describe Formsg::Sdk::AuthHeader do
  describe ".from_header" do
    let(:header_str) { "t=1583136171649,s=someSubmissionId,f=someFormId,v1=KMirkrGJLPqu+Na+gdZLUxl9ZDgf2PnNGPnSoG1FuTMRUTiQ6o0jB/GTj1XFjn2s9JtsL5GiCmYROpjJhDyxCw==" }
    subject { Formsg::Sdk::AuthHeader.from_header(header_str) }

    it "parses the component parts" do
      expect(subject.epoch).to eq(1583136171649)
      expect(subject.submission_id).to eq("someSubmissionId")
      expect(subject.form_id).to eq("someFormId")
      expect(subject.signature).to eq("KMirkrGJLPqu+Na+gdZLUxl9ZDgf2PnNGPnSoG1FuTMRUTiQ6o0jB/GTj1XFjn2s9JtsL5GiCmYROpjJhDyxCw==")
    end
  end
end
