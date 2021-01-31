RSpec.describe Formsg::Sdk::Webhook do
  let(:public_key) { 'KUY1XT30ar+XreVjsS1w/c3EpDs2oASbF6G3evvaUJM=' }
  let(:secret_key) { '/u+LP57Ib9y5Ytpud56FzuitSC9O6lJ4EOLOFHpsHlYpRjVdPfRqv5et5WOxLXD9zcSkOzagBJsXobd6+9pQkw==' }
  subject { Formsg::Sdk::Webhook.new(public_key: public_key, secret_key: secret_key) }

  let(:uri) { "https://some-endpoint.com/post" }
  let(:submission_id) { 'someSubmissionId' }
  let(:form_id) { 'someFormId' }
  let(:epoch) { 1583136171649 }

  describe "#generate_signature" do
    let(:generated_signature) do
      subject.generate_signature(
        uri: uri,
        submission_id: submission_id,
        form_id: form_id,
        epoch: epoch,
      )
    end

    it "signs the signature" do
      expect(generated_signature).to eq("KMirkrGJLPqu+Na+gdZLUxl9ZDgf2PnNGPnSoG1FuTMRUTiQ6o0jB/GTj1XFjn2s9JtsL5GiCmYROpjJhDyxCw==")
    end

    context "invalid when" do
      describe "called with undefined uri" do
        let(:uri) { nil }

        specify do
          expect{ generated_signature }.to raise_error(ArgumentError)
        end
      end

      describe "called with undefined submissionId" do
        let(:submission_id) { nil }

        specify do
          expect{ generated_signature }.to raise_error(ArgumentError)
        end
      end

      describe "called with undefined formId" do
        let(:form_id) { nil }

        specify do
          expect{ generated_signature }.to raise_error(ArgumentError)
        end
      end

      describe "called with undefined epoch" do
        let(:epoch) { nil }

        specify do
          expect{ generated_signature }.to raise_error(ArgumentError)
        end
      end
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

  describe '#authenticate' do
    let(:signature) do
      subject.generate_signature(
        uri: uri,
        submission_id: submission_id,
        form_id: form_id,
        epoch: epoch,
        )
    end
    let(:header) do
      subject.construct_header(
        epoch: epoch,
        submission_id: submission_id,
        form_id: form_id,
        signature: signature
      )
    end

    describe "authenticates a signature that was recently generated" do
      let(:epoch) { Time.now.strftime('%s%L').to_i }

      specify do
        expect(subject.authenticate(header, uri)).to be_truthy
      end
    end

    context "invalid" do
      describe "reject signatures generated more than 5 minutes ago" do
        let(:epoch) { Time.now.strftime('%s%L').to_i - 5 * 60 * 1000 - 1 }

        specify do
          expect{ subject.authenticate(header, uri) }.to raise_error(Formsg::Sdk::WebhookAuthenticateError)
        end
      end

      describe "reject invalid signature headers" do
        let(:header) { "invalidHeader" }

        specify do
          expect{ subject.authenticate(header, uri) }.to raise_error(Formsg::Sdk::WebhookAuthenticateError)
        end
      end

      describe "reject if signature header cannot be verified" do
        subject { Formsg::Sdk::Webhook.new(public_key: public_key, secret_key: 'bad_secret') }

        specify do
          expect{ subject.authenticate(header, uri) }.to raise_error(Formsg::Sdk::WebhookAuthenticateError)
        end
      end

      describe "reject signatures generated more than 5 minutes in the future" do
        let(:epoch) { Time.now.strftime('%s%L').to_i + 5 * 60 * 1000 + 1000 }

        specify do
          expect{ subject.authenticate(header, uri) }.to raise_error(Formsg::Sdk::WebhookAuthenticateError)
        end
      end
    end
  end
end
