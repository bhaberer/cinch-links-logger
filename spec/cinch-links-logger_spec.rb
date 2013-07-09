require 'spec_helper'

describe Cinch::Plugins::LinksLogger do
  include Cinch::Test

  before(:each) do
    @bot = make_bot(Cinch::Plugins::LinksLogger, { :filename => '/dev/null' })
  end

  describe 
  it 'should capture links' do
    puts Benchmark.measure { get_replies(make_message(@bot, 'http://github.com', { channel: :foo })) }
    puts Benchmark.measure { get_replies(make_message(@bot, '!links', { channel: :foo })) }

  end
end
