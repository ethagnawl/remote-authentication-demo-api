require "json"

module Types
  class UserAuth
    JSON.mapping({
      email: String,
      password: String
    })

    def initialize(pull : JSON::PullParser)
      previous_def
      raise JSON::Error.new("email is required.") if email.empty?
      raise JSON::Error.new("password is required.") if password.empty?
    end
  end

  class User
    JSON.mapping(
      email: String,
      first_name: String,
      last_name: String,
      password: String
    )

    def to_h
      {
        "email" => self.email,
        "first_name" => self.first_name,
        "last_name" => self.last_name
      }
    end

    def initialize(pull : JSON::PullParser)
      previous_def
      raise JSON::Error.new("email is required.") if email.empty?
      raise JSON::Error.new("first_name is required.") if first_name.empty?
      raise JSON::Error.new("last_name is required.") if last_name.empty?
      raise JSON::Error.new("password is required.") if password.empty?
    end
  end
end
