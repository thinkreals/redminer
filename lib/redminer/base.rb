module Redminer
  class Base
    attr_accessor :server

    def initialize(host, access_key, options = {})
      @server = Server.new(host, access_key, options)
    end

    def all=(hash)
      hash.each_pair { |k, v|
        if respond_to?("#{k}=")
          send("#{k}=", v)
        end
      }
      self
    end

    def method_missing(m, *args, &blk)
      @server.send(m, *args, &blk)
    end
  end
end

