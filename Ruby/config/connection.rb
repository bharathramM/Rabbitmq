# frozen_string_literal: true

require_relative "string"
require 'bunny'
require 'yaml'

module Config
  # Initializing the connection of RabbitMq
  # exchange argument will accept only hash
  class Connection
    attr_accessor :channel, :exchange

    def initialize
      rmq_config = YAML.load_file("#{root_path}/config/yaml/credential.yml").transform_keys(&:to_sym)
      exchange_config = YAML.load_file("#{root_path}/config/yaml/#{exchange_name}.yml")
      connection = Bunny.new(**rmq_config)
      connection.start

      @channel = connection.create_channel
      @exchange = @channel.send(
        exchange_config.delete('type'),
        exchange_config.delete('name'),
        **exchange_config
      )
    end

    def class_name(name = nil)
      name ||= self.class.name
      underscore(name.split('::')[-1])
    end

    def exchange_name
      ancestors = self.class.ancestors
      class_name(ancestors[ancestors.index(Config::Connection) - 1].name)
    end

    def root_path
      Dir.pwd.split('Ruby').first + "Ruby"
    end

    private

    def underscore(text)
      text.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          downcase
    end
  end
end
