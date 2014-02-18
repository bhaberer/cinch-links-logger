# -*- coding: utf-8 -*-
require 'open-uri'
require 'cinch'
require 'cinch/toolbox'
require 'cinch-storage'

module Cinch::Plugins
  # Cinch Plugin to track links
  class LinksLogger
    include Cinch::Plugin
    attr_reader :storage

    listen_to :channel

    self.help = 'Use .links to see the last links posted to the channel.'

    match /links/

    def initialize(*args)
      super
      @storage = CinchStorage.new(config[:filename] || 'yaml/links.yaml')
      @storage.data ||= {}
    end

    def execute(m)
      return if Cinch::Toolbox.sent_via_private_message?(m)
      get_recent_links(m.channel.name).each { |line| m.user.send line }
    end

    def listen(m)
      urls = URI.extract(m.message, %w(http https))
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
      @storage.data[channel][url] ||= Link.new(m.user.nick, url)
      @storage.data[channel][url].inc_count
      @storage.synced_save(@bot)
      @storage.data[channel][url]
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
      message
    end
  end
end
