# LinkShare API

[![Gem Version](https://badge.fury.io/rb/linkshare_api.png)](http://badge.fury.io/rb/linkshare_api)
[![Build Status](https://travis-ci.org/rmarescu/linkshare_api.png)](https://travis-ci.org/rmarescu/linkshare_api)

Ruby wrapper for [LinkShare Publisher Web Services](https://rakutenlinkshare.zendesk.com).
Supported web services:
* [Deep Linking](#deep-linking) (previously [Automated LinkGenerator](#automated-link-generator))
* [Merchandiser Query Tool](#merchandiser-query-tool)
* [Coupon Web Service](#coupon-web-service)

If you need services that are not yet supported, feel free to [contribute](#contributing).
For questions or bugs please [create an issue](../../issues/new).

## <a id="requirement"></a>Requirements

[Ruby](http://www.ruby-lang.org/en/downloads/) 1.9 or above.

## <a id="installation"></a>Installation

Add this line to your application's Gemfile:

    gem 'linkshare_api'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install linkshare_api

## <a id="configuration"></a>Configuration

Before using **LinkShare API** you need to set up your publisher token first. If you use Ruby on Rails, the token can be set in a configuration file (i.e. `app/config/initializers/linkshare_api.rb`), otherwise just set it in your script. The token can be found on LinkShare's Web Services page under the Links tab.

```ruby
LinkshareAPI.token = ENV["LINKSHARE_TOKEN"]
```

Affiliate ID is required for using Deep Linking.

```ruby
LinkshareAPI.affiliate_id = ENV["LINKSHARE_AFFILIATE_ID"]
```

By default linkshare_api logs to STDOUT. To use your own logger implementation you have to specify it using `LinkshareAPI.logger`

### Configuration example

Would apply for Ruby on Rails. Create `app/config/initializers/linkshare_api.rb` and add the following content:

```ruby
LinkshareAPI.token = ENV["LINKSHARE_TOKEN"]
LinkshareAPI.affiliate_id = ENV["LINKSHARE_AFFILIATE_ID"]
LinkshareAPI.logger = Rails.logger
```

## <a id="usage"></a>Usage

### Deep Linking

Generate affiliate URLs using [Deep Linking](https://rakutenlinkshare.zendesk.com/hc/en-us/articles/201295755-Guide-to-Deep-Linking) service.
Below is an example of generating an affiliate URL for [Walmart](http://www.walmart.com). Walmart merchant code is `2149`.

```ruby
require "linkshare_api" # No need for RoR

LinkshareAPI.affiliate_id = ENV["LINKSHARE_AFFILIATE_ID"] # must be set in order to use Deep Linking, otherwise will fall back to Automated Link Generator
url = "http://www.walmart.com/cp/Electronics/3944?povid=P1171-C1093.2766-L33"
affiliate_url = LinkshareAPI.link_generator(2149, url)
# http://click.linksynergy.com/deeplink?id=your_affiliate_id&mid=2149&murl=http%3A%2F%2Fwww.walmart.com%2Fcp%2FElectronics%2F3944%3Fpovid%3DP1171-C1093.2766-L33
```

**Note:** The link is generated manually, therefore you must ensure that the Affiliate ID provided is valid.

### Automated Link Generator

**Deprecation Notice**

**As of October 2014, Automated LinkGenerator is discontinued in favor of Deep Linking.** To use [Deep Linking](#deep-linking) instead, you only have to set `LinkshareAPI.affiliate_id`. Everything else remains the same.

Generate affiliate URLs using [Automated LinkGenerator](https://rakutenlinkshare.zendesk.com/hc/en-us/articles/201343135-Automated-LinkGenerator-Guidelines) service.
Below is an example of generating an affiliate URL for [Walmart](http://www.walmart.com). Walmart merchant code is `2149`.

```ruby
url = "http://www.walmart.com/cp/Electronics/3944?povid=P1171-C1093.2766-L33"
affiliate_url = LinkshareAPI.link_generator(2149, url)
# http://linksynergy.walmart.com/fs-bin/click?id=your_affiliate_id&subid=0&offerid=223073.1&type=10&tmpid=273&RD_PARM1=http%3A%2F%2Fwww.walmart.com%2Fcp%2FElectronics%2F3944%3F&RD_PARM2=povid%3DP1171-C1093.2766-L33
```

### Merchandiser Query Tool

Search for products using [Merchandiser Query Tool](https://rakutenlinkshare.zendesk.com/hc/en-us/articles/201483905-Merchandiser-Query-Tool-API-Guidelines) service.

```ruby
response = LinkshareAPI.product_search(keyword: "laptop")
# Return the number of total records that match the search criteria
puts response.total_matches # -1 means more than 4000 results (see doc)
# Return the number of pages
puts response.total_pages
# Return the number of current page
puts response.page_number
# See the actual API call to Linkshare
puts response.request.uri
# Return items
response.data.each do |item|
  puts "Title: #{item.productname}"
  puts "Price: #{item.price.__content__} #{item.price.currency}"
  puts "URL: #{item.linkurl}"
end
```

`product_search` accepts a hash as argument, and can include all available options. For a complete list of options please visit https://rakutenlinkshare.zendesk.com/hc/en-us/articles/201483905-Merchandiser-Query-Tool-API-Guidelines.

```ruby
# Search "laptop" only for Wal-Mart, within Electronics category,
# sorted by price ascending, and limit to 10 items per page.
options = {
  keyword: "laptop",
  mid: 2149, # Wal-Mart
  cat: "Electronics",
  max: 10,
  sort: :retailprice,
  sorttype: :asc
}
response = LinkshareAPI.product_search(options)
response.data.each do |item|
  # Do stuff
end
```

If there are multiple pages, you can retrieve all pages by using the `all` method, as follows:

```ruby
response.all.each do |item|
  # Do stuff
end
```

When using the `all` method, `response` object is updated with the data returned by the last API request (last page). `response.all` returns the `data` array.

### Coupon Web Service

Easy access to coupons and promotional link data for your advertisers using [Coupon Web Service](https://rakutenlinkshare.zendesk.com/hc/en-us/articles/200919909-Using-the-Coupon-Web-Service)

```ruby
# Search for promotion types "Clearance" (id 3) and "Dollar Amount Off" (id 5)
# from Wal-Mart (id 2149) within category "Apparel - Babies & Kids" (id 3)
# in the US network (id 1)
options = {
  promotiontype: 3|5,
  mid: 2149,
  cat: 3,
  network: 1
}
response = LinkshareAPI.coupon_web_service(options)
response.data.each do |item|
  # Do stuff
end
```

### Extra Configuration

* `LinkshareAPI.api_timeout` - the timeout set when initiating requests to LinkShare Web Services (default value is 30 seconds)

## <a id="contributing"></a>Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## <a id="license"></a>License

[MIT](LICENSE.txt)
