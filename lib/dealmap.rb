require 'typhoeus'
require 'nokogiri'
require "ext/string"
require 'hashie/mash'
require 'faraday'

module Dealmap
  class Client
    attr :api_key, :conn
    def initialize(api_key)
      raise Dealmap::ApiKeyMissingError, "You must supply an API key" if api_key.nil?
      @api_key = api_key
      @conn = Faraday.new(:url => 'http://api.thedealmap.com') do |builder|
        builder.adapter  :typhoeus
        builder.adapter  :logger
      end
    end

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

    def search_businesess(options = {})
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

    def details(deal_id, options = {})
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
