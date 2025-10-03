module OAuth
  class AuthenticationService
    def initialize(session:, nation_slug:)
      @session = session
      @nation_slug = nation_slug
    end

    def authorization_url
      # Generate and store PKCE pair
      pkce = OAuth::PkceGenerator.generate
      @session[:code_verifier] = pkce[:code_verifier]

      # Generate and store state for CSRF protection
      state = SecureRandom.hex(32)
      @session[:oauth_state] = state

      # Store nation slug for callback
      @session[:nation_slug] = @nation_slug

      # Build authorization URL
      base_url = "https://#{@nation_slug}.nationbuilder.com"
      params = {
        response_type: "code",
        client_id: ENV.fetch("NB_CLIENT_ID"),
        redirect_uri: ENV.fetch("NB_REDIRECT_URI"),
        scope: ENV.fetch("NB_SCOPES", "default"),
        state: state,
        code_challenge: pkce[:code_challenge],
        code_challenge_method: "S256"
      }

      query_string = params.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join("&")
      "#{base_url}/oauth/authorize?#{query_string}"
    end

  def handle_callback(code:, state:)
    # Verify state parameter (CSRF protection)
    unless state == @session[:oauth_state]
      raise "Invalid state parameter - possible CSRF attack"
    end

      # Get stored values from session
      code_verifier = @session[:code_verifier]
      nation_slug = @session[:nation_slug]

      unless code_verifier && nation_slug
        raise "Missing OAuth session data"
      end

      # Exchange code for tokens
      token_service = OAuth::TokenService.new(nation_slug)
      tokens = token_service.exchange_code(
        code: code,
        code_verifier: code_verifier
      )

      # Store installation in database
      installation = Installation.find_or_initialize_by(nation_slug: nation_slug)

      if installation.persisted? && installation.uninstalled?
        # Reactivate previously uninstalled app
        installation.reactivate!(tokens)
      else
        # New installation
        installation.assign_attributes(
          access_token: tokens["access_token"],
          refresh_token: tokens["refresh_token"],
          expires_at: Time.at(tokens["expires_at"]),
          token_type: tokens["token_type"],
          scope: tokens["scope"],
          status: "active",
          installed_at: Time.current,
          last_used_at: Time.current
        )
        installation.save!
      end

      # Clean up session OAuth data
      @session.delete(:oauth_state)
      @session.delete(:code_verifier)

      # Keep nation_slug in session for this visit
      @session[:nation_slug] = nation_slug

      installation
    end

    def logout
      if @nation_slug
        installation = Installation.find_by(nation_slug: @nation_slug)
        installation&.uninstall!
      end

      @session.delete(:nation_slug)
    end
  end
end
