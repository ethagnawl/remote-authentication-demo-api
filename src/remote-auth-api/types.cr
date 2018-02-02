require "json"

module Types
  class UserAuth
    JSON.mapping(
      email: String,
      password: String
    )
  end

  class User
    JSON.mapping(
      email: String,
      password: String,
      first_name: String,
      last_name: String
    )
  end
end
