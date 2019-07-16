# frozen_string_literal: true

require 'dashboard'

module Amr
  class ValidateAndPersistReadingsService
    def initialize(active_record_school)
      @active_record_school = active_record_school
    end

    def perform
      return unless @active_record_school.meters_with_readings.any?
      @meter_collection = AnalyticsUnvalidatedMeterCollectionFactory.new(@active_record_school).build

      p "Validate and persist readings for #{@active_record_school.name} #{@active_record_school.id}"
      AggregateDataService.new(@meter_collection).validate_meter_data
      UpsertValidatedReadings.new(@meter_collection).perform
      p "ValidateAndPersistReadingsService Report for #{@active_record_school.name}"
      @meter_collection
    end
  end
end
