require 'rails_helper'

module Amr
  describe N3rgyUpserter do

    let(:meter)           { create(:electricity_meter) }
    let(:config)          { create(:amr_data_feed_config)}
    let(:end_date)     { Date.today }
    let(:start_date) { end_date - 1 }
    let(:readings)        {
      {
        meter.meter_type => {
            mpan_mprn:        meter.mpan_mprn,
            readings:         { start_date: OneDayAMRReading.new(meter.mpan_mprn, start_date, 'ORIG', nil, start_date, Array.new(48, 0.25)) },
            missing_readings: []
          }
      }
    }
    let(:import_log)    { create(:amr_data_feed_import_log) }

    it "inserts new readings" do
      expect( AmrDataFeedReading.count ).to eql 0
      upserter = Amr::N3rgyUpserter.new(meter: meter, config: config, readings: readings, import_log: import_log)
      upserter.perform
      expect( AmrDataFeedReading.count ).to eql 1
    end

    it "handles empty reading for meter" do
      expect( AmrDataFeedReading.count ).to eql 0
      readings[meter.meter_type][:readings] = {}
      upserter = Amr::N3rgyUpserter.new(meter: meter, config: config, readings: readings, import_log: import_log)
      upserter.perform
      expect( AmrDataFeedReading.count ).to eql 0
    end

    it "does not create meters" do
      readings = {
        meter.meter_type => {
            mpan_mprn:      meter.mpan_mprn,
            readings:       { start_date: OneDayAMRReading.new("1234567890009", start_date, 'ORIG', nil, start_date, Array.new(48, 0.25)) },
            missing_readings: []
          }
      }
      upserter = Amr::N3rgyUpserter.new(meter: meter, config: config, readings: readings, import_log: import_log)
      upserter.perform
      expect( Meter.count ).to eql 1
      expect( Meter.first.id ).to eql meter.id
    end

    it "does not log any errors or warnings with valid data" do
      upserter = Amr::N3rgyUpserter.new(meter: meter, config: config, readings: readings, import_log: import_log)
      upserter.perform
      amr_data_feed_import_log = AmrDataFeedImportLog.last
      expect(amr_data_feed_import_log.error_messages).to be_blank
      expect(amr_data_feed_import_log.amr_reading_warnings).to be_empty
    end

  end
end