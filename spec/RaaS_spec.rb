require 'spec_helper'

describe "RaaS" do
  let(:options) do
    {
      url: "http://www.google.co.jp/search?q=what",
      endpoint_url: "http://localhost:5002",
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
      def stub_request!(options = {})
        url = "http://localhost:5002/get?url=http%3A%2F%2Fwww.google.co.jp%2Fsearch%3Fq%3Dwhat"
        url += "&force=#{options[:force]}"  if options[:force]
        url += "&timeout=#{options[:timeout]}"  if options[:timeout]
        stub_request(:post, url).to_return(body: '{}')
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

      it "sends along headers if specified" do
        request = stub_request!.with(:headers => {'User-Agent' => "doubleo7"})
        RaaS.execute(:get, options.merge(headers: {'User-Agent' => 'doubleo7'}))
        request.should have_been_requested
      end

      it "sends along the force param if specified" do
        request = stub_request!(force: "Shift_JIS")
        RaaS.execute(:get, options.merge(force: "Shift_JIS"))
        request.should have_been_requested
      end

      it "sends the timeout param if specified" do
        request = stub_request!(timeout: 15)
        RaaS.execute(:get, options.merge(timeout: 15))
        request.should have_been_requested
      end
    end
  end

  context "if the response from RaaS is 200" do
    it "returns response JSON" do
      url = "http://localhost:5002/get?url=http%3A%2F%2Fwww.google.co.jp%2Fsearch%3Fq%3Dwhat"
      example_response = File.read('./spec/fixtures/response.json')
      stub_request(:post, url).to_return(
        :headers => {'Content-Type' => 'application/json'},
        :body => example_response,
        :status => 200,
      )

      response = RaaS.execute(:get, options)
      response['response']['body'].should == JSON.parse(example_response)['response']['body']
    end
  end

  context "if the response from RaaS is 400" do
    before(:each) do
      url = "http://localhost:5002/get?url=http%3A%2F%2Fwww.google.co.jp%2Fsearch%3Fq%3Dwhat"
      stub_request(:post, url).to_return(
        :status => 400,
        :headers => {'Content-Type' => 'application/json'},
        :body => '{"error":"SocketError"}',
      )
    end

    it "raises a RaaS::BadResponse" do
      expect { RaaS.execute(:get, options) }.to raise_error(RaaS::BadRequest)
    end

    it "includes details in the exception" do
      begin
        RaaS.execute(:get, options)
      rescue => e
        e.message.should == "SocketError"
      end
    end
  end

  context "if the response from RaaS is 5XX" do
    it "raises a RaaS::InternalServerError" do
      url = "http://localhost:5002/get?url=http%3A%2F%2Fwww.google.co.jp%2Fsearch%3Fq%3Dwhat"
      stub_request(:post, url).to_return(
        :status => 500
      )

      expect { RaaS.execute(:get, options) }.to raise_error(RaaS::InternalServerError)
    end
  end

  context "if the response from RaaS is an non-200, 400,or 5XX status code" do
    before(:each) do
      url = "http://localhost:5002/get?url=http%3A%2F%2Fwww.google.co.jp%2Fsearch%3Fq%3Dwhat"
      stub_request(:post, url).to_return(
        :status => 402
      )
    end

    it "raises a RaaS::UnexpectedStatusCode" do
      expect { RaaS.execute(:get, options) }.to raise_error(RaaS::UnexpectedStatusCode)
    end

    it "includes details in the exception message" do
      begin
        RaaS.execute(:get, options)
      rescue => e
        e.message.should == "402"
      end
    end
  end
end
