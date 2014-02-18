# -*- coding: utf-8 -*-
# Class to track Link data
class Link
  attr_accessor :nick, :title, :count, :short_url, :time

  def initialize(nick, url, time = Time.now)
    @nick = nick
    @title = Cinch::Toolbox.get_page_title(url)
    @count = 0
    @short_url = Cinch::Toolbox.shorten(url)
    @time = time
  end

  def inc_count(count = 1)
    @count += count
  end
end
