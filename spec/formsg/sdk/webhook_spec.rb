RSpec.describe Formsg::Sdk::Webhook do
  let(:public_key) { 'KUY1XT30ar+XreVjsS1w/c3EpDs2oASbF6G3evvaUJM=' }
  let(:secret_key) { '/u+LP57Ib9y5Ytpud56FzuitSC9O6lJ4EOLOFHpsHlYpRjVdPfRqv5et5WOxLXD9zcSkOzagBJsXobd6+9pQkw==' }
  subject { Formsg::Sdk::Webhook.new(public_key: public_key, secret_key: secret_key) }

  let(:uri) { "https://some-endpoint.com/post" }
  let(:submission_id) { 'someSubmissionId' }
  let(:form_id) { 'someFormId' }
  let(:epoch) { 1583136171649 }

  describe "#initialize" do
    it "sets the instance variables" do
      expect(subject.instance_variable_get(:@public_key)).to eq(public_key)
      expect(subject.instance_variable_get(:@secret_key)).to eq(secret_key)
    end
  end

  describe "#generate_signature" do
    it "signs the signature" do
      signature = subject.generate_signature(
        uri: uri,
        submission_id: submission_id,
        form_id: form_id,
        epoch: epoch,
      )

      expect(signature).to eq("KMirkrGJLPqu+Na+gdZLUxl9ZDgf2PnNGPnSoG1FuTMRUTiQ6o0jB/GTj1XFjn2s9JtsL5GiCmYROpjJhDyxCw==")
    end
  end

  describe "#construct_header" do
    it "generates the X-FormSG-Signature header" do
      header = subject.construct_header(
        epoch: epoch,
        submission_id: submission_id,
        form_id: form_id,
        signature: "KMirkrGJLPqu+Na+gdZLUxl9ZDgf2PnNGPnSoG1FuTMRUTiQ6o0jB/GTj1XFjn2s9JtsL5GiCmYROpjJhDyxCw=="
      )

      expect(header).to eq("t=1583136171649,s=someSubmissionId,f=someFormId,v1=KMirkrGJLPqu+Na+gdZLUxl9ZDgf2PnNGPnSoG1FuTMRUTiQ6o0jB/GTj1XFjn2s9JtsL5GiCmYROpjJhDyxCw==")
    end
  end
end
