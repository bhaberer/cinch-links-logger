# -*- coding: utf-8 -*-
require 'open-uri'
require 'cinch'
require 'cinch/toolbox'
require 'cinch-storage'
require 'time-lord'

module Cinch::Plugins
  class LinksLogger
    include Cinch::Plugin

    listen_to :channel

    self.help = 'Use .links to see the last links users have posted to the channel.'

    match /links/

    def initialize(*args)
      super
      @storage = CinchStorage.new(config[:filename] || 'yaml/links.yaml')
      @storage.data ||= Hash.new
    end

    Link < Struct.new(:nick, :title, :count, :short_url, :time)

    def execute(m)
      return if Cinch::Toolbox.sent_via_private_message?(m)

      message = []

      message << "Recent Links in #{m.channel.name}"
      last = @storage.data[m.channel.name].values
      last.sort! {|a,b| b.time <=> a.time }
      last[0,9].each_with_index do |link, i|
        msg = "#{i + 1} - "
        if link.title.nil?
          msg << Cinch::Toolbox.expand(link.short_url)
        else
          msg << "#{link.short_url} ∴ #{link.title}"
        end
        message << msg
      end
      message.each { |m| m.user.send m }
    end

    def listen(m)
      channel = m.channel.name

      urls = URI.extract(m.message, ["http", "https"])
      urls.each do |url|
        # Ensure we have a Channel Object in the History to dump links into.
        @storage.data[channel] ||= Hash.new

        # Make sure it conforms to white/black lists before bothering.
        if whitelisted?(url) && !blacklisted?(url)
          # If the link was posted already, get the old info instead of getting new
          if @storage.data[channel].key?(url)
            @storage.data[channel][url][:count] += 1
            @link = @storage.data[channel][url]
          else
            @storage.data[channel][url] = Link.new(m.user.nick,
                                                   Cinch::Toolbox.get_page_title(url),
                                                   1, Cinch::Toolbox.shorten(url), Time.now)
          end
        else
          debug "#{blacklisted?(url) ? 'Blacklisted URL was not logged' : 'Domain not Whitelisted'} #{url}"
          return
        end
      end
      # Save if we matched urls.
      @storage.synced_save if urls
    end

    private

    def whitelisted?(url)
      return true unless config[:whitelist]
      debug "Checking Whitelist! #{config[:whitelist]} url: #{url}"
      return true if url.match(Regexp.new("https:?\/\/.*\.?#{config[:whitelist].join('|')}\."))
      false
    end

    def blacklisted?(url)
      return false unless config[:blacklist]
      debug "Checking Blacklist! #{config[:blacklist]} url: #{url}"
      return true if url.match(Regexp.new("https:?\/\/.*\.?#{config[:blacklist].join('|')}\."))
      false
    end
  end
end
