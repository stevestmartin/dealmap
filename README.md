# Dealmap

Simple Ruby wrapper for the Dealmap [API](http://www.thedealmap.com/api/). [TheDealMap](http://thedealmap.com) features deals aggregated from a number of sources, includng Groupon, LivingSocial, Restaurants.com, and more.

## Installation

    sudo gem install dealmap
    
## Usage

You'll need a Dealmap [API key](http://www.thedealmap.com/api/keys/).

    require 'dealmap'
    client = Dealmap::Client.new(YOUR_API_KEY)
    
### Searching for deals in Brooklyn, NY
    deals, total = client.search_deals(:l => "Brooklyn, NY")

### Searching for deals based on lat/lng (Brooklyn, NY)
    deals, total = client.search_deals(:l => "40.6500000, -73.9500000")

Dealmap uses a [`Hashie::Mash`](http://github.com/intridea/hashie) for return values, providing a handy hash that supports dot notation:

    deals.first.title
    => "$100 Gift Certificate, Your Price $40"
    deals.first.city
    => "Brooklyn"
    
<a name="changelog"></a>
## Changelog

### 0.0.3 - March 13, 2011

* Initial version

## How to contribute
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

Copyright (c) 2011 [Josh Deeden](http://twitter.com/jdeeden). 
