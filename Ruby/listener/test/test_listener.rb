# frozen_string_literal: true

require_relative '../../config/direct'
module Listener
  module Test
    class TestListener < Config::Direct
      def listen(method_name = :listener)
        super(method_name)
      end

      def listener(_delivery_info, _metadata, msg)
        puts "Test Listener Received as #{msg}"
      end
    end
  end
end

Listener::Test::TestListener.new.listen if ARGV[0] == 'start'
