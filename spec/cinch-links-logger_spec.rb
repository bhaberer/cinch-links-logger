# -*- coding: utf-8 -*-
require 'spec_helper'

describe Cinch::Plugins::LinksLogger do
  include Cinch::Test

  before(:each) do
    @bot = make_bot(Cinch::Plugins::LinksLogger, { :filename => '/dev/null' })
  end

  it 'should capture links' do
    get_replies(make_message(@bot, 'http://github.com', { channel: '#foo', nick: 'bar' }))
    expect(@bot.plugins.first.storage.data['#foo'].keys.first)
      .to eq('http://github.com')
  end

  it 'should capture links count' do
    15.times { get_replies(make_message(@bot, 'http://github.com', { channel: '#foo' })) }
    links = @bot.plugins.first.storage.data['#foo']
    expect(links.length).to eq(1)
    expect(links.values.first.count).to eq(15)
  end

  it 'should not capture malformed URLS' do
    get_replies(make_message(@bot, 'htp://github.com', { channel: '#foo', nick: 'bar' }))
    get_replies(make_message(@bot, 'http/github.com', { channel: '#foo', nick: 'bar' }))
    expect(@bot.plugins.first.storage.data['#foo'])
      .to be_nil
  end

  it 'should allow users to get a list of recently linked URLS' do
    get_replies(make_message(@bot, 'http://github.com', { channel: '#foo', nick: 'bar' }))
    replies = get_replies(make_message(@bot, '!links', { channel: '#foo', nick: 'test' }))
    expect(replies.first.text).to eq('Recent Links in #foo')
    expect(replies.last.text)
      .to eq('http://github.com - GitHub · Build software better, together.')
  end
end
