# Cinch::Plugins::LinksLogger

[![Gem Version](https://badge.fury.io/rb/cinch-links-logger.png)](http://badge.fury.io/rb/cinch-links-logger)
[![Dependency Status](https://gemnasium.com/bhaberer/cinch-links-logger.png)](https://gemnasium.com/bhaberer/cinch-links-logger)
[![Build Status](https://travis-ci.org/bhaberer/cinch-links-logger.png?branch=master)](https://travis-ci.org/bhaberer/cinch-links-logger)
[![Coverage Status](https://coveralls.io/repos/bhaberer/cinch-links-logger/badge.png?branch=master)](https://coveralls.io/r/bhaberer/cinch-links-logger?branch=master)
[![Code Climate](https://codeclimate.com/github/bhaberer/cinch-links-logger.png)](https://codeclimate.com/github/bhaberer/cinch-links-logger)

Cinch Plugin for logging links and printing titles / stats for linked urls.

## Installation

Add this line to your application's Gemfile:

    gem 'cinch-links-logger'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cinch-links-logger

## Usage

You will need to add the Plugin and config to your list first;

    @bot = Cinch::Bot.new do
      configure do |c|
        c.plugins.plugins = [Cinch::Plugins::LinksLogger]
        c.plugins.options[Cinch::Plugins::LinksTumblr] = { :stats     => true,
                                                           :titles    => true,
                                                           :filename  => 'yaml/links.yml',
                                                           :whitelist => nil,
                                                           :blacklist => nil }
      end
    end

The configuration variables are all optional, what's listed are their defaults

:titles (boolean) - Setting this to true will print the URL's title to the channel.

:stats (boolean) - Setting this to true will print the name of the user who first linked
                   the URL, if applicable.

:blacklist - An array of domains that you want to ignore, e.g.

    :blackist => ['twitter', 'reddit']

:whitelist - An array of domains that you want limit title printing and logging to, e.g.

    :whitelist => ['youtube']

:filename - the file to store previously linked urls.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
