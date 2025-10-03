module OAuth
  class TokenService
    include HTTParty

    def initialize(nation_slug)
      @nation_slug = nation_slug
      @base_url = "https://#{nation_slug}.nationbuilder.com"
    end

    def exchange_code(code:, code_verifier:)
      response = self.class.post(
        "#{@base_url}/oauth/token",
        body: {
          grant_type: "authorization_code",
          code: code,
          redirect_uri: oauth_config[:redirect_uri],
          client_id: oauth_config[:client_id],
          client_secret: oauth_config[:client_secret],
          code_verifier: code_verifier
        },
        headers: { "Content-Type" => "application/x-www-form-urlencoded" }
      )

      if response.success?
        tokens = JSON.parse(response.body)
        add_expiry_timestamp(tokens)
      else
        raise "Token exchange failed: #{response.code} - #{response.body}"
      end
    end

    def refresh_tokens(refresh_token)
      response = self.class.post(
        "#{@base_url}/oauth/token",
        body: {
          grant_type: "refresh_token",
          refresh_token: refresh_token,
          client_id: oauth_config[:client_id],
          client_secret: oauth_config[:client_secret]
        },
        headers: { "Content-Type" => "application/x-www-form-urlencoded" }
      )

      if response.success?
        tokens = JSON.parse(response.body)
        add_expiry_timestamp(tokens)
      else
        raise "Token refresh failed: #{response.code} - #{response.body}"
      end
    end

    private

    def oauth_config
      @oauth_config ||= {
        client_id: ENV.fetch("NB_CLIENT_ID"),
        client_secret: ENV.fetch("NB_CLIENT_SECRET", nil),
        redirect_uri: ENV.fetch("NB_REDIRECT_URI")
      }
    end

    def add_expiry_timestamp(tokens)
      tokens["expires_at"] = Time.current.to_i + tokens["expires_in"].to_i
      tokens
    end
  end
end
