class OAuthController < ApplicationController
  # Step 1: User arrives from NB App Store with ?nation=slug
  def install
    nation_slug = params[:nation]
    
    unless nation_slug.present?
      # Show error page instead of redirecting (prevents loop)
      render html: "<h1>Missing Nation Parameter</h1><p>Please visit this URL with ?nation=yourslug</p><p>Example: http://localhost:3000/?nation=yourslug</p>".html_safe, status: :bad_request
      return
    end
    
    # Check if already installed
    installation = Installation.active.find_by(nation_slug: nation_slug)
    if installation
      # Already installed, go straight to dashboard
      session[:nation_slug] = nation_slug
      redirect_to dashboard_path, notice: "Already connected to #{nation_slug}"
      return
    end
    
    # Not installed, start OAuth flow
    auth_service = OAuth::AuthenticationService.new(
      session: session,
      nation_slug: nation_slug
    )
    
    redirect_to auth_service.authorization_url, allow_other_host: true
  end
  
  # Step 2: NationBuilder redirects back with code
  def callback
    nation_slug = params[:nation] || session[:nation_slug]
    
    Rails.logger.info "=== OAuth Callback Debug ==="
    Rails.logger.info "Nation slug: #{nation_slug}"
    Rails.logger.info "Code: #{params[:code]}"
    Rails.logger.info "State: #{params[:state]}"
    Rails.logger.info "Session nation: #{session[:nation_slug]}"
    
    auth_service = OAuth::AuthenticationService.new(
      session: session,
      nation_slug: nation_slug
    )
    
    installation = auth_service.handle_callback(
      code: params[:code],
      state: params[:state]
    )
    
    Rails.logger.info "Installation saved: #{installation.nation_slug}"
    redirect_to dashboard_path, notice: "Successfully connected to #{installation.nation_slug}!"
  rescue => e
    Rails.logger.error "OAuth callback error: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.first(10).join("\n")
    redirect_to root_path, alert: "Authentication failed: #{e.message}"
  end
  
  # Step 3: User uninstalls
  def uninstall
    nation_slug = session[:nation_slug]
    
    if nation_slug
      auth_service = OAuth::AuthenticationService.new(
        session: session,
        nation_slug: nation_slug
      )
      auth_service.logout
    end
    
    reset_session
    redirect_to root_path, notice: "Disconnected from NationBuilder"
  end
end
