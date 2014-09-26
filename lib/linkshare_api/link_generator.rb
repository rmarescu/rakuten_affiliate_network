require "cgi"
require "httparty"

module LinkshareAPI
  # For implementation details please visit
  # https://rakutenlinkshare.zendesk.com/hc/en-us/articles/201343135-Automated-LinkGenerator-Guidelines
  class LinkGenerator
    include HTTParty

    attr_reader :api_base_url, :token, :api_timeout

    def initialize
      @token        = LinkshareAPI.token
      @api_base_url = LinkshareAPI::WEB_SERVICE_URIS[:link_generator]
      @api_timeout  = LinkshareAPI.api_timeout

      if @token.nil?
        raise AuthenticationError.new(
          "No token. Set your token by using 'LinkshareAPI.token = <TOKEN>'. " +
          "You can retrieve your token from LinkhShare's Web Services page under the Links tab. " +
          "See https://rakutenlinkshare.zendesk.com/hc/en-us/articles/200992487-What-is-a-Web-Services-Token-Feed-Token- for details."
        )
      end
    end

    def build(mid, murl)
      raise ArgumentError, "mid must be a Fixnum, got #{mid.class} instead" unless mid.is_a?(Fixnum)

      query_string = "token=#{CGI.escape(token)}"
      query_string << "&mid=#{mid}"
      # murl must not be encoded (RFC ftw)
      query_string << "&murl=#{murl}"
      api_request_url = "#{api_base_url}?#{query_string}"
      begin
        response = self.class.get(api_request_url, timeout: api_timeout)
      rescue Timeout::Error
        raise ConnectionError.new("Timeout error (#{timeout}s)")
      end

      if response.code != 200
        raise Error.new("Unexpected response: #{response.message}", response.code)
      end

      # If the body content looks like an URL, then would be
      # safe to assume that the request was processed correctly
      unless response.body.start_with? "http://", "https://"
        raise InvalidRequestError.new(response.body)
      end
      response.body
    end
  end
end
