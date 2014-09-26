# Version
require "linkshare_api/version"

# Resources
require File.expand_path("../linkshare_api/link_generator", __FILE__)
require File.expand_path("../linkshare_api/deep_linking", __FILE__)
require File.expand_path("../linkshare_api/product_search", __FILE__)
require File.expand_path("../linkshare_api/coupon_web_service", __FILE__)
require File.expand_path("../linkshare_api/response", __FILE__)

# Errors
require File.expand_path("../linkshare_api/errors/error", __FILE__)
require File.expand_path("../linkshare_api/errors/authentication_error", __FILE__)
require File.expand_path("../linkshare_api/errors/connection_error", __FILE__)
require File.expand_path("../linkshare_api/errors/invalid_request_error", __FILE__)

# Misc
require File.expand_path("../linkshare_api/logger", __FILE__)

module LinkshareAPI
  WEB_SERVICE_URIS = {
    link_generator: "http://getdeeplink.linksynergy.com/createcustomlink.shtml",
    deep_linking: "http://click.linksynergy.com/deeplink",
    product_search: "http://productsearch.linksynergy.com/productsearch",
    coupon_web_service: "http://couponfeed.linksynergy.com/coupon"
  }

  PARSE_RESULT = {
    link_generator: "item",
    product_search: "item",
    coupon_web_service: "link"
  }

  RESULT = {
    product_search: "result",
    coupon_web_service: "couponfeed"
  }

  PAGE_NUMBER = {
    product_search: "PageNumber",
    coupon_web_service: "PageNumberRequested"
  }

  @api_timeout  = 30

  class << self
    attr_accessor :token, :affiliate_id, :logger
    attr_reader   :api_timeout
  end

  def self.api_timeout=(timeout)
    raise ArgumentError, "Timeout must be a Fixnum; got #{timeout.class} instead" unless timeout.is_a? Fixnum
    raise ArgumentError, "Timeout must be > 0; got #{timeout} instead" unless timeout > 0
    @api_timeout = timeout
  end

  def self.link_generator(mid, murl)
    if affiliate_id.nil?
      LinkshareAPI::Logger.log(
        :warn,
        "`Automated Link Generator` has been discontinued in favor of `Deep Linking`. " +
        "To use `Deep Linking` you only have to set your Affiliate ID by executing " +
        "'LinkshareAPI.affiliate_id = <AFFILIATE_ID>'. Everything else remains the same. " +
        "See https://github.com/rmarescu/linkshare_api#deep-linking for details."
      )
      link_generator = LinkshareAPI::LinkGenerator.new
    else
      link_generator = LinkshareAPI::DeepLinking.new
    end
    link_generator.build(mid, murl)
  end

  def self.product_search(options = {})
    product_search = LinkshareAPI::ProductSearch.new
    product_search.query(options)
  end

  def self.coupon_web_service(options = {})
    coupon_web_service = LinkshareAPI::CouponWebService.new
    coupon_web_service.query(options)
  end
end
