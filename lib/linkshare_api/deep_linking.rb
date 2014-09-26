require "addressable/uri"

module LinkshareAPI
  # For implementation details please visit
  # https://rakutenlinkshare.zendesk.com/hc/en-us/articles/201295755-Guide-to-Deep-Linking
  class DeepLinking
    attr_reader :base_url, :affiliate_id

    def initialize
      @affiliate_id = LinkshareAPI.affiliate_id
      @base_url = LinkshareAPI::WEB_SERVICE_URIS[:deep_linking]

      if @affiliate_id.nil?
        raise AuthenticationError.new(
          "No Affilite ID. Set your Affiliate ID by using 'LinkshareAPI.affiliate_id = <AFFILIATE_ID>'. " +
          "See https://github.com/rmarescu/linkshare_api#deep-linking for details."
        )
      end
    end

    def build(mid, murl)
      raise ArgumentError, "mid must be a Fixnum, got #{mid.class} instead" unless mid.is_a?(Fixnum)

      uri = Addressable::URI.parse(base_url)
      uri.query_values = {
        id: affiliate_id,
        mid: mid,
        murl: murl
      }
      uri.to_s
    end
  end
end
