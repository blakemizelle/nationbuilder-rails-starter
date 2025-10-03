class OAuthController < ApplicationController
  # Step 1: User arrives from NB App Store with ?nation=slug OR enters it manually
  def install
    nation_slug = params[:nation]

    unless nation_slug.present?
      # Show landing page with nation input form
      render :landing
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

    auth_service = OAuth::AuthenticationService.new(
      session: session,
      nation_slug: nation_slug
    )

    installation = auth_service.handle_callback(
      code: params[:code],
      state: params[:state]
    )

    redirect_to dashboard_path, notice: "Successfully connected to #{installation.nation_slug}!"
  rescue => e
    Rails.logger.error "OAuth callback error: #{e.class} - #{e.message}"
    # Redirect back to install with nation param if we have it
    if nation_slug.present?
      redirect_to root_path(nation: nation_slug), alert: "Authentication failed: #{e.message}"
    else
      render html: "<h1>Authentication Failed</h1><p>#{e.message}</p><p><a href='/'>Try again</a></p>".html_safe, status: :internal_server_error
    end
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
