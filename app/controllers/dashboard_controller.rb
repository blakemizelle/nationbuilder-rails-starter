class DashboardController < ApplicationController
  before_action :require_installation
  
  def show
    @installation = Installation.active.find_by!(nation_slug: @nation_slug)
    
    # Fetch user info from NationBuilder
    client = NationBuilder::ApiClient.new(@nation_slug)
    @user_info = client.signups.me
  rescue NationBuilder::ApiClient::AuthenticationError => e
    redirect_to root_path, alert: "Please install the app first"
  rescue => e
    Rails.logger.error "Dashboard error: #{e.message}"
    redirect_to root_path, alert: "Error loading dashboard: #{e.message}"
  end
  
  private
  
  def require_installation
    @nation_slug = params[:nation] || session[:nation_slug]
    
    unless @nation_slug && Installation.active.exists?(nation_slug: @nation_slug)
      redirect_to root_path, alert: "Please install the app first"
    end
  end
end
