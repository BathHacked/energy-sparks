module Alerts
  class GenerateSubscriptionEvents
    def initialize(school, content_generation_run:)
      @school = school
      @content_generation_run = content_generation_run
    end

    def perform(frequency: [])
      @school.alerts.joins(:alert_type).where(alert_types: { frequency: frequency }).latest.each do |alert|
        content_and_contacts_for(alert, :email) do |content_version, find_out_more, contact|
          first_or_create_alert_subscription_event(contact, alert, content_version, find_out_more, :email) if contact.email_address?
        end
        content_and_contacts_for(alert, :sms) do |content_version, find_out_more, contact|
          first_or_create_alert_subscription_event(contact, alert, content_version, find_out_more, :sms) if contact.mobile_phone_number?
        end
      end
    end

  private

    def content_and_contacts_for(alert, scope)
      FetchContent.new(alert).content_versions(scope: scope).each do |content_version|
        find_out_more = @content_generation_run.find_out_mores.where(content_version: content_version).first
        @school.contacts.each do |contact|
          yield content_version, find_out_more, contact
        end
      end
    end

    def first_or_create_alert_subscription_event(contact, alert, content_version, find_out_more, communication_type)
      AlertSubscriptionEvent.create_with(
        content_version: content_version,
        content_generation_run: @content_generation_run,
        find_out_more: find_out_more
      ).find_or_create_by!(
        contact: contact, alert: alert, communication_type: communication_type
      )
    end
  end
end
