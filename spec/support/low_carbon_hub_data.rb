RSpec.shared_context  "low carbon hub data", shared_context: :metadata do

  let!(:school)               { create(:school) }
  let(:low_carbon_hub_api)    { double("low_carbon_hub_api") }
  let(:rbee_meter_id)         { "216057958" }
  let!(:amr_data_feed_config) { create(:amr_data_feed_config, process_type: :low_carbon_hub_api) }
  let(:info_text)             { 'Some info' }
  let(:information)           { { info: info_text } }
  let(:start_date)            { Date.parse('02/08/2016') }
  let(:end_date)              { start_date + 1.day }
  let(:readings)              {
    {
      solar_pv: {
        mpan_mprn: 70000000123085,
        readings: {
          start_date => OneDayAMRReading.new(70000000123085, start_date, 'ORIG', nil, start_date, Array.new(48, 0.25)),
          end_date => OneDayAMRReading.new(70000000123085, end_date, 'ORIG', nil, end_date, Array.new(48, 0.5))
        }
      },
      electricity: {
        mpan_mprn: 90000000123085,
        readings: {
          start_date => OneDayAMRReading.new(90000000123085, start_date, 'ORIG', nil, start_date, Array.new(48, 0.25)),
          end_date => OneDayAMRReading.new(90000000123085, end_date, 'ORIG', nil, end_date, Array.new(48, 0.5))
        }
      },
      exported_solar_pv: {
        mpan_mprn: 60000000123085,
        readings: {
          start_date => OneDayAMRReading.new(60000000123085, start_date, 'ORIG', nil, start_date, Array.new(48, 0.25)),
          end_date => OneDayAMRReading.new(60000000123085, end_date, 'ORIG', nil, end_date, Array.new(48, 0.5))
        }
      },
    }
  }

end

RSpec.configure do |rspec|
  rspec.include_context "low carbon hub data", include_shared: true
end