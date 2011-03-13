require File.expand_path('../../spec_helper', __FILE__)
describe Dealmap::Client do
  context "initialization" do
    it "should raise an ApiKeyMissingError if no API key is given" do
      expect { Dealmap::Client.new(nil) }.to raise_error(Dealmap::ApiKeyMissingError)
    end
  end


  context "api" do
    before(:all) do
      api_key="12345"
      @client = Dealmap::Client.new(api_key)
    end
    context "search deals" do
      use_vcr_cassette
      before do
        @results, @total = @client.search_deals(:l => "Miami, FL")
        @deal = @results.first
      end
      specify { @results.size.should == 20 }
      specify { @total.should == 562 }
      specify { @deal.id.should == "5-EE22936BCFB0E2E1C6AE028D3A17928A" }
    end
  end
end
