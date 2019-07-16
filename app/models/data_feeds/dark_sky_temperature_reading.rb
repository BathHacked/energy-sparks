# frozen_string_literal: true

# == Schema Information
#
# Table name: dark_sky_temperature_readings
#
#  area_id                 :bigint(8)
#  created_at              :datetime         not null
#  id                      :bigint(8)        not null, primary key
#  reading_date            :date             not null
#  temperature_celsius_x48 :decimal(, )      not null, is an Array
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_dark_sky_temperature_readings_on_area_id                   (area_id)
#  index_dark_sky_temperature_readings_on_area_id_and_reading_date  (area_id,reading_date) UNIQUE
#

module DataFeeds
  class DarkSkyTemperatureReading < ApplicationRecord
    def self.download_all_data
      <<~QUERY
        SELECT a.title, dstr.reading_date, dstr.temperature_celsius_x48
        FROM  dark_sky_temperature_readings dstr, areas a
        WHERE dstr.area_id = a.id
        ORDER BY a.id, dstr.reading_date ASC
      QUERY
    end

    def self.download_for_area_id(area_id)
      <<~QUERY
        SELECT a.title, dstr.reading_date, dstr.temperature_celsius_x48
        FROM  dark_sky_temperature_readings dstr, areas a
        WHERE dstr.area_id = a.id
        AND   dstr.area_id = #{area_id}
        ORDER BY a.id, dstr.reading_date ASC
      QUERY
    end
  end
end
