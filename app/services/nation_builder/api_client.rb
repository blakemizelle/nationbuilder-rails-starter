module NationBuilder
  class ApiClient
    include HTTParty
    
    class ApiError < StandardError; end
    class AuthenticationError < ApiError; end
    
    def initialize(nation_slug)
      @nation_slug = nation_slug
      @base_url = "https://#{nation_slug}.nationbuilder.com"
    end
    
    def signups
      @signups ||= SignupsApi.new(self)
    end
    
    def get(path, params: {})
      request(:get, path, query: params)
    end
    
    def post(path, body: {})
      request(:post, path, body: body.to_json)
    end
    
    def request(method, path, **options)
      installation = Installation.active.find_by(nation_slug: @nation_slug)
      raise AuthenticationError, "Nation not installed" unless installation
      
      # Refresh tokens if needed
      installation = refresh_if_needed(installation)
      
      # Make request with current tokens
      url = "#{@base_url}#{path}"
      headers = {
        "Authorization" => "Bearer #{installation.access_token}",
        "Content-Type" => "application/json",
        "Accept" => "application/json"
      }
      
      response = self.class.send(method, url, headers: headers, **options)
      
      # Handle 401 (try refresh and retry once)
      if response.code == 401
        installation = refresh_tokens!(installation)
        headers["Authorization"] = "Bearer #{installation.access_token}"
        response = self.class.send(method, url, headers: headers, **options)
      end
      
      # Update last_used timestamp
      installation.touch_last_used!
      
      if response.success?
        JSON.parse(response.body)
      else
        raise ApiError, "API request failed: #{response.code} - #{response.body}"
      end
    end
    
    private
    
    def refresh_if_needed(installation)
      if installation.expiring_soon?(30.minutes)
        refresh_tokens!(installation)
      else
        installation
      end
    end
    
    def refresh_tokens!(installation)
      token_service = OAuth::TokenService.new(@nation_slug)
      new_tokens = token_service.refresh_tokens(installation.refresh_token)
      
      installation.update!(
        access_token: new_tokens["access_token"],
        refresh_token: new_tokens["refresh_token"],
        expires_at: Time.at(new_tokens["expires_at"]),
        last_used_at: Time.current
      )
      
      installation.reload
    end
  end
  
  # Signups API wrapper
  class SignupsApi
    def initialize(client)
      @client = client
    end
    
    def me
      @client.get("/api/v2/signups/me")
    end
  end
end
