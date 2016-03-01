require './lib/cassie/configuration/generator'

RSpec.describe Cassie::Configuration::Generator do
  let(:klass) do
    Cassie::Configuration::Generator
  end
  let(:object){ klass.new(args) }
  let(:args){
    {
      app_name: app_name,
      destination_path: destination_path,
      template_path: template_path
    }.delete_if { |k, v| v == :undefined }
  }
  let(:app_name){ :undefined }
  let(:destination_path){ :undefined }
  let(:template_path){ :undefined }

  describe ".save" do
    let(:destination_path){ 'some_path' }
    let(:buffer){ StringIO.new() }

    it "writes the rendering to destination_path" do
      allow(File).to receive(:open).with(destination_path, anything()).and_yield( buffer )

      object.save

      expect(buffer.string).to eq(object.render)
    end
  end

  describe ".render" do
    context "when app_name defined" do
      let(:app_name){ 'foo' }

      it "includes the app_name" do
        expect(object.render).to include(app_name)
      end
      it "does not include my_app" do
        expect(object.render).not_to include('my_app')
      end
    end

    it "includes a policy erb interpolation" do
        expect(object.render).to match(/<%= Cassandra::Reconnection::Policies::Exponential.new\([^,]*, [^,]*, [^,]*\) %>/)
    end
  end
end
