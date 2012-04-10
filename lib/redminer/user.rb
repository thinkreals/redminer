module Redminer
  class User
    attr_reader :id
    attr_accessor :login, :firstname, :lastname, :mail

    def initialize(server, id = nil)
      @id = id
    end

    def self.current(server)
      response = server.get('/users/current.json')
      origin = response["user"]
      c_user = self.new(server)
      c_user.all = origin
      c_user.instance_variable_get(:@id, origin["id"])
      c_user
    end
  end
end