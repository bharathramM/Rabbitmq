# frozen_string_literal: true

require 'json'
require_relative 'connection'

module Config
  # Direct Exchange
  class Direct < Connection
    def listen(method_name = :default_block)
      name, queue_opts, bind_opts, subscribe_opts = queue_conf
      @channel.queue(name, **queue_opts)
              .bind(@exchange, **bind_opts)
              .subscribe(**subscribe_opts) do |delivery_info, metadata, msg|
        method(method_name).call(delivery_info, metadata, msg)
      end
    end

    # class_name will be inherited from Connection class
    # message argument needs to be Hash
    def publish(message)
      validate!(message)

      publish_config = conf['publish']
      @exchange.publish(message.to_json, **publish_config)
    end

    private

    # Validating weather provided value is Hash
    def validate!(value)
      raise "Invalid format" unless value.instance_of?(Hash)
    end

    def conf
      name = class_name
      folder = name.split('_').first
      YAML.load_file("#{root_path}/listener/#{folder}/#{class_name}.yml")
    end

    def queue_conf
      listener_conf = conf
      [
        listener_conf['queue'].delete('name'),
        listener_conf['queue'].delete('options'),
        listener_conf['bind'].transform_keys(&:to_sym),
        listener_conf['subscribe'].transform_keys(&:to_sym)
      ]
    end

    def default_block(_delivery_info, _metadata, msg)
      puts "I received message as ======= #{msg}"
    end
  end
end
