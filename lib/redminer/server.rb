module Redminer
  class Server
    attr_accessor :http, :access_key
    attr_accessor :verbose, :reqtrace

    def initialize(host, access_key, options = {})
      options = {:port => 80}.merge(options)
      @http = Net::HTTP.new(host, options[:port])
      @access_key = access_key
      @verbose = options[:verbose]
      @reqtrace = options[:reqtrace]
    end

    def request(path, params = nil, obj = Net::HTTP::Get)
      puts "requesting... #{http.address}:#{http.port}#{path} by #{obj}" if verbose
      puts caller.join("\n  ") if reqtrace
      req = obj.new(path)
      req.add_field('X-Redmine-API-Key', access_key)
      req.body = hash_to_querystring(params) if not params.nil? and not params.empty?
      begin
        if block_given?
          yield http.request(req)
        else
          response = http.request(req)
          if response.code != "200"
            raise "fail to request #{response.code}:#{response.message}"
          end
          return {} if response.body.nil? or response.body.strip.empty?
          JSON.parse(response.body)
        end
      rescue Timeout::Error => e
        raise e, "#{host}:#{port} timeout error", e.backtrace
      rescue JSON::ParserError => e
        raise e, "response json parsing error", e.backtrace
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

    def current_user
      Redminer::User.current(self)
    end

    def working?
      begin
        current_user and true
      rescue
        false
      end
    end

    def issue(issue_key = nil)
      Redminer::Issue.new(self, issue_key)
    end
  end
end
