require "test_helper"

class LinkshareCouponAPITest < Test::Unit::TestCase
  def test_coupon_web_service_invalid_token
    LinkshareAPI.token = nil
    assert_raise LinkshareAPI::AuthenticationError do
      LinkshareAPI.coupon_web_service(network: 1, mid: 38605)
    end
  end

  def test_coupon_web_service_internal_error
    LinkshareAPI.token = token
    xml_response = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
        <fault>
          <errorcode>10</errorcode>
          <errorstring>Internal Error Unable To Process Request At This Time</errorstring>
        </fault>
    XML
    stub_request(
      :get,
      "http://couponfeed.linksynergy.com/coupon?network=1&token=#{token}"
      ).
      to_return(
        status: 200,
        body: xml_response,
        headers: { "Content-type" => "text/xml; charset=UTF-8" }
    )
    e = assert_raise LinkshareAPI::InvalidRequestError do
      LinkshareAPI.coupon_web_service(network: 1)
    end
    assert_equal 10, e.code
    assert_equal "Internal Error Unable To Process Request At This Time", e.message
  end

  def test_coupon_web_service_usage_limited
    LinkshareAPI.token = token
    xml_response = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
        <fault>
          <errorcode>30</errorcode>
          <errorstring>Usage Quota Exceeded</errorstring>
        </fault>
    XML
    stub_request(
      :get,
      "http://couponfeed.linksynergy.com/coupon?network=1&token=#{token}"
      ).
      to_return(
        status: 200,
        body: xml_response,
        headers: { "Content-type" => "text/xml; charset=UTF-8" }
    )
    e = assert_raise LinkshareAPI::InvalidRequestError do
      LinkshareAPI.coupon_web_service(network: 1)
    end
    assert_equal 30, e.code
    assert_equal "Usage Quota Exceeded", e.message
  end

  def test_coupon_web_service_invalid_or_missing_parameters
    LinkshareAPI.token = token
    xml_response = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
        <fault>
          <errorcode>40</errorcode>
          <errorstring>Invalid Request</errorstring>
        </fault>
    XML
    stub_request(
      :get,
      "http://couponfeed.linksynergy.com/coupon?network=15&token=#{token}"
      ).
      to_return(
        status: 200,
        body: xml_response,
        headers: { "Content-type" => "text/xml; charset=UTF-8" }
    )
    e = assert_raise LinkshareAPI::InvalidRequestError do
      LinkshareAPI.coupon_web_service(network: 15)
    end
    assert_equal 40, e.code
    assert_equal "Invalid Request", e.message
  end

  def test_coupon_web_service_invalid_or_not_approved_token
    LinkshareAPI.token = token
    xml_response = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
        <fault>
          <errorcode>20</errorcode>
          <errorstring>Access Denied Token ID Is Invalid or Not Approved for Coupon Feed</errorstring>
        </fault>
    XML
    stub_request(
      :get,
      "http://couponfeed.linksynergy.com/coupon?network=15&token=#{token}"
      ).
      to_return(
        status: 200,
        body: xml_response,
        headers: { "Content-type" => "text/xml; charset=UTF-8" }
    )
    e = assert_raise LinkshareAPI::InvalidRequestError do
      LinkshareAPI.coupon_web_service(network: 15)
    end
    assert_equal 20, e.code
    assert_equal "Access Denied Token ID Is Invalid or Not Approved for Coupon Feed", e.message
  end

  def test_coupon_web_service_with_no_results
    LinkshareAPI.token = token
    xml_response = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
        <couponfeed>
          <TotalMatches>0</TotalMatches>
          <TotalPages>0</TotalPages>
          <PageNumberRequested>1</PageNumberRequested>
        </couponfeed>
    XML
    stub_request(
      :get,
      "http://couponfeed.linksynergy.com/coupon?network=1&promotiontype=30&token=#{token}"
      ).
      to_return(
        status: 200,
        body: xml_response,
        headers: { "Content-type" => "text/xml; charset=UTF-8" }
    )
    response = LinkshareAPI.coupon_web_service(network: 1, promotiontype: 30)
    assert_equal 0, response.total_matches
    assert_equal 0, response.total_pages
    assert_equal 1, response.page_number
    assert_equal [], response.data
  end

  def test_with_valid_results
    LinkshareAPI.token = token
    xml_response = <<-XML.strip
      <?xml version="1.0" encoding="UTF-8"?>
        <couponfeed>
          <TotalMatches>1</TotalMatches>
          <TotalPages>1</TotalPages>
          <PageNumberRequested>1</PageNumberRequested>
        <link type="TEXT">
          <categories>
            <category id="983">computers</category>
            <category id="12">electronics</category>
            <category id="14">gifts</category>
          </categories>
          <promotiontypes>
            <promotiontype id="22">percentage off</promotiontype>
          </promotiontypes>
          <offerdescription>15 percent off</offerdescription>
          <offerstartdate>2009-04-01</offerstartdate>
          <offerenddate>2009-05-31</offerenddate>
          <couponcode>KJEISLD</couponcode>
          <couponrestriction>New Customers Only</couponrestriction>
          <clickurl>http://click.linksynergy.com/fs-bin/click?id=XXXXXXXXXXX&amp;offerid=164317.10002595&amp;type=4&amp;subid=0</clickurl>
          <impressionpixel>http://ad.linksynergy.com/fs-bin/show?id=XXXXXXXXXXX&amp;bids=164317.10002595&amp;type=4&amp;subid=0</impressionpixel>
          <advertiserid>000</advertiserid>
          <advertisername>Sample Advertiser Name</advertisername>
          <network id="1">Linkshare Network</network>
        </link>
        <link type="TEXT">
          <categories>
            <category id="983">computers</category>
            <category id="12">electronics</category>
            <category id="14">gifts</category>
          </categories>
          <promotiontypes>
            <promotiontype id="22">percentage off</promotiontype>
          </promotiontypes>
          <offerdescription>10 percent off</offerdescription>
          <offerstartdate>2009-04-01</offerstartdate>
          <offerenddate>2009-05-31</offerenddate>
          <couponcode>KJEISLD</couponcode>
          <couponrestriction>New Customers Only</couponrestriction>
          <clickurl>http://click.linksynergy.com/fs-bin/click?id=XXXXXXXXXXX&amp;offerid=164317.10002595&amp;type=4&amp;subid=0</clickurl>
          <impressionpixel>http://ad.linksynergy.com/fs-bin/show?id=XXXXXXXXXXX&amp;bids=164317.10002595&amp;type=4&amp;subid=0</impressionpixel>
          <advertiserid>000</advertiserid>
          <advertisername>Sample Advertiser Name</advertisername>
          <network id="1">Linkshare Network</network>
        </link>
        </couponfeed>
    XML
    stub_request(
      :get,
      "http://couponfeed.linksynergy.com/coupon?network=1&promotiontype=22&token=#{token}"
      ).
      to_return(
        status: 200,
        body: xml_response,
        headers: { "Content-type" => "text/xml; charset=UTF-8" }
    )

    response = LinkshareAPI.coupon_web_service(network: 1, promotiontype: 22)
    assert_equal 1, response.total_matches
    assert_equal 1, response.total_pages
    assert_equal 1, response.page_number
    assert_equal "KJEISLD", response.data.first.couponcode
    assert_equal "10 percent off", response.data.last.offerdescription
  end

  def test_all_with_valid_results
    LinkshareAPI.token = token
    xml_response1 = <<-XML.strip
      <?xml version="1.0" encoding="UTF-8"?>
        <couponfeed>
          <TotalMatches>6</TotalMatches>
          <TotalPages>3</TotalPages>
          <PageNumberRequested>1</PageNumberRequested>
        <link type="TEXT">
          <categories>
            <category id="983">computers</category>
            <category id="12">electronics</category>
            <category id="14">gifts</category>
          </categories>
          <promotiontypes>
            <promotiontype id="22">percentage off</promotiontype>
          </promotiontypes>
          <offerdescription>15 percent off</offerdescription>
          <offerstartdate>2009-04-01</offerstartdate>
          <offerenddate>2009-05-31</offerenddate>
          <couponcode>KJEISLD</couponcode>
          <couponrestriction>New Customers Only</couponrestriction>
          <clickurl>http://click.linksynergy.com/fs-bin/click?id=XXXXXXXXXXX&amp;offerid=164317.10002595&amp;type=4&amp;subid=0</clickurl>
          <impressionpixel>http://ad.linksynergy.com/fs-bin/show?id=XXXXXXXXXXX&amp;bids=164317.10002595&amp;type=4&amp;subid=0</impressionpixel>
          <advertiserid>000</advertiserid>
          <advertisername>Sample Advertiser Name</advertisername>
          <network id="1">Linkshare Network</network>
        </link>
        <link type="TEXT">
          <categories>
            <category id="983">computers</category>
            <category id="12">electronics</category>
            <category id="14">gifts</category>
          </categories>
          <promotiontypes>
            <promotiontype id="22">percentage off</promotiontype>
          </promotiontypes>
          <offerdescription>10 percent off</offerdescription>
          <offerstartdate>2009-04-01</offerstartdate>
          <offerenddate>2009-05-31</offerenddate>
          <couponcode>KJEISLD</couponcode>
          <couponrestriction>New Customers Only</couponrestriction>
          <clickurl>http://click.linksynergy.com/fs-bin/click?id=XXXXXXXXXXX&amp;offerid=164317.10002595&amp;type=4&amp;subid=0</clickurl>
          <impressionpixel>http://ad.linksynergy.com/fs-bin/show?id=XXXXXXXXXXX&amp;bids=164317.10002595&amp;type=4&amp;subid=0</impressionpixel>
          <advertiserid>000</advertiserid>
          <advertisername>Sample Advertiser Name</advertisername>
          <network id="1">Linkshare Network</network>
        </link>
        </couponfeed>
    XML
    xml_response2 = <<-XML.strip
      <?xml version="1.0" encoding="UTF-8"?>
        <couponfeed>
          <TotalMatches>6</TotalMatches>
          <TotalPages>3</TotalPages>
          <PageNumberRequested>2</PageNumberRequested>
        <link type="TEXT">
          <categories>
            <category id="983">computers</category>
            <category id="12">electronics</category>
            <category id="14">gifts</category>
          </categories>
          <promotiontypes>
            <promotiontype id="22">percentage off</promotiontype>
          </promotiontypes>
          <offerdescription>15 percent off</offerdescription>
          <offerstartdate>2009-04-01</offerstartdate>
          <offerenddate>2009-05-31</offerenddate>
          <couponcode>KJEISLD</couponcode>
          <couponrestriction>New Customers Only</couponrestriction>
          <clickurl>http://click.linksynergy.com/fs-bin/click?id=XXXXXXXXXXX&amp;offerid=164317.10002595&amp;type=4&amp;subid=0</clickurl>
          <impressionpixel>http://ad.linksynergy.com/fs-bin/show?id=XXXXXXXXXXX&amp;bids=164317.10002595&amp;type=4&amp;subid=0</impressionpixel>
          <advertiserid>000</advertiserid>
          <advertisername>Sample Advertiser Name</advertisername>
          <network id="1">Linkshare Network</network>
        </link>
        <link type="TEXT">
          <categories>
            <category id="983">computers</category>
            <category id="12">electronics</category>
            <category id="14">gifts</category>
          </categories>
          <promotiontypes>
            <promotiontype id="22">percentage off</promotiontype>
          </promotiontypes>
          <offerdescription>10 percent off</offerdescription>
          <offerstartdate>2009-04-01</offerstartdate>
          <offerenddate>2009-05-31</offerenddate>
          <couponcode>KJEISLD</couponcode>
          <couponrestriction>New Customers Only</couponrestriction>
          <clickurl>http://click.linksynergy.com/fs-bin/click?id=XXXXXXXXXXX&amp;offerid=164317.10002595&amp;type=4&amp;subid=0</clickurl>
          <impressionpixel>http://ad.linksynergy.com/fs-bin/show?id=XXXXXXXXXXX&amp;bids=164317.10002595&amp;type=4&amp;subid=0</impressionpixel>
          <advertiserid>000</advertiserid>
          <advertisername>Sample Advertiser Name</advertisername>
          <network id="1">Linkshare Network</network>
        </link>
        </couponfeed>
    XML
    xml_response3 = <<-XML.strip
      <?xml version="1.0" encoding="UTF-8"?>
        <couponfeed>
          <TotalMatches>6</TotalMatches>
          <TotalPages>3</TotalPages>
          <PageNumberRequested>3</PageNumberRequested>
        <link type="TEXT">
          <categories>
            <category id="983">computers</category>
            <category id="12">electronics</category>
            <category id="14">gifts</category>
          </categories>
          <promotiontypes>
            <promotiontype id="22">percentage off</promotiontype>
          </promotiontypes>
          <offerdescription>15 percent off</offerdescription>
          <offerstartdate>2009-04-01</offerstartdate>
          <offerenddate>2009-05-31</offerenddate>
          <couponcode>KJEISLD</couponcode>
          <couponrestriction>New Customers Only</couponrestriction>
          <clickurl>http://click.linksynergy.com/fs-bin/click?id=XXXXXXXXXXX&amp;offerid=164317.10002595&amp;type=4&amp;subid=0</clickurl>
          <impressionpixel>http://ad.linksynergy.com/fs-bin/show?id=XXXXXXXXXXX&amp;bids=164317.10002595&amp;type=4&amp;subid=0</impressionpixel>
          <advertiserid>000</advertiserid>
          <advertisername>Sample Advertiser Name</advertisername>
          <network id="1">Linkshare Network</network>
        </link>
        <link type="TEXT">
          <categories>
            <category id="983">computers</category>
            <category id="12">electronics</category>
            <category id="14">gifts</category>
          </categories>
          <promotiontypes>
            <promotiontype id="22">percentage off</promotiontype>
          </promotiontypes>
          <offerdescription>10 percent off</offerdescription>
          <offerstartdate>2009-04-01</offerstartdate>
          <offerenddate>2009-05-31</offerenddate>
          <couponcode>KIRK</couponcode>
          <couponrestriction>New Customers Only</couponrestriction>
          <clickurl>http://click.linksynergy.com/fs-bin/click?id=XXXXXXXXXXX&amp;offerid=164317.10002595&amp;type=4&amp;subid=0</clickurl>
          <impressionpixel>http://ad.linksynergy.com/fs-bin/show?id=XXXXXXXXXXX&amp;bids=164317.10002595&amp;type=4&amp;subid=0</impressionpixel>
          <advertiserid>000</advertiserid>
          <advertisername>Sample Advertiser Name</advertisername>
          <network id="1">Linkshare Network</network>
        </link>
        </couponfeed>
    XML
    stub_request(
      :get,
      "http://couponfeed.linksynergy.com/coupon?network=1&promotiontype=22&token=#{token}"
      ).
      to_return(
        status: 200,
        body: xml_response1,
        headers: { "Content-type" => "text/xml; charset=UTF-8" }
    )
    stub_request(
      :get,
      "http://couponfeed.linksynergy.com/coupon?network=1&promotiontype=22&pagenumber=2&token=#{token}"
      ).
      to_return(
        status: 200,
        body: xml_response2,
        headers: { "Content-type" => "text/xml; charset=UTF-8" }
    )
    stub_request(
      :get,
      "http://couponfeed.linksynergy.com/coupon?network=1&promotiontype=22&pagenumber=3&token=#{token}"
      ).
      to_return(
        status: 200,
        body: xml_response3,
        headers: { "Content-type" => "text/xml; charset=UTF-8" }
    )

    data = LinkshareAPI.coupon_web_service(network: 1, promotiontype: 22).all
    assert_equal "KJEISLD", data.first.couponcode
    assert_equal "KIRK", data.last.couponcode

  end

  private

  def token
    "abcdef"
  end

end
 
