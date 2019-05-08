# == Schema Information
#
# Table name: activity_types
#
#  active                 :boolean          default(TRUE)
#  activity_category_id   :bigint(8)
#  badge_name             :string
#  created_at             :datetime         not null
#  custom                 :boolean          default(FALSE)
#  data_driven            :boolean          default(FALSE)
#  deprecated_description :text
#  id                     :bigint(8)        not null, primary key
#  name                   :string
#  repeatable             :boolean          default(TRUE)
#  score                  :integer
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_activity_types_on_active                (active)
#  index_activity_types_on_activity_category_id  (activity_category_id)
#
# Foreign Keys
#
#  fk_rails_...  (activity_category_id => activity_categories.id)
#

class ActivityType < ApplicationRecord
  belongs_to :activity_category

  has_and_belongs_to_many :key_stages, join_table: :activity_type_key_stages
  has_and_belongs_to_many :impacts, join_table: :activity_type_impacts
  has_and_belongs_to_many :subjects, join_table: :activity_type_subjects
  has_and_belongs_to_many :topics, join_table: :activity_type_topics
  has_and_belongs_to_many :activity_timings, join_table: :activity_type_timings

  where(active: true, custom: false, data_driven: true, repeatable: true)

  scope :active, -> { where(active: true) }
  scope :repeatable, -> { where(repeatable: true) }
  scope :data_driven, -> { where(data_driven: true) }
  scope :random_suggestions, -> { active.repeatable }
  scope :custom_last, -> { order(:custom) }
  validates_presence_of :name, :activity_category_id, :score
  validates_uniqueness_of :name, scope: :activity_category_id
  validates_uniqueness_of :badge_name, allow_blank: true, allow_nil: true
  validates :score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  has_many :activity_type_suggestions
  has_many :suggested_types, through: :activity_type_suggestions

  accepts_nested_attributes_for :activity_type_suggestions, reject_if: proc { |attributes| attributes[:suggested_type_id].blank? }, allow_destroy: true

  def key_stage_list
    key_stages.map(&:name).sort.join(', ')
  end

  def name_with_key_stages
    "#{name} (#{key_stage_list})"
  end
end
