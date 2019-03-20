class AlertMailer < ApplicationMailer
  add_template_helper(AlertsChartsHelper)

  def alert_email
    @email_address = params[:email_address]
    @alerts = Alert.find(params[:alert_ids])
    @school = School.find(params[:school_id])
    @unsubscribe_emails = User.where(school: @school, role: :school_admin).pluck(:email).join(', ')

    make_bootstrap_mail(to: @email_address, subject: 'Energy Sparks alerts')
  end
end
