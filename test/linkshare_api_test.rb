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
    LinkshareAPI.token = token
    assert_raise ArgumentError do
      LinkshareAPI.link_generator(nil, nil)
    end
  end

  def test_link_generator_missing_url
    LinkshareAPI.token = token
    stub_request(
      :get,
      "http://getdeeplink.linksynergy.com/createcustomlink.shtml?token=#{token}&mid=123&murl="
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
    LinkshareAPI.token = token
    mid = 2149
    murl = "http://www.walmart.com/cp/blu-ray/616859?povid=P1171-C1110.2784+1455.2776+1115.2956-L44"
    stub_request(
      :get,
      "http://getdeeplink.linksynergy.com/createcustomlink.shtml?token=#{token}&mid=#{mid}&murl=#{murl}"
      ).
      to_return(
        status: 200,
        body: "http://linksynergy.walmart.com/fs-bin/click?id=yourid&subid=0&offerid=223073.1&type=10&tmpid=273&RD_PARM0=http%3A%2F%2Fwww.walmart.com%2Fcp%2Fblu-ray%2F616859%3Fpovid%3DP1171-C1110.2784%2B1455.2776%2B1115.2956-L44&RD_PARM1=http%3A%2F%2Fwww.walmart.com%2Fcp%2Fblu-ray%2F616859%3F&RD_PARM2=povid%3DP1171-C1110.2784%2B1455.2776%2B1115.2956-L44",
        headers: {}
    )
    url = LinkshareAPI.link_generator(mid, murl)
    assert_equal "http://linksynergy.walmart.com/fs-bin/click?id=yourid&subid=0&offerid=223073.1&type=10&tmpid=273&RD_PARM0=http%3A%2F%2Fwww.walmart.com%2Fcp%2Fblu-ray%2F616859%3Fpovid%3DP1171-C1110.2784%2B1455.2776%2B1115.2956-L44&RD_PARM1=http%3A%2F%2Fwww.walmart.com%2Fcp%2Fblu-ray%2F616859%3F&RD_PARM2=povid%3DP1171-C1110.2784%2B1455.2776%2B1115.2956-L44", url
  end

  def test_product_search_invalid_token
    LinkshareAPI.token = nil
    assert_raise LinkshareAPI::AuthenticationError do
      LinkshareAPI.product_search(keyword: "laptop")
    end
  end

  def test_product_search_invalid_argument
    LinkshareAPI.token = "token"
    assert_raise ArgumentError do
      LinkshareAPI.product_search("foo")
    end
  end

  def test_product_search_invalid_response_code
    LinkshareAPI.token = token
    stub_request(
      :get,
      "http://productsearch.linksynergy.com/productsearch?keyword=%26%26&token=#{token}"
      ).
      to_return(
        status: [500, "Internal Server Error"],
        body: "",
        headers: {}
    )
    e = assert_raise LinkshareAPI::Error do
      LinkshareAPI.product_search(keyword: "&&")
    end
    assert_equal 500, e.code
    assert_equal "Internal Server Error", e.message
  end

  def test_product_search_invalid_request
    LinkshareAPI.token = token
    xml_response = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      <result><Errors><ErrorID>718615</ErrorID><ErrorText>No keyword specified.</ErrorText></Errors></result>
    XML
    stub_request(
      :get,
      "http://productsearch.linksynergy.com/productsearch?keyword=%26%26&token=#{token}"
      ).
      to_return(
        status: 200,
        body: xml_response,
        headers: { "Content-type" => "text/xml; charset=UTF-8" }
    )
    e = assert_raise LinkshareAPI::InvalidRequestError do
      LinkshareAPI.product_search(keyword: "&&")
    end
    assert_equal 718615, e.code
    assert_equal "No keyword specified.", e.message
  end

  def test_product_search_no_results
    LinkshareAPI.token = token
    xml_response = <<-XML.strip
      <?xml version="1.0" encoding="UTF-8"?>
      <result><TotalMatches>0</TotalMatches><TotalPages>0</TotalPages><PageNumber>1</PageNumber></result>
    XML
    keyword = "weird_keyword_with_no_results"
    stub_request(
      :get,
      "http://productsearch.linksynergy.com/productsearch?keyword=#{keyword}&token=#{token}"
      ).
      to_return(
        status: 200,
        body: xml_response,
        headers: { "Content-type" => "text/xml; charset=UTF-8" }
    )
    response = LinkshareAPI.product_search(keyword: keyword)
    assert_equal 0, response.total_matches
    assert_equal 0, response.total_pages
    assert_equal 1, response.page_number
    assert_equal [], response.data
  end

  def test_product_search_valid_response
    LinkshareAPI.token = token
    xml_response = <<-XML.strip
      <?xml version="1.0" encoding="UTF-8"?>
      <result><TotalMatches>2</TotalMatches><TotalPages>1</TotalPages><PageNumber>1</PageNumber><item><mid>36342</mid><merchantname>Buy.com</merchantname><linkid>250754125</linkid><createdon>2013-07-13/16:15:14</createdon><sku>250754125</sku><productname> Dell Inspiron 17R-5720, Core i5- 2.5GHz, 8GB/1TB, 17.3 , Webcam, Bluetooth, 1Y Warranty ; Lotus Pink Edition </productname><category><primary> Computers~~Computer Systems </primary><secondary>   </secondary></category><price currency="USD">629.99</price><upccode>00621988902522</upccode><description><short>Enjoy HD movies on this expansive 17 laptop with bold color options, HD+ display, Intel Core i5 processor, and more storage space for all your multimedia. From movie night to family finances, everyones priorities are easier to tackle with the 3rd Gen Intel Core i5 processor, Windows 8, 8GB of memory and 1TB hard drive capacity. Support new technologies like USB 3.0, higher performance and Intel HD graphics for your everyday computing needs with power to grow with you in the future.</short><long>Enjoy HD movies on this expansive 17 laptop with bold color options, HD+ display, Intel Core i5 processor, and more storage space for all your multimedia. From movie night to family finances, everyones priorities are easier to tackle with the 3rd Gen Intel Core i5 processor, Windows 8, 8GB of memory and 1TB hard drive capacity. Support new technologies like USB 3.0, higher performance and Intel HD graphics for your everyday computing needs with power to grow with you in the future. Watch your movies, games, and streaming video go from fast to blazing fast with up to 8GB of fast, efficient DDR3 SDRAM at 1600MHz. Make the Inspiron 17R your communications hub. Connecting with friends and family has never been easier, thanks to a robust WiFi connection and built-in HD webcam, over five hours of battery life, and a 17.3 screen that brings you face-to-face with friends and family. The Inspiron 17Rs 17.3 Truelife screen brings whatever you are watching to life, wherever you go. Plus, take your entertainment from cool to whoa by connecting to an external HDMI-capable TV or monitor via the available HDMI v1.4a port. You may never need to buy a movie ticket again. The 17.3 Truelife display makes your photos, videos, movies and other onscreen images pop. Treat your eyes to an intense visual experience wherever you go. Peace of mind comes standard with every Inspiron 17R.</long></description><saleprice currency="USD">629.99</saleprice><keywords/><linkurl>http://affiliate.rakuten.com/link?id=yourid&amp;offerid=272843.250754125&amp;type=15&amp;murl=http%3A%2F%2Fnotebookavenue.store.buy.com%2Fp%2Fdell-inspiron-17r-5720-core-i5-2-5ghz-8gb-1tb-17-3-webcam-bluetooth-1y%2F250754125.html</linkurl><imageurl>http://images.rakuten.com/PI/0/1000/250754125.jpg</imageurl></item><item><mid>36342</mid><merchantname>Buy.com</merchantname><linkid>250993173</linkid><createdon>2013-07-06/19:57:35</createdon><sku>250993173</sku><productname> Dell Inspiron 17R-5720, Core i7 -3612QM- 2.1GHz, 8GB/1TB, 17.3 , Webcam, Bluetooth, 1 Year Warranty ; Lotus Pink Edition </productname><category><primary> Computers~~Computer Systems </primary><secondary>   </secondary></category><price currency="USD">729.99</price><upccode>00022367227517</upccode><description><short>Enjoy HD movies on this expansive 17 laptop with bold color options, HD+ display, Intel Core i7 processor, and more storage space for all your multimedia. From movie night to family finances, everyones priorities are easier to tackle with the 3rd Gen Intel Core i7 processor, Windows 7, 8GB of memory and 1TB hard drive capacity. Support new technologies like USB 3.0, higher performance and Intel HD graphics for your everyday computing needs with power to grow with you in the future.</short><long>Enjoy HD movies on this expansive 17 laptop with bold color options, HD+ display, Intel Core i7 processor, and more storage space for all your multimedia. From movie night to family finances, everyones priorities are easier to tackle with the 3rd Gen Intel Core i7 processor, Windows 7, 8GB of memory and 1TB hard drive capacity. Support new technologies like USB 3.0, higher performance and Intel HD graphics for your everyday computing needs with power to grow with you in the future. Watch your movies, games, and streaming video go from fast to blazing fast with up to 8GB of fast, efficient DDR3 SDRAM at 1600MHz. Make the Inspiron 17R your communications hub. Connecting with friends and family has never been easier, thanks to a robust WiFi connection and built-in HD webcam, over five hours of battery life, and a 17.3 screen that brings you face-to-face with friends and family. The Inspiron 17Rs 17.3 Truelife screen brings whatever you are watching to life, wherever you go. Plus, take your entertainment from cool to whoa by connecting to an external HDMI-capable TV or monitor via the available HDMI v1.4a port. You may never need to buy a movie ticket again. The 17.3 Truelife display makes your photos, videos, movies and other onscreen images pop. Treat your eyes to an intense visual experience wherever you go. Peace of mind comes standard with every Inspiron 17R.</long></description><saleprice currency="USD">729.99</saleprice><keywords/><linkurl>http://affiliate.rakuten.com/link?id=yourid&amp;offerid=272843.250993173&amp;type=15&amp;murl=http%3A%2F%2Fnotebookavenue.store.buy.com%2Fp%2Fdell-inspiron-17r-5720-core-i7-3612qm-2-1ghz-8gb-1tb-17-3-webcam%2F250993173.html</linkurl><imageurl>http://img.rakuten.com/PIC/53838093/0/1/250/53838093.jpg</imageurl></item></result>
    XML
    keyword = "weird_keyword_with_no_results"
    stub_request(
      :get,
      "http://productsearch.linksynergy.com/productsearch?keyword=#{keyword}&token=#{token}"
      ).
      to_return(
        status: 200,
        body: xml_response,
        headers: { "Content-type" => "text/xml; charset=UTF-8" }
    )
    response = LinkshareAPI.product_search(keyword: keyword)
    assert_equal 2, response.total_matches
    assert_equal 1, response.total_pages
    assert_equal 1, response.page_number
    assert_equal 2, response.data.count
    assert_equal "250754125", response.data.first.sku
    assert_equal "729.99", response.data.last.saleprice.__content__
  end

  def test_product_search_all_results
    LinkshareAPI.token = token
    keyword = "intel laptop"
    options = {
      keyword: keyword,
      max: 3
    }
    xml_response_1 = <<-XML.strip
      <?xml version="1.0" encoding="UTF-8"?>
      <result><TotalMatches>7</TotalMatches><TotalPages>3</TotalPages><PageNumber>1</PageNumber><item><mid>36342</mid><merchantname>Buy.com</merchantname><linkid>250014339</linkid><createdon>2013-07-19/16:21:04</createdon><sku>250014339</sku><productname> HP Envy 17-J020US E0K82UA 17.3 LED Notebook - Intel Core i7 i7-4700MQ - Natural Silver - 8 GB RAM - 1 TB HDD - DVD-Writer - Genuine Windows 8 64-bit - 1600 x 900 Display - Bluetooth </productname><category><primary> Computers~~Computer Systems </primary><secondary>   </secondary></category><price currency="USD">1044.44</price><upccode>00887758488485</upccode><description><short>In a class by itself. Elevate your expectations. Every ENVY laptop is crafted to surpass them with the finest features and powerful technology that deliver premium entertainment and computing experience.</short><long>In a class by itself. Elevate your expectations. Every ENVY laptop is crafted to surpass them with the finest features and powerful technology that deliver premium entertainment and computing experience.</long></description><saleprice currency="USD">1044.44</saleprice><keywords/><linkurl>http://affiliate.rakuten.com/link?id=yourid&amp;offerid=272843.250014339&amp;type=15&amp;murl=http%3A%2F%2Fantonline.store.buy.com%2Fp%2Fhp-envy-17-j020us-e0k82ua-17-3-led-notebook-intel-core-i7-i7-4700mq%2F250014339.html</linkurl><imageurl>http://img.rakuten.com/PIC/55207010/0/1/250/55207010.jpg</imageurl></item><item><mid>36342</mid><merchantname>Buy.com</merchantname><linkid>247569811</linkid><createdon>2013-08-11/20:22:31</createdon><sku>247569811</sku><productname> Lenovo ThinkPad W530 243857U 15.6 LED Notebook - Intel - Core i7 i7-3740QM 2.7GHz - 4 GB RAM - 500 GB HDD - DVD-Writer - NVIDIA Quadro K2000M, Intel HD 4000 Graphics - Genuine Windows 7 Professional 64-bit - 1920 x 1080 Display - Bluetooth </productname><category><primary> Computers~~Computer Systems </primary><secondary>   </secondary></category><price currency="USD">1699</price><upccode>00887770534832</upccode><description><short>BRILLIANT BUSINESS LAPTOPS.Rock-solid reliability. Blazing-fast performance. Clever manageability tools. We pack a lot of intelligent features into every ThinkPad laptop, tablet, and Ultrabook so you get more out. More productivity, more cost savings, more IT headache-busting. That's why a ThinkPad investment isn't just smart. It's pure genius.</short><long>BRILLIANT BUSINESS LAPTOPS.Rock-solid reliability. Blazing-fast performance. Clever manageability tools. We pack a lot of intelligent features into every ThinkPad laptop, tablet, and Ultrabook so you get more out. More productivity, more cost savings, more IT headache-busting. That's why a ThinkPad investment isn't just smart. It's pure genius.</long></description><saleprice currency="USD">1659.99</saleprice><keywords/><linkurl>http://affiliate.rakuten.com/link?id=yourid&amp;offerid=272843.247569811&amp;type=15&amp;murl=http%3A%2F%2Fwww.rakuten.com%2Fprod%2Flenovo-thinkpad-w530-243857u-15-6-led-notebook-intel-core-i7-i7-3740qm%2F247569811.html</linkurl><imageurl>http://img.rakuten.com/PIC/41096678/0/1/250/41096678.jpg</imageurl></item><item><mid>36342</mid><merchantname>Buy.com</merchantname><linkid>227830151</linkid><createdon>2012-04-27/04:16:52</createdon><sku>227830151</sku><productname> Intel 520 Series 180GB 2.5 SATA III Solid State Drive </productname><category><primary> Computers~~Storage Devices </primary><secondary>   </secondary></category><price currency="USD">218.99</price><upccode>00735858224369</upccode><description><short>GET FAST. PLAY FIERCE.Faster game and application loads, less lag, smoother visuals.Stay ahead of the competition when you level up to 6.0 gigabits per second (Gb/s) performance. Cherryville Solid-State Drives (SSDs) continue to evolve with the Intel SSD 500 Faily.</short><long>GET FAST. PLAY FIERCE.Faster game and application loads, less lag, smoother visuals.Stay ahead of the competition when you level up to 6.0 gigabits per second (Gb/s) performance. Cherryville Solid-State Drives (SSDs) continue to evolve with the Intel SSD 500 Faily. Available in a wide range of capacities, Cherryville SSDs offer built-in data protection features and delivers exceptional performance over hard drives.New Level of PerformanceBuilt with compute-quality Intel 25 nanometer (nm) NAND Flash Memory, Cherryville SSDs accelerate PC performance where it matters most. With random read performance up to 50,000 input/output operations per second (IOPS)1 and sequential read performance of up to 550 megabytes per second (MB/s), your PC will blaze through the most demanding applications and will handle intense multi-tasking needs. Couple that read performance with random writes up to 80,000 IOPS and sequential writes of 520 MB/s to unleash your applications. With Cherryville SSDs, Intel continues to deliver solutions designed to satisfy the most demanding gamers, media creators and technology enthusiasts.Superior Data Protection FeaturesThe new Cherryville SSDs offer the best security features of any Intel Solid-State Drive to date and comes pre-configured with Advanced Encryption Standard (AES) 256-bit encryption capabilities. In the event of theft or loss of your computer, you have the peace of mind that your personal data is secured by an advanced encryption technology.Additionally, the Cherryville SSDs contain End to End Data Protection ensuring integrity of stored data from the computer to the SSD and back.Proven Reliability with Lower Operating CostsWith no moving parts, the Cherryville SSDs reduce your risk of data loss due to laptop bumps or drop, all while consuming less power than a traditional hard drive so you can stay mobile longer. Now that your work is safe, use the world-class performance</long></description><saleprice currency="USD">218.99</saleprice><keywords/><linkurl>http://affiliate.rakuten.com/link?id=yourid&amp;offerid=272843.227830151&amp;type=15&amp;murl=http%3A%2F%2Fbruc-computers.store.buy.com%2Fp%2Fintel-520-series-180gb-2-5-sata-iii-solid-state-drive%2F227830151.html</linkurl><imageurl>http://img.rakuten.com/PIC/52297706/0/1/250/52297706.jpg</imageurl></item></result>
    XML
    xml_response_2 = <<-XML.strip
      <?xml version="1.0" encoding="UTF-8"?>
      <result><TotalMatches>7</TotalMatches><TotalPages>3</TotalPages><PageNumber>2</PageNumber><item><mid>36699</mid><merchantname>Expansys</merchantname><linkid>226002</linkid><createdon>2011-11-17/16:35:22</createdon><sku>226002</sku><productname> Samsung Series 7 Slate PC (1.6GHz, 4GB RAM, 64GB SSD, Windows 7) </productname><category><primary> Windows 8 </primary><secondary>   </secondary></category><price currency="CAD">1189.99</price><upccode/><description><short>The Windows 7 OS allows you to run all your favorite office software. You can share documents with co-workers without any compatibility issues. And our Samsung touch interface gives you easy, instant access to all your programs. Exclusive Fast Start Technology When inspiration hits, make sure you have a laptop that can keep up. With Samsung's exclusive Fast Start technology, close the lid to enter a hybrid sleep mode, then simply open it to be up and running again in as little as two seconds....</short><long>The Windows 7 OS allows you to run all your favorite office software. You can share documents with co-workers without any compatibility issues. And our Samsung touch interface gives you easy, instant access to all your programs. Exclusive Fast Start Technology When inspiration hits, make sure you have a laptop that can keep up. With Samsung's exclusive Fast Start technology, close the lid to enter a hybrid sleep mode, then simply open it to be up and running again in as little as two seconds. A Full PC in a Sleek Form Factor Samsung Series 7 slate PCs offer the power and speed of a full-size PC, yet they're a mere half-inch thick and weigh less than a pound. They're an amazing marriage of power and design. 1366 x 768 WXGA Display - 4 GB RAM - 64 GB SSD - Intel HD 3000 Graphics Card - Bluetooth - Webcam - Genuine Windows 7 Home Premium - HDMI</long></description><saleprice currency="CAD">1189.99</saleprice><keywords/><linkurl>http://click.linksynergy.com/link?id=yourid&amp;offerid=223777.226002&amp;type=15&amp;murl=http%3A%2F%2Fwww.expansys.ca%2Fsamsung-series-7-slate-pc-226002%2F%3Futm_source%3Daffiliate%26utm_medium%3Dshopping%26utm_campaign%3Dlinkshare-ca</linkurl><imageurl>http://i1.expansys.com/img/l/226002/samsung-series-7-slate-pc.jpg</imageurl></item><item><mid>24572</mid><merchantname>Cascio Interstate Music</merchantname><linkid>10150425</linkid><createdon>2013-08-09/19:40:04</createdon><sku>893566</sku><productname> "Lenovo - 59371478 IdeaPad S500 Touch 15.6"" Multi-Touch Laptop" </productname><category><primary> New Product </primary><secondary>   </secondary></category><price currency="USD">599.99</price><upccode>887770679847</upccode><description><short>"IdeaPad S500 Touch:&amp;nbsp; Thin, Light and Affordable 15.6"" Multi-Touch Laptop. The IdeaPad S500 Touch laptop features a capacitive 10-point touchscreen in a slim, attractive design.&amp;nbsp; Backed by powerful Intel processor, long battery life, integrated Intel HD graphics and the comfortable AccuType keyboard, it delivers the smart performance of a laptop, while also providing the touch convenience of a tablet.&amp;nbsp; All at an affordable price.&amp;nbsp;&amp;nbsp; &amp;nbsp;Features:    10-Point Multi-touch Screen optimized for Windows 8    Less than 1&amp;rdquo; profile (.9&amp;rdquo;) with smooth cover    Stereo speakers and Dolby Advanced Audio v2    Comfortable, user-friendly AccuType keyboard    Integrated 720p HD webcam    Intelligent Touchpad with easy multi-gesture control    Integrated 802.11b/g/n WiFi    High-speed USB 3.0, USB 2.0, 2-in-1 card-reader and HDMI out    OneKey Recovery System makes data backup and recovery simple    Lenovo Energy Management minimizes power use and protects battery life"</short><long/></description><saleprice currency="USD">599.99</saleprice><keywords>"Lenovo S500 Touch 15.6&amp;quot; i3 4GB, Lenovo - 59371478 IdeaPad S500 Touch 15.6"" Multi-Touch Laptop, 59371478, LENOVO, 887770679847, Computers and Software, Laptops/Notebooks"</keywords><linkurl>http://click.linksynergy.com/link?id=yourid&amp;offerid=170159.10150425&amp;type=15&amp;murl=http%3A%2F%2Fwww.interstatemusic.com%2F893566-Lenovo-59371478-IdeaPad-S500-Touch-15-6-Multi-Touch-Laptop-59371478.aspx</linkurl><imageurl>http://az58332.vo.msecnd.net/e88dd2e9fff747f090c792316c22131c/Images/PersonalizedContentAreaRulesetContents31-300x90-1701471.jpg</imageurl></item><item><mid>36342</mid><merchantname>Buy.com</merchantname><linkid>246616304</linkid><createdon>2013-07-06/19:57:35</createdon><sku>246616304</sku><productname> Lenovo ThinkPad X220 42904E1 12.5 LED Notebook - Intel - Core i5 2.6GHz - Black - 4 GB RAM - 320 GB HDD - Genuine Windows 7 Professional 64-bit - 1366 x 768 Display - Bluetooth </productname><category><primary> Computers~~Computer Systems </primary><secondary>   </secondary></category><price currency="USD">712.32</price><upccode>00887619743586</upccode><description><short>BRILLIANT BUSINESS LAPTOPS. Rock-solid reliability. Blazing-fast performance. Clever manageability tools. We pack a lot of intelligent features into every ThinkPad laptop and tablet so you get more out. More productivity, more cost savings, more IT headache-busting. That's why a ThinkPad investment isn't just smart. It's pure genius.</short><long>BRILLIANT BUSINESS LAPTOPS. Rock-solid reliability. Blazing-fast performance. Clever manageability tools. We pack a lot of intelligent features into every ThinkPad laptop and tablet so you get more out. More productivity, more cost savings, more IT headache-busting. That's why a ThinkPad investment isn't just smart. It's pure genius.</long></description><saleprice currency="USD">712.32</saleprice><keywords/><linkurl>http://affiliate.rakuten.com/link?id=yourid&amp;offerid=272843.246616304&amp;type=15&amp;murl=http%3A%2F%2Ftechnology-galaxy.store.buy.com%2Fp%2Flenovo-thinkpad-x220-42904e1-12-5-led-notebook-intel-core-i5-2-6ghz%2F246616304.html</linkurl><imageurl>http://img.rakuten.com/PIC/39586835/0/1/250/39586835.jpg</imageurl></item></result>
    XML
    xml_response_3 = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      <result><TotalMatches>7</TotalMatches><TotalPages>3</TotalPages><PageNumber>3</PageNumber><item><mid>35825</mid><merchantname>DinoDirect China Ltd</merchantname><linkid>1221542</linkid><createdon>2012-10-26/10:25:50</createdon><sku>A0295000MA</sku><productname> 10.2-inch WIN7 Intel Atom 1.8GHz D2500 CPU 130MP Camera DDR3 RAM 2GB 160GB 1024*600 Microphone Notebook </productname><category><primary> Computers &amp; Networking </primary><secondary>  PC Laptops &amp; Netbooks ~~ Netbooks </secondary></category><price currency="USD">232.99</price><upccode/><description><short>10.2-inch WIN7 Intel Atom 1.8GHz D2500 CPU 130MP Camera DDR3 RAM 2GB 160GB 1024*600 Microphone Notebook allows users to easily view documents and WebPages.Built-in Windows 7 system and 1.8GHz D2500 CPU make the netbook laptop running fast and stable.It is ideal for business people on the go, students, children and home users. You can surf the internet, send emails, instant messaging, and study, and compose documents or other things with this 320GB notebook. What's more, the 2GB laptop adopts 1.8 GHz D2500 CPU to ensure the its running speed. Besides, the 160GB notebook is lightweight and compact which easily fits in a book bag or briefcase. High resolution 1024*600 laptop that you can enjoy the visual feast.</short><long/></description><saleprice currency="USD">232.99</saleprice><keywords/><linkurl>http://click.linksynergy.com/link?id=yourid&amp;offerid=265182.1221542&amp;type=15&amp;murl=http%3A%2F%2Fus.dinodirect.com%2Fnotebook-laptop-d2500-cpu-2gb-hdd-320gb-netbook-windows-7-notebook-ultrathin-laptop.html%3Fvn%3DRGlub2RpcmVjdEZ1Y2s%26AFFID%3D41</linkurl><imageurl>http://p.lefux.com/61/20120903/A0295000MA/notebook-laptop-d2500-cpu-2gb-hdd-320gb-netbook-windows-7-no-4610708-big.jpg</imageurl></item><item><mid>2149</mid><merchantname>Wal-Mart.com USA, LLC</merchantname><linkid>26002180</linkid><createdon>2013-08-04/03:41:45</createdon><sku>0088411612032</sku><productname> Dell Fire Red 15.6" Touchscreen Inspiron 15R Laptop PC with Intel Core i3-3227U Processor,  6GB Memory, 500GB Hard Drive and Windows 8 Home </productname><category><primary> Computers~~ </primary><secondary>  Electronics </secondary></category><price currency="USD">598</price><upccode>00884116120322</upccode><description><short>The Dell 15.6" Inspiron 15R Laptop PC features 6GB DDR3 SDRAM system memory to give you the power to handle most power-hungry applications and tons of multimedia work.</short><long>Dell 15.6" Inspiron 15R Laptop PC: Key Features and Benefits: Intel Core i3-3227U processor 1.9GHz, 3MB Cache 6GB DDR3 SDRAM system memory Gives you the power to handle most power-hungry applications and tons of multimedia work 500GB SATA hard drive Store 333,000 photos, 142,000 songs or 263 hours of HD video and more DVD+/-RW Drive Watch movies, and read and write CDs and DVDs in multiple formats Integrated 10/100 Fast Ethernet, Wireless-N Connect to a broadband modem with wired Ethernet or wirelessly connect to a WiFi signal or hotspot with the 802.11n connection built into your PC 15.6" HD widescreen touch display with webcam Integrated Intel HD Graphics with HDMI capabilities Additional Features: 8-in-1 memory card reader 2 x USB 3.0 ports, 2 x USB 2.0 ports, 1 x RJ-45 Ethernet port, 1 x HDMI port 6-cell lithium-ion battery 5.12 lbs, 10.2" x 14.8" x 1.23" Software: Genuine Microsoft Windows 8 Home Microsoft Office Trial and Pocket Cloud Companion McAfee LiveSafe Support and Warranty: 1-year limited hardware warranty; 24/7 technical assistance available online or toll-free by phone Restore discs are not included (unless specified by supplier). We recommend you use the installed software to create your own restore and backup DVD the first week you use the computer. What's In The Box: Power cord Dell laptop Quick Start Guide To see the manufacturer's specifications for this product, click here . To see a list of our PC Accessories, click here . Trade in your used computer and electronics for more cash to spend at Walmart. Good for your wallet and the environment - click here .</long></description><saleprice currency="USD">598</saleprice><keywords/><linkurl>http://linksynergy.walmart.com/link?id=yourid&amp;offerid=223073.26002180&amp;type=15&amp;murl=http%3A%2F%2Fwww.walmart.com%2Fip%2FDell-Fire-Red-15.6-Inspiron-15R-Laptop-PC-with-Intel-Core-i3-3227U-Processor-Touchscreen-6GB-Memory-500GB-Hard-Drive-and-Windows-8-Home%2F26002180%3Fsourceid%3D0100000012230215302434</linkurl><imageurl>http://i.walmartimages.com/i/p/00/88/41/16/12/0088411612032_Color_Red_SW_500X500.jpg</imageurl></item></result>
    XML
    stub_request(
      :get,
      "http://productsearch.linksynergy.com/productsearch?keyword=#{keyword}&max=3&token=#{token}"
      ).
      to_return(
        status: 200,
        body: xml_response_1,
        headers: { "Content-type" => "text/xml; charset=UTF-8" }
    )
    stub_request(
      :get,
      "http://productsearch.linksynergy.com/productsearch?keyword=#{keyword}&max=3&pagenumber=2&token=#{token}"
      ).
      to_return(
        status: 200,
        body: xml_response_2,
        headers: { "Content-type" => "text/xml; charset=UTF-8" }
    )
    stub_request(
      :get,
      "http://productsearch.linksynergy.com/productsearch?keyword=#{keyword}&max=3&pagenumber=3&token=#{token}"
      ).
      to_return(
        status: 200,
        body: xml_response_3,
        headers: { "Content-type" => "text/xml; charset=UTF-8" }
    )

    data = LinkshareAPI.product_search(options).all
    assert_equal 8, data.count
    assert_equal "250014339", data.first.sku
    assert_equal "http://i.walmartimages.com/i/p/00/88/41/16/12/0088411612032_Color_Red_SW_500X500.jpg", data.last.imageurl
  end

  private

  def token
    "abcdef"
  end
end
