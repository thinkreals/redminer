module Redminer
  class Issue < Redminer::Base
    attr_reader :base, :id
    attr_accessor :author, :project
    attr_accessor :tracker, :status, :priority, :category
    attr_accessor :subject, :description
    attr_accessor :start_date, :due_date
    attr_accessor :created_on, :updated_on

    def initialize(base, id = nil)
      @base = base
      unless id.nil?
        @id = id
        retrieve
      end
    end

    def retrieve
      response = base.get("/issues/#{id}.json")
      raise "#{id} issue does not exists" if response.nil?
      origin = JSON.parse(response)["issue"]
      origin.each_pair { |k, v|
        if respond_to?("#{k}=")
          send("#{k}=", v)
        end
      }
      self
    end

    def self.exists?(id)
      (self.new(id) and true) rescue false
    end

    def sync
      (@id.nil? ? create : update)
    end

    def craete
      params = {
        :subject => @subject,
        :description => @description,
        :project => @project
      }
      base.post("/issues.json", params)
    end
    def update(note = nil)
      params = {
        :subject => @subject,
        :description => @description,
        :project => @project
      }
      params.merge!(:notes => note) unless note.nil?
      base.put("/issues/#{id}.json", params)
    end
  end
end
