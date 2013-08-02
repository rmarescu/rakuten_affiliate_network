# LinkShare API

Ruby wrapper for [LinkShare Publisher Web Services](http://helpcenter.linkshare.com/publisher/categories.php?categoryid=71).
Supported web services:
* [Automated LinkGenerator](#automated_link_generator)

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

Before using the services you need to set up your publisher token first. If you use Ruby on Rails, the token can be set in a configuration file (i.e. `app/config/initializers/linkshare_api.rb`), otherwise just set it in your script. The token can be found on LinkShare's Web Services page under the Links tab.

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
