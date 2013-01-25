require 'spec_helper'

describe "RaaS" do

  describe "convenience methods" do
    let(:options) { {some: "options"} }
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
  end
end
