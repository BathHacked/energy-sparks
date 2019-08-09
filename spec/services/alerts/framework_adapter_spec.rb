require 'rails_helper'

describe Alerts::FrameworkAdapter do

  let(:school) { build(:school) }
  let(:aggregate_school) { double :aggregate_school }
  let!(:alert_type) { create :alert_type, source: :system}
  let(:gas_date) { Date.parse('2019-01-01') }
  let(:alert) do
    Alert.new(
      run_on: gas_date,
      alert_type: alert_type,
      rating: 5.0 ,
      enough_data: :enough,
      template_data: {template: 'variables'},
      chart_data: {chart: 'variables'},
      table_data: {table: 'variables'}
    )
  end

  it 'uses the adapters to create an alert object from the returned reports' do
    expect(Alerts::FrameworkAdapter.new(alert_type, school, gas_date, aggregate_school).analyse).to have_attributes alert.attributes
  end
end
