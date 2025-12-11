# Roda application environment variables
ENV["SESSION_SECRET"] ||= "a_secure_random_string_here_that_is_long_enough_and_random_enough"

# Facebook OAuth credentials
ENV["FACEBOOK_APP_ID"] ||= "your_facebook_app_id"
ENV["FACEBOOK_APP_SECRET"] ||= "your_facebook_app_secret"

