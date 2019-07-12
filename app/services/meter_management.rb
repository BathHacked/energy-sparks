class MeterManagement
  def initialize(meter)
    @meter = meter
  end

  def process_creation!
    assign_amr_data_feed_readings
  end

  def process_mpan_mpnr_change!
    @meter.transaction do
      remove_amr_validated_readings
      nullify_amr_data_feed_readings
      assign_amr_data_feed_readings
    end
  end

  def delete_meter!
    @meter.transaction do
      Rails.logger.info "Removing validated readings"
      remove_amr_validated_readings
      Rails.logger.info "Nullify amr readings"
      nullify_amr_data_feed_readings
      Rails.logger.info "Delete meter"
      @meter.delete
    end
  end

private

  def assign_amr_data_feed_readings
    AmrDataFeedReading.where(mpan_mprn: @meter.mpan_mprn).update_all(meter_id: @meter.id)
  end

  def remove_amr_validated_readings
    @meter.amr_validated_readings.delete_all
    AggregateSchoolService.new(@meter.school).invalidate_cache
  end

  def nullify_amr_data_feed_readings
    @meter.amr_data_feed_readings.update_all(meter_id: nil)
  end
end
