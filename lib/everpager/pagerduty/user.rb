module Everpager; module PagerDuty

  class Users

    API_METHOD = 'users'

    def initialize(session,query)
      @response = session.api(API_METHOD,query)
      @users = []
      @response['users'].each do |user|
        @users.push(User.new(user))
      end
    end

  end

  class User < Hash

    def initialize(user_hash)
      user_hash.each do |key,value|
        self.class[key] = value
    end
  end
end end end