require "crypto/bcrypt"
require "kemal"
require "./database"

# TODO: is this boilerplate _really_ necessary?!
ACCESS_CONTROL_ALLOW_ORIGIN = "*"
ACCESS_CONTROL_ALLOW_METHODS = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
ACCESS_CONTROL_ALLOW_HEADERS = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"

before_all do |env|
  env.response.headers["Access-Control-Allow-Headers"] = ACCESS_CONTROL_ALLOW_HEADERS
  env.response.headers["Access-Control-Allow-Methods"] = ACCESS_CONTROL_ALLOW_METHODS
  env.response.headers["Access-Control-Allow-Origin"] = ACCESS_CONTROL_ALLOW_ORIGIN
end

options "/users" do |env|
  env.response.headers["Access-Control-Allow-Headers"] = ACCESS_CONTROL_ALLOW_HEADERS
  env.response.headers["Access-Control-Allow-Methods"] = ACCESS_CONTROL_ALLOW_METHODS
  env.response.headers["Access-Control-Allow-Origin"] = ACCESS_CONTROL_ALLOW_ORIGIN
end

options "/users/auth/sign_in" do |env|
  env.response.headers["Access-Control-Allow-Headers"] = ACCESS_CONTROL_ALLOW_HEADERS
  env.response.headers["Access-Control-Allow-Methods"] = ACCESS_CONTROL_ALLOW_METHODS
  env.response.headers["Access-Control-Allow-Origin"] = ACCESS_CONTROL_ALLOW_ORIGIN
end

alias SuccessResponse = Hash(String, Hash(String, Hash(String, String)))
alias ErrorResponse = Hash(String, Array(String))

post "/users" do |env|
  begin
    user = Types::User.from_json(env.params.json.to_json)
    _password = "#{user.password}#{user.email}"
    hashed_password = Crypto::Bcrypt::Password.create(_password).to_s
    user.password = hashed_password
    USER_DATABASE[user.email] = user
    success_response = SuccessResponse.new
    success_response["data"] = {"attributes" => user.to_h}
    env.response.status_code = 200
    success_response.to_json
  rescue exception: JSON::ParseException | JSON::Error
    error_response = ErrorResponse.new
    error_response["errors"] = [exception.message.to_s]
    env.response.status_code = 400
    error_response.to_json
  end
end

post "/users/auth/sign_in" do |env|
  begin
    auth = Types::UserAuth.from_json(env.params.json.to_json)
    user = USER_DATABASE[auth.email]
    hashed_password = Crypto::Bcrypt::Password.new(user.password)
    salted_auth_password = "#{auth.password}#{auth.email}"

    if hashed_password == salted_auth_password
      success_response = SuccessResponse.new
      success_response["data"] = {"attributes" => user.to_h}
      env.response.status_code = 200
      success_response.to_json
    else
      raise Exception.new
    end
  rescue exception: Exception
    error_response = ErrorResponse.new
    error_response["errors"] = ["Invalid email or password."]
    env.response.status_code = 401
    error_response.to_json
  end
end

get "/heartbeat" do |env|
  env.response.status_code = 200
end
