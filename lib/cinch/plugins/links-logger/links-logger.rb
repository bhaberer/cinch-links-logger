# -*- coding: utf-8 -*-
require 'open-uri'
require 'cinch-storage'
require 'cinch-toolbox'
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
      @storage.data[:history] ||= Hash.new
      @post_titles = config[:titles].nil? ? true : config[:titles]
      @post_stats  = config[:stats].nil?  ? true : config[:stats]
    end

    def execute(m)
      if m.channel.nil?
        m.user.msg "You must use that command in the main channel."
        return
      end

      m.user.send "Recent Links in #{m.channel}"
      last = @storage.data[:history][m.channel.name].values.sort {|a,b| b[:time] <=> a[:time] }
      last[0,10].each_with_index do |link, i|
        msg = "#{i + 1} - "
        if link[:title].nil?
          msg << Cinch::Toolbox.expand(@link[:short_url])
        else
          msg << "#{link[:short_url]} ∴ #{link[:title]}"
        end
        m.user.send msg
      end
    end

    def listen(m)
      urls = URI.extract(m.message, ["http", "https"])
      urls.each do |url|
        # Ensure we have a Channel Object in the History to dump links into.
        @storage.data[:history][m.channel.name] ||= Hash.new

        # Make sure it conforms to white/black lists before bothering.
        if whitelisted?(url) && !blacklisted?(url)
          # If the link was posted already, get the old info instead of getting new
          if @storage.data[:history][m.channel.name].key?(url)
            @storage.data[:history][m.channel.name][url][:count] += 1
            @link = @storage.data[:history][m.channel.name][url]
          else
            @link = { :nick      => m.user.nick,
                      :title     => Cinch::Toolbox.get_page_title(url) || nil,
                      :count     => 1,
                      :short_url => Cinch::Toolbox.shorten(url),
                      :time      => Time.now }
            @storage.data[:history][m.channel.name][url] = @link
          end
        else
          debug "#{blacklisted?(url) ? 'Blacklisted URL was not logged' : 'Domain not Whitelisted'} #{url}"
          return
        end

        # Check to see if we should post titles
        if @post_titles
          # Only spam the channel if you have a title
          unless @link[:title].nil?
            m.reply "#{@link[:short_url] || url} ∴  #{@link[:title]}"
          end
        end

        # Check to see if we should post stats and if it'ss been linked more than once.
        if @post_stats && @link[:count] > 1
          # No stats if this person was the first one to link it
          unless @link[:nick] == m.user.nick
            m.reply "That was already linked by #{@link[:nick]} #{@link[:time].ago.to_words}.", true
          end
        end
      end

      # Don't save unless we found some urls to process
      if urls
        synchronize(:save_links) do
          @storage.save
        end
      end
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
