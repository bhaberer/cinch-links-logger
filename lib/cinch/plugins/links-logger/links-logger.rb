# -*- coding: utf-8 -*-
require 'open-uri'
require 'cinch'
require 'cinch/toolbox'
require 'cinch-storage'

class Link < Struct.new(:nick, :title, :count, :short_url, :time)
  def to_yaml
    { nick: nick, title: title, count: count, short_url: short_url, time: time }
  end
end

module Cinch::Plugins
  class LinksLogger
    include Cinch::Plugin
    attr_reader :storage

    listen_to :channel

    self.help = 'Use .links to see the last links users have posted to the channel.'

    match /links/

    def initialize(*args)
      super
      @storage = CinchStorage.new(config[:filename] || 'yaml/links.yaml')
      @storage.data ||= Hash.new
    end

    def execute(m)
      return if Cinch::Toolbox.sent_via_private_message?(m)
      get_recent_links(m.channel.name).each { |line| m.user.send line }
    end

    def listen(m)
      urls = URI.extract(m.message, ["http", "https"])
      urls.each do |url|
        # Ensure we have a Channel Object in the History to dump links into.
        @storage.data[m.channel.name] ||= Hash.new
        @link = get_or_create_link(m, url)
      end
    end

    private

    def get_or_create_link(m, url)
      channel = m.channel.name
      # If the link was posted already, get the old info instead of getting new
      @storage.data[channel][url] ||= Link.new(m.user.nick,
                                               Cinch::Toolbox.get_page_title(url),
                                               0,
                                               Cinch::Toolbox.shorten(url),
                                               Time.now)
      @storage.data[channel][url].count += 1
      @storage.synced_save(@bot)
      return @storage.data[channel][url]
    end

    def get_recent_links(channel)
      message = ["Recent Links in #{channel}"]
      links = @storage.data[channel].values.reverse[0..9]
      links.each_with_index do |link|
        message << if link.title.nil?
                     Cinch::Toolbox.expand(link.short_url)
                   else
                     "#{link.short_url} - #{link.title}"
                   end
      end
      return message
    end
  end
end
