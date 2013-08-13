# Version
require "linkshare_api/version"

# Resources
require "linkshare_api/link_generator"
require "linkshare_api/product_search"
require "linkshare_api/response"

# Errors
require "linkshare_api/errors/error"
require "linkshare_api/errors/authentication_error"
require "linkshare_api/errors/connection_error"
require "linkshare_api/errors/invalid_request_error"

module LinkshareAPI
  WEB_SERVICE_URIS = {
    link_generator: "http://getdeeplink.linksynergy.com/createcustomlink.shtml",
    product_search: "http://productsearch.linksynergy.com/productsearch"
  }

  @api_timeout  = 30

  class << self
    attr_accessor :token
    attr_reader   :api_timeout
  end

  def self.api_timeout=(timeout)
    raise ArgumentError, "Timeout must be a Fixnum; got #{timeout.class} instead" unless timeout.is_a? Fixnum
    raise ArgumentError, "Timeout must be > 0; got #{timeout} instead" unless timeout > 0
    @api_timeout = timeout
  end

  def self.link_generator(mid, murl)
    link_generator = LinkshareAPI::LinkGenerator.new
    link_generator.build(mid, murl)
  end

  def self.product_search(options = {})
    product_search = LinkshareAPI::ProductSearch.new
    product_search.query(options)
  end
end
