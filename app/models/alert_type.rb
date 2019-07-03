# == Schema Information
#
# Table name: alert_types
#
#  analysis     :text
#  class_name   :text
#  description  :text             not null
#  frequency    :integer
#  fuel_type    :integer
#  has_ratings  :boolean          default(TRUE)
#  id           :bigint(8)        not null, primary key
#  show_ratings :boolean          default(TRUE)
#  source       :integer          default("analytics"), not null
#  sub_category :integer
#  title        :text
#

class AlertType < ApplicationRecord
  has_many :alerts,                     dependent: :destroy
  has_many :alert_subscription_events,  dependent: :destroy

  has_many :ratings, class_name: 'AlertTypeRating'

  enum source: [:analytics, :system]
  enum fuel_type: [:electricity, :gas]
  enum sub_category: [:hot_water, :heating, :baseload]
  enum frequency: [:termly, :weekly, :before_each_holiday]

  scope :electricity,   -> { where(fuel_type: :electricity) }
  scope :gas,           -> { where(fuel_type: :gas) }
  scope :no_fuel,       -> { where(fuel_type: nil) }

  validates_presence_of :description, :frequency

  def display_fuel_type
    return 'No fuel type' if fuel_type.nil?
    fuel_type.humanize
  end

  def cleaned_template_variables
    # TODO: make the analytics code remove the £ sign
    class_name.constantize.front_end_template_variables.deep_transform_keys do |key|
      :"#{key.to_s.gsub('£', 'gbp')}"
    end
  end

  def available_charts
    class_name.constantize.front_end_template_charts.map { |variable_name, values| [values[:description], variable_name] }
  end
end
