module Redminer
  class Base
    attr_accessor :server, :access_key

    def initialize(host, port, access_key)
      @server = Net::HTTP.new(host, port)
      @access_key = access_key
    end

    def request(path, params = nil, obj = Net::HTTP::Get)
      req = obj.new(path)
      req.add_field('X-Redmine-API-Key', access_key)
      req.body = hash_to_querystring(params) if not params.nil? and not params.empty?
      begin
        if block_given?
          yield server.request(req)
        else
          server.request(req).body
        end
      rescue Timeout::Error
        raise "#{host}:#{port} does not respond"
      end
    end

    def hash_to_querystring(hash)
      hash.keys.inject('') do |query_string, key|
        value = case hash[key]
          when Hash then hash[key].to_json
          else hash[key].to_s
        end
        query_string << '&' unless key == hash.keys.first
        query_string << "#{URI.encode(key.to_s)}=#{URI.encode(value)}"
      end
    end

    def get(path, params = nil, &block); request(path, params, &block) end
    def put(path, params = nil, &block); request(path, params, Net::HTTP::Put, &block) end
    def post(path, params = nil, &block); request(path, params, Net::HTTP::Post, &block) end
    def delete(path, params = nil, &block); request(path, params, Net::HTTP::Delete, &block) end

    def issue(issue_key = nil)
      Redminer::Issue.new(self, issue_key)
    end
  end
end

