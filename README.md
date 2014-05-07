# LinkShare API

[![Gem Version](https://badge.fury.io/rb/linkshare_api.png)](http://badge.fury.io/rb/linkshare_api)
[![Build Status](https://travis-ci.org/rmarescu/linkshare_api.png)](https://travis-ci.org/rmarescu/linkshare_api)

Ruby wrapper for [LinkShare Publisher Web Services](http://helpcenter.linkshare.com/publisher/categories.php?categoryid=71).
Supported web services:
* [Automated LinkGenerator](#automated-link-generator)
* [Merchandiser Query Tool](#merchandiser-query-tool)

If you need services that are not yet supported, feel free to [contribute](#contributing).
For questions or bugs please [create an issue](../../issues/new).

## <a id="installation"></a>Installation

Add this line to your application's Gemfile:

    gem 'linkshare_api'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install linkshare_api

## <a id="requirement"></a>Requirements

[Ruby](http://www.ruby-lang.org/en/downloads/) 1.9 or above.

## <a id="usage"></a>Usage

Before using **LinkShare API** you need to set up your publisher token first. If you use Ruby on Rails, the token can be set in a configuration file (i.e. `app/config/initializers/linkshare_api.rb`), otherwise just set it in your script. The token can be found on LinkShare's Web Services page under the Links tab.

```ruby
require "linkshare_api" # no need for RoR
LinkshareAPI.token = ENV["LINKSHARE_TOKEN"]
```

### Automated Link Generator

Generate affiliate URLs using [Automated LinkGenerator](http://helpcenter.linkshare.com/publisher/categories.php?categoryid=72) service.
Below is an example of generating an affiliate URL for [Walmart](http://www.walmart.com). Walmart merchant code is `2149`.

```ruby
url = "http://www.walmart.com/cp/Electronics/3944?povid=P1171-C1093.2766-L33"
affiliate_url = LinkshareAPI.link_generator(2149, url)
```

### Merchandiser Query Tool

Search for products using [Merchandiser Query Tool](http://helpcenter.linkshare.com/publisher/categories.php?categoryid=74) service.

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

`product_search` accepts a hash as argument, and can include all available options. For a complete list of options please visit  http://helpcenter.linkshare.com/publisher/questions.php?questionid=652.

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

### Coupon Web Services

Easy access to coupons and promotional link data for your advertisers using [Coupon Web Service](http://helpcenter.linkshare.com/publisher/questions.php?questionid=865)

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
