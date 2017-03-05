class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_ga_code

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  def after_sign_in_path_for(resource)
    if resource.school.present?
      return resource.school
    end
    root_path
  end

private

  def set_ga_code
    @analytics_code = ENV['GOOGLE_ANALYTICS_CODE']
  end

  def current_school
    current_user.school if current_user && current_user.school_admin?
  end
end
