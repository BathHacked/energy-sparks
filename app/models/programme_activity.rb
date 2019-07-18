# == Schema Information
#
# Table name: programme_activities
#
#  activity_id      :bigint(8)        not null
#  activity_type_id :bigint(8)
#  id               :bigint(8)        not null, primary key
#  position         :integer          default(0), not null
#  programme_id     :bigint(8)        not null
#
# Indexes
#
#  index_programme_activities_on_activity_type_id  (activity_type_id)
#  programme_activity_uniq                         (programme_id,activity_id) UNIQUE
#

class ProgrammeActivity < ApplicationRecord
  belongs_to :activity_type
  belongs_to :activity
  belongs_to :programme
end
