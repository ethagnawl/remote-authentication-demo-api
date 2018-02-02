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

post "/users" do |env|
  begin
    result = Types::User.from_json(env.params.json.to_json)
    email = result.email
    USER_DATABASE[email] = result
    success_response = Hash(String, Hash(String, Types::User)).new
    success_response["data"] = {"attributes" => result}
    env.response.status_code = 200
    success_response.to_json
  rescue exception: JSON::ParseException
    error_response = Hash(String, Array(String)).new
    error_response["errors"] = [exception.message.to_s]
    env.response.status_code = 400
    error_response.to_json
  end
end

post "/users/auth/sign_in" do |env|
  begin
    auth = Types::UserAuth.from_json(env.params.json.to_json)
    user = USER_DATABASE[auth.email]
    if user.password == auth.password
      success_response = Hash(String, Hash(String, Types::User)).new
      success_response["data"] = {"attributes" => user}
      env.response.status_code = 200
      success_response.to_json
    else
      env.response.status_code = 401
    end
  rescue
    env.response.status_code = 401
  end
end

# get "/users/:email" do |env|
#   env.response.content_type = "application/json"
#   email = env.params.url["email"]
#   USER_DATABASE[email].to_json
# end
