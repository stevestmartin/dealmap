require 'typhoeus'
require 'nokogiri'
require 'core_ext/string'
require 'hashie/mash'
require 'faraday'

# The Dealmap namespace.
module Dealmap
  # Defines methods for the Dealmap API
  class Client
    attr_reader :api_key, :conn
    # Initialize the Dealmap client
    # @param api_key [String] Your Dealmap API Key
    def initialize(api_key)
      raise Dealmap::ApiKeyMissingError, "You must supply an API key" if api_key.nil?
      @api_key = api_key
      @conn = Faraday.new(:url => 'http://api.thedealmap.com') do |builder|
        builder.adapter  :typhoeus
        builder.adapter  :logger
      end
    end

    # Search for deals  
    # @param options [Hash] A customizable set of options  
    # @option options [String] :l Location around which the deals are searched for. This is a required field. This can be text value or lat/lon value. Examples: Seattle, WA or \+43.324-123.432. Note about geocoding: It is recommended that you send latitude/longitude location as it reduces the need for geo-coding (which may slow down your request) and may not be accurate at all times
    # @option options [String] :q Query keyword. Optional. For example if you want to find beer deals, you send keyword as your query 'q=beer'. If you want to get all deals, either drop q or send q=\*
    # @option options [Fixnum] :d Distance around the location specified in the query. Optional. Default value is 5 miles. Always expressed in miles.  
    # @option options [Fixnum] :si Start index of the deals. Used for paging through the results. Optional. Default value is 0 - which means start from the beginning.  
    # @option options [Fixnum] :ps Page size. Used for paging through the deal results. Optional. Default page size is 20. Maximum number of deals per page is 100.  
    # @option options [Fixnum] :a {http://apiwiki.thedealmap.com/index.php/Center%27d_Activity Center'd Activity}. Used to filter the results based on the type of activity. For example, send 1 for kid-friendly deals and 8 for romantic deals etc.
    # @option options [Fixnum] :c {http://apiwiki.thedealmap.com/index.php/Deal_capability Deal capability}. Used to filter the results based on the deal type. For example, to get daily deals only, send c=16.
    # @option options [String] :ed Expiration date. Used to filter the deals based on their expiration date. For example to get deals that are expiring soon (say by April 22nd 2010), you send ed=2010-04-22
    # @return [Array, Fixnum] An array of Hashie::Mash objects representing deals.  An integer representing the total number of deals available for retrieval.  Note, this value and the size of the results array may differ, as *total* represents all available deals, not only the ones returned in your query.
    #
    # @example Search for deals in Miami, FL and get the total # of deals available
    #   @client = Dealmap::Client.new("YOUR_API_KEY")
    #   deals, total = @client.search_deals(:l => "Miami, FL")
    #   deals.each {|deal| puts deal.inspect }
    # @example Search for all deals within a 50 mile radius of Miami, FL
    #   deals, total = @client.search_deals(:l => "Miami, FL", :d => 50)
    # @example Search for beer deals within a 50 mile radius of Miami, FL
    #   deals, total = @client.search_deals(:l => "Miami, FL", :d => 50, :q => "beer")
    # @example Search for beer deals within a 50 mile radius of Miami, FL and return 100 results
    #   deals, total = @client.search_deals(:l => "Miami, FL", :d => 50, :q => "beer", :ps => 100)
    def search_deals(options = {})
      options = options.merge(:key => api_key)
      response = conn.get("/search/deals/") { |req| req.params = options }
      doc = Nokogiri::XML(response.body)
      results = doc.search("Deal")
      total = doc.search("TotalResults").first.text.to_i
      deals = []
      results.each do |deal|
        attrs = Hashie::Mash.new
        deal.children.map do |child|
          attrs[child.name.underscore] = child.text.strip.rstrip
        end
        deals << attrs
      end
      return deals, total
    end


    # Search for businesses  
    # @param options [Hash] A customizable set of options  
    # @option options [String] :l Location around which the businesses are searched for. This is a required field. This can be text value or lat/lon value. Examples: Seattle, WA or \+43.324-123.432. Note about geocoding: It is recommended that you send latitude/longitude location as it reduces the need for geo-coding (which may slow down your request) and may not be accurate at all times
    # @option options [String] :q Query keyword. Optional. For example if you want to find bars, you send keyword as your query 'q=bar'. 
    # @option options [Fixnum] :d Distance around the location specified in the query. Optional. Default value is 5 miles. Always expressed in miles.  
    # @option options [Fixnum] :si Start index of the businesses. Used for paging through the results. Optional. Default value is 0 - which means start from the beginning.  
    # @option options [Fixnum] :ps Page size. Used for paging through the business listing results. Optional. Default page size is 20. Maximum number of deals per page is 100.  
    # @option options [Fixnum] :a {http://apiwiki.thedealmap.com/index.php/Center%27d_Activity Center'd Activity}. Used to filter the results based on the type of activity. For example, send 1 for kid-friendly businesses and 8 for romantic businesses (whatever that means) etc.
    # @return [Array, Fixnum] An array of Hashie::Mash objects representing businesses.  An integer representing the total number of businesses available for retrieval.  Note, this value and the size of the results array may differ, as *total* represents all available businesses, not only the ones returned in your query.
    #
    # @example Search for businesses in Miami, FL and get the total # of deals available
    #   @client = Dealmap::Client.new("YOUR_API_KEY")
    #   businesses, total = @client.search_businesses(:l => "Miami, FL")
    #   businesses.each {|business| puts business.inspect }
    # @example Search for all businesses within a 50 mile radius of Miami, FL
    #   businesses, total = @client.search_businesses(:l => "Miami, FL", :d => 50)
    # @example Search for bars within a 50 mile radius of Miami, FL
    #   businesses, total = @client.search_businesses(:l => "Miami, FL", :d => 50, :q => "bar")
    # @example Search for bars within a 50 mile radius of Miami, FL and return 100 results
    #   businesses, total = @client.search_businesses(:l => "Miami, FL", :d => 50, :q => "bar", :ps => 100)
    def search_businesses(options = {})
      options = options.merge(:key => api_key)
      response = conn.get("/search/businesses/") { |req| req.params = options }
      doc = Nokogiri::XML(response.body)
      results = doc.search("Business")
      total = doc.search("TotalResults").first.text.to_i
      businesses = []
      results.each do |business|
        attrs = Hashie::Mash.new
        business.children.map do |child|
          attrs[child.name.underscore] = child.text.strip.rstrip
        end
        businesses << attrs
      end
      return businesses, total
    end

    # Get deal details.
    # @param deal_id [String] A deal id
    # @param options [Hash] An optional set of options.  Currently unused.
    # @return [Hashie::Mash] A Hashie::Mash object representing a deal
    # @example Example response:
    #   {"activity"=>"0",
    #    "added_by"=>"",
    #    "additional_discount_coupon_code"=>"",
    #    "additional_discount_coupon_effective_time"=>"0001-01-01T00:00:00",
    #    "additional_discount_coupon_expiration_time"=>"0001-01-01T00:00:00",
    #    "additional_discount_deal_unit"=>"0",
    #    "additional_discounted_value"=>"0",
    #    "address_line"=>"7726 W Sand Lake Rd",
    #    "affiliation"=>"",
    #    "b_description"=>"",
    #    "business_id"=>"",
    #    "business_name"=>"Shala Salon & Spa",
    #    "capability"=>"211",
    #    "category"=>"Beauty & Spas,Waxing",
    #    "city"=>"Orlando",
    #    "country"=>"",
    #    "currency"=>"1",
    #    "deal_source"=>"Groupon",
    #    "deal_type"=>"8",
    #    "deal_unit"=>"1",
    #    "description"=>"",
    #    "discounted_value"=>"10",
    #    "effective_time"=>"2011-03-13T03:01:00",
    #    "expiration_time"=>"2011-03-13T20:59:00",
    #    "face_value"=>"20",
    #    "id"=>"5-4A3EDD412F8C1ECF7F5A6AEDDAF7DA2A",
    #    "icon_url"=>"",
    #    "image_url"=>
    #    "http://www.groupon.com/images/site_images/0686/1969/Shala-Salon-_-Spa.jpg",
    #    "keywords"=>"",
    #    "latitude"=>"28.4498819801956",
    #    "longitude"=>"-81.4899128861725",
    #    "more_info_link"=>
    #    "http://www.thedealmap.com/deal/?dealid=5-4A3EDD412F8C1ECF7F5A6AEDDAF7DA2A&s=2-500726978-634341593775180000&utm_campaign=api",
    #    "phone"=>"",
    #    "state"=>"FL",
    #    "tags"=>"",
    #    "terms"=>"",
    #    "title"=>
    #    "$20 For A Full-Face Threading ($40 Value) Or $10 For An Eyebrow Threading ($20 Value) At Shala Salon & Day Spa",
    #    "tracking_url"=>"",
    #    "transaction_url"=>
    #    "http://www.thedealmap.com/x/?s=2-500726978-634341593775180000&id=5-4A3EDD412F8C1ECF7F5A6AEDDAF7DA2A",
    #    "you_save"=>"50 %",
    #    "zip_code"=>""}
    def deal_details(deal_id, options = {})
      options = options.merge(:key => api_key)
      response = conn.get("/deals/#{deal_id}") { |req| req.params = options }
      doc = Nokogiri::XML(response.body)
      deal = doc.search("Deal").first
      attrs = Hashie::Mash.new
      deal.children.each do |attr|
        attrs[attr.name.underscore] = attr.text.strip.rstrip
      end
      return attrs
    end
  end
  class ApiKeyMissingError < StandardError; end
end
