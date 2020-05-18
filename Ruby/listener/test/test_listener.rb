# frozen_string_literal: true

require_relative '../../config/direct'
module Listener
  module Test
    class TestListener < Config::Direct; end
  end
end

Listener::Test::TestListener.new.listen if ARGV[0] == 'start'
