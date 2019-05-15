# == Schema Information
#
# Table name: alert_type_rating_content_versions
#
#  alert_type_rating_id               :bigint(8)        not null
#  colour                             :integer          default("red"), not null
#  created_at                         :datetime         not null
#  email_content                      :text
#  email_end_date                     :date
#  email_start_date                   :date
#  email_title                        :string
#  find_out_more_chart_title          :string           default("")
#  find_out_more_chart_variable       :text             default("none")
#  find_out_more_content              :text
#  find_out_more_end_date             :date
#  find_out_more_start_date           :date
#  find_out_more_title                :string
#  id                                 :bigint(8)        not null, primary key
#  pupil_dashboard_alert_end_date     :date
#  pupil_dashboard_alert_start_date   :date
#  pupil_dashboard_title              :string
#  replaced_by_id                     :integer
#  sms_content                        :string
#  sms_end_date                       :date
#  sms_start_date                     :date
#  teacher_dashboard_alert_end_date   :date
#  teacher_dashboard_alert_start_date :date
#  teacher_dashboard_title            :string
#  updated_at                         :datetime         not null
#
# Indexes
#
#  fom_content_v_fom_id  (alert_type_rating_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_type_rating_id => alert_type_ratings.id) ON DELETE => cascade
#

class AlertTypeRatingContentVersion < ApplicationRecord
  belongs_to :alert_type_rating
  belongs_to :replaced_by, class_name: 'AlertTypeRatingContentVersion', foreign_key: :replaced_by_id

  enum colour: [:red, :yellow, :green]

  validates :colour, presence: true

  validates :teacher_dashboard_title,
    presence: true,
    if: ->(content) { content.alert_type_rating && content.alert_type_rating.teacher_dashboard_alert_active?},
    on: :create
  validates :pupil_dashboard_title,
    presence: true,
    if: ->(content) { content.alert_type_rating && content.alert_type_rating.pupil_dashboard_alert_active?},
    on: :create
  validates :find_out_more_title, :find_out_more_content,
    presence: true,
    if: ->(content) { content.alert_type_rating && content.alert_type_rating.find_out_more_active?},
    on: :create
  validates :sms_content,
    presence: true,
    if: ->(content) { content.alert_type_rating && content.alert_type_rating.sms_active?},
    on: :create
  validates :email_title, :email_content,
    presence: true,
    if: ->(content) { content.alert_type_rating && content.alert_type_rating.email_active?},
    on: :create

  validate on: :create do |content|
    if content.alert_type_rating
      content.timings_are_correct(:find_out_more) if content.alert_type_rating.find_out_more_active?
      content.timings_are_correct(:sms) if content.alert_type_rating.sms_active?
      content.timings_are_correct(:email) if content.alert_type_rating.email_active?
      content.timings_are_correct(:teacher_dashboard_alert) if content.alert_type_rating.teacher_dashboard_alert_active?
      content.timings_are_correct(:pupil_dashboard_alert) if content.alert_type_rating.pupil_dashboard_alert_active?
    end
  end

  scope :latest, -> { where(replaced_by_id: nil) }


  def self.template_fields
    [
      :pupil_dashboard_title, :teacher_dashboard_title,
      :find_out_more_title, :find_out_more_content,
      :email_title, :email_content, :sms_content,
      :find_out_more_chart_variable, :find_out_more_chart_title
    ]
  end

  def self.timing_fields
    [
      :teacher_dashboard_alert_start_date, :teacher_dashboard_alert_end_date,
      :pupil_dashboard_alert_start_date, :pupil_dashboard_alert_end_date,
      :find_out_more_start_date, :find_out_more_end_date,
      :sms_start_date, :sms_end_date,
      :email_start_date, :email_end_date
    ]
  end

  def timings_are_correct(scope)
    start_date_field = :"#{scope}_start_date"
    end_date_field = :"#{scope}_end_date"
    start_date = self[start_date_field]
    end_date = self[end_date_field]
    if start_date.present? && end_date.present?
      if end_date < start_date
        errors.add(end_date_field, 'must be on or after start date')
      end
    end
  end
end
