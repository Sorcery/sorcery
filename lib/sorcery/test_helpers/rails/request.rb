module Sorcery
  module TestHelpers
    module Rails
      module Request
        # Accepts arguments for user to login, the password, route to use and HTTP method
        # Defaults - @user, 'secret', 'user_sessions_url' and http_method: POST
        def login_user(user = nil, password = 'secret', route = nil, http_method = :post)
          user ||= @user
          route ||= user_sessions_url

          username_attr = user.sorcery_config.username_attribute_names.first
          username = user.send(username_attr)
          password_attr = user.sorcery_config.password_attribute_name

          send(http_method, route, params: { "#{username_attr}": username, "#{password_attr}": password })
        end
      end
    end
  end
end
