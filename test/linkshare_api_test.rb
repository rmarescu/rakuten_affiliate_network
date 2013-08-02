require "test_helper"

class LinkshareAPITest < Test::Unit::TestCase
  def test_link_generator_invalid_token
    LinkshareAPI.token = nil
    assert_raise LinkshareAPI::AuthenticationError do
      LinkshareAPI.link_generator(123, "http://www.example.com")
    end
  end

  def test_link_generator_invalid_timeout
    assert_raise ArgumentError do
      LinkshareAPI.api_timeout = ""
    end

    assert_raise ArgumentError do
      LinkshareAPI.api_timeout = "20"
    end

    assert_raise ArgumentError do
      LinkshareAPI.api_timeout = 0
    end
  end

  def test_link_generator_invalid_mid
    LinkshareAPI.token = "token"
    assert_raise ArgumentError do
      LinkshareAPI.link_generator(nil, nil)
    end
  end

  def test_link_generator_missing_url
    LinkshareAPI.token = "your_token"
    stub_request(
      :get,
      "http://getdeeplink.linksynergy.com/createcustomlink.shtml?token=your_token&mid=123&murl="
      ).
      to_return(
        status: 200,
        body: "No Advertiser URL provided for deep linking. This could be because murl was not found or was empty.",
        headers: {}
    )
    e = assert_raise LinkshareAPI::InvalidRequestError do
      LinkshareAPI.link_generator(123, nil)
    end
    assert_equal "No Advertiser URL provided for deep linking. This could be because murl was not found or was empty.", e.to_s
  end

  def test_link_generator_valid_request
    LinkshareAPI.token = "your_token"
    mid = 2149
    murl = "http://www.walmart.com/cp/blu-ray/616859?povid=P1171-C1110.2784+1455.2776+1115.2956-L44"
    stub_request(
      :get,
      "http://getdeeplink.linksynergy.com/createcustomlink.shtml?token=your_token&mid=#{mid}&murl=#{murl}"
      ).
      to_return(
        status: 200,
        body: "http://linksynergy.walmart.com/fs-bin/click?id=yourid&subid=0&offerid=223073.1&type=10&tmpid=273&RD_PARM0=http%3A%2F%2Fwww.walmart.com%2Fcp%2Fblu-ray%2F616859%3Fpovid%3DP1171-C1110.2784%2B1455.2776%2B1115.2956-L44&RD_PARM1=http%3A%2F%2Fwww.walmart.com%2Fcp%2Fblu-ray%2F616859%3F&RD_PARM2=povid%3DP1171-C1110.2784%2B1455.2776%2B1115.2956-L44",
        headers: {}
    )
    url = LinkshareAPI.link_generator(mid, murl)
    assert_equal "http://linksynergy.walmart.com/fs-bin/click?id=yourid&subid=0&offerid=223073.1&type=10&tmpid=273&RD_PARM0=http%3A%2F%2Fwww.walmart.com%2Fcp%2Fblu-ray%2F616859%3Fpovid%3DP1171-C1110.2784%2B1455.2776%2B1115.2956-L44&RD_PARM1=http%3A%2F%2Fwww.walmart.com%2Fcp%2Fblu-ray%2F616859%3F&RD_PARM2=povid%3DP1171-C1110.2784%2B1455.2776%2B1115.2956-L44", url
  end
end
