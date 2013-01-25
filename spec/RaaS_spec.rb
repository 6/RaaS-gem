require 'spec_helper'

describe "RaaS" do
  let(:options) do
    {
      url: "http://www.google.co.jp/search?q=what",
      endpoint_url: "http://localhost:5002"
    }
  end

  describe ".get" do
    it "calls .execute with the :get method and given options" do
      RaaS.should_receive(:execute).with(:get, options)
      RaaS.get(options)
    end
  end

  describe ".post" do
    it "calls .execute with the :post method and given options" do
      RaaS.should_receive(:execute).with(:post, options)
      RaaS.post(options)
    end
  end

  describe ".execute" do
    context "with invalid options" do
      it "raises a RaaS::InvalidUrl error if the URL is not present" do
        expect { RaaS.execute(:get, {}) }.to raise_error(RaaS::InvalidUrl)
        expect { RaaS.execute(:get, {url: "  "}) }.to raise_error(RaaS::InvalidUrl)
      end

      it "raises a RaaS::InvalidUrl error if the URL has an unsupported scheme" do
        expect { RaaS.execute(:get, {url: "ftp://example.com"}) }.to raise_error(RaaS::InvalidUrl)
      end

      it "raises a RaaS::InvalidEndpointUrl error if the endpoint is not present" do
        expect { RaaS.execute(:get, {url: "http://example.com"}) }.to raise_error(RaaS::InvalidEndpointUrl)
      end

      it "raises a RaaS::InvalidHttpMethod error if the method is not :get or :post" do
        expect { RaaS.execute(:head, options) }.to raise_error(RaaS::InvalidHttpMethod)
      end
    end

    context "with valid options" do
      def stub_request!
        url = "http://localhost:5002/get?url=http%3A%2F%2Fwww.google.co.jp%2Fsearch%3Fq%3Dwhat"
        stub_request(:get, url)
      end

      it "does not raise an error" do
        stub_request!
        expect { RaaS.execute(:get, options) }.not_to raise_error
      end

      it "sends the correct request to the RaaS endpoint URL" do
        request = stub_request!
        RaaS.execute(:get, options)
        request.should have_been_requested
      end
    end
  end
end
