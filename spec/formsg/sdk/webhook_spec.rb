RSpec.describe Formsg::Sdk::Webhook do
  describe "" do
    let(:public_key) { 'very_public' }
    let(:secret_key) { 'very_secret' }

    it "initializes" do
      subject = Formsg::Sdk::Webhook.new(public_key: public_key, secret_key: secret_key)

      expect(subject.instance_variable_get(:@public_key)).to eq(public_key)
      expect(subject.instance_variable_get(:@secret_key)).to eq(secret_key)
    end
  end
end
