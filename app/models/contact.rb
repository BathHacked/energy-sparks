# == Schema Information
#
# Table name: contacts
#
#  description         :text
#  email_address       :text
#  id                  :bigint(8)        not null, primary key
#  mobile_phone_number :text
#  name                :text
#  school_id           :bigint(8)        not null
#  staff_role_id       :bigint(8)
#  user_id             :bigint(8)
#
# Indexes
#
#  index_contacts_on_school_id      (school_id)
#  index_contacts_on_staff_role_id  (staff_role_id)
#  index_contacts_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#  fk_rails_...  (staff_role_id => staff_roles.id) ON DELETE => restrict
#  fk_rails_...  (user_id => users.id) ON DELETE => cascade
#
class Contact < ApplicationRecord
  belongs_to :school, inverse_of: :contacts
  belongs_to :user, optional: true
  belongs_to :staff_role, optional: true
  has_many   :alert_subscription_events
  has_many   :alert_type_rating_unsubscriptions

  validates :mobile_phone_number, presence: true, unless: ->(contact) { contact.email_address.present? }
  validates :email_address,       presence: true, unless: ->(contact) { contact.mobile_phone_number.present? }
  validates :description,         presence: true, unless: ->(contact) { contact.name.present? }
  validates :name,                presence: true, unless: ->(contact) { contact.description.present? }

  def display_name
    "#{name} #{description}"
  end

  def popualate_from_user(user)
    self.user = user
    self.name = user.display_name
    self.email_address = user.email
    self.staff_role = user.staff_role
  end
end
