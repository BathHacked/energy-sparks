class RemoveAreaFieldFromAmrConfig < ActiveRecord::Migration[5.2]
  def change
    remove_column :amr_data_feed_configs, :area_id
  end
end
