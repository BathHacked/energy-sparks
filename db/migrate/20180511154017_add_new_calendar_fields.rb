class AddNewCalendarFields < ActiveRecord::Migration[5.1]
  def change
    add_column :calendars, :start_year,   :integer, index: true
    add_column :calendars, :end_year,     :integer, index: true
    add_column :calendars, :based_on_id,  :integer, index: true
    add_column :calendars, :group_id,      :integer, index: true
    add_column :calendars, :template,     :boolean, default: false
    rename_column :calendars, :name, :title
  end
end
