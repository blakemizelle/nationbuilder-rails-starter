class DashboardController < ApplicationController
  before_action :require_installation

  def show
    @installation = Installation.active.find_by!(nation_slug: @nation_slug)

    # Fetch user info from NationBuilder
    client = NationBuilder::ApiClient.new(@nation_slug)
    @user_info = client.signups.me
  rescue NationBuilder::ApiClient::AuthenticationError => e
    redirect_to root_path(nation: @nation_slug), alert: "Please install the app first"
  rescue => e
    Rails.logger.error "Dashboard error: #{e.message}"
    redirect_to root_path(nation: @nation_slug), alert: "Error loading dashboard: #{e.message}"
  end

  private

  def require_installation
    @nation_slug = params[:nation] || session[:nation_slug]

    unless @nation_slug && Installation.active.exists?(nation_slug: @nation_slug)
      if @nation_slug.present?
        redirect_to root_path(nation: @nation_slug), alert: "Please install the app first"
      else
        render html: "<h1>Missing Nation</h1><p>Please access this app from NationBuilder App Store or visit with ?nation=yourslug</p>".html_safe, status: :bad_request
      end
    end
  end
end
