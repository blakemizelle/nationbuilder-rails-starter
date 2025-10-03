# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "bin/rails g active_record:session_migration")
Rails.application.config.session_store :cookie_store,
  key: "_nb_rails_app_session",
  same_site: :lax,
  secure: Rails.env.production?
