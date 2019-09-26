module Admin
  class SettingsController < AdminController
    def show
      @settings = SiteSettings.current
    end

    def update
      SiteSettings.create!(settings_params)
      redirect_to admin_settings_path, notice: 'Settings updated'
    end

  private

    def settings_params
      params.require(:site_settings).permit(:message_for_no_contacts, :management_priorities_limit)
    end
  end
end
