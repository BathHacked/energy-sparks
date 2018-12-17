# == Schema Information
#
# Table name: school_onboardings
#
#  calendar_area_id            :bigint(8)
#  contact_email               :string           not null
#  created_at                  :datetime         not null
#  created_user_id             :bigint(8)
#  id                          :bigint(8)        not null, primary key
#  notes                       :text
#  school_group_id             :bigint(8)
#  school_id                   :bigint(8)
#  school_name                 :string           not null
#  solar_pv_tuos_area_id       :bigint(8)
#  updated_at                  :datetime         not null
#  uuid                        :string           not null
#  weather_underground_area_id :bigint(8)
#
# Indexes
#
#  index_school_onboardings_on_calendar_area_id             (calendar_area_id)
#  index_school_onboardings_on_created_user_id              (created_user_id)
#  index_school_onboardings_on_school_group_id              (school_group_id)
#  index_school_onboardings_on_school_id                    (school_id)
#  index_school_onboardings_on_solar_pv_tuos_area_id        (solar_pv_tuos_area_id)
#  index_school_onboardings_on_uuid                         (uuid) UNIQUE
#  index_school_onboardings_on_weather_underground_area_id  (weather_underground_area_id)
#
# Foreign Keys
#
#  fk_rails_...  (calendar_area_id => areas.id) ON DELETE => restrict
#  fk_rails_...  (created_user_id => users.id) ON DELETE => nullify
#  fk_rails_...  (school_group_id => school_groups.id) ON DELETE => restrict
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#  fk_rails_...  (solar_pv_tuos_area_id => areas.id) ON DELETE => restrict
#  fk_rails_...  (weather_underground_area_id => areas.id) ON DELETE => restrict
#

class SchoolOnboarding < ApplicationRecord
  validates :school_name, :contact_email, presence: true

  belongs_to :school
  belongs_to :school_group
  belongs_to :calendar_area
  belongs_to :weather_underground_area
  belongs_to :solar_pv_tuos_area
  belongs_to :created_user, class_name: 'User'

  has_many :events, class_name: 'SchoolOnboardingEvent'

  def has_event?(event_name)
    events.where(event: event_name).any?
  end

  def to_param
    uuid
  end
end
