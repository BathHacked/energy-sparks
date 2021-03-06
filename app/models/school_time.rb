# == Schema Information
#
# Table name: school_times
#
#  closing_time :integer          default(1520)
#  day          :integer
#  id           :bigint(8)        not null, primary key
#  opening_time :integer          default(850)
#  school_id    :bigint(8)        not null
#
# Indexes
#
#  index_school_times_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#

class SchoolTime < ApplicationRecord
  belongs_to :school

  enum day: [:monday, :tuesday, :wednesday, :thursday, :friday]

  validates :opening_time, :closing_time, presence: true
  validates :opening_time, :closing_time, numericality: {
    only_integer: true, allow_nil: true,
    less_than_or_equal_to: 2359,
    greater_than_or_equal_to: 0,
    message: 'must be between 0000 and 2359'
  }

  def opening_time=(time)
    time = time.delete(':') if time.respond_to?(:delete)
    super(time)
  end

  def closing_time=(time)
    time = time.delete(':') if time.respond_to?(:delete)
    super(time)
  end
end
