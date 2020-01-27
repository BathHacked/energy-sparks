# == Schema Information
#
# Table name: team_members
#
#  created_at  :datetime         not null
#  description :text
#  id          :bigint(8)        not null, primary key
#  position    :integer          default(0), not null
#  title       :string           not null
#  updated_at  :datetime         not null
#

class TeamMember < ApplicationRecord
  has_one_attached :image

  validates :title, :image, presence: true
  validates :position, numericality: true, presence: true
end