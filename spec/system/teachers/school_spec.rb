require 'rails_helper'

RSpec.describe "teachers school view", type: :system do

  let(:school_name) { 'Theresa Green Infants'}
  let!(:school)     { create(:school, name: school_name, weather_underground_area: create(:weather_underground_area), solar_pv_tuos_area: create(:solar_pv_tuos_area)) }
  let!(:user)       { create(:user, role: :school_admin, school: school)}

  describe 'when logged in as teacher' do
    before(:each) do
      sign_in(user)
    end

    it 'I can visit the teacher dashboard' do
      visit teachers_school_path(school)
      expect(page.has_content? school_name).to be true
    end
  end

  describe 'when the school is gas only I can visit the teacher dashboard and it only shows me a ' do
    let!(:gas_meter)  { create(:gas_meter, school: school)}
    it 'gas chart' do
      visit teachers_school_path(school)
      expect(page.has_content? 'Electricity').to be false
      expect(page.has_content? 'Gas').to be true
    end
  end

  describe 'has a loading page which redirects to the right place', js: true do

    let!(:gas_meter)  { create(:gas_meter, school: school)}

    before(:each) do
      allow(AggregateSchoolService).to receive(:caching_off?).and_return(false, true)
      allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(school)
      allow_any_instance_of(ChartData).to receive(:data).and_return([])
    end

    it 'redirects to the loading page and then back to the dashboard page once complete' do
      visit teachers_school_path(school)

      expect(page.has_content? 'Gas').to be true
      expect(page.has_content? 'processing').to be false
    end

    it 'redirects by default to the dashboard page' do
      visit school_aggregated_meter_collection_path(school)

      expect(page.has_content? 'Gas').to be true
      expect(page.has_content? 'processing').to be false
    end
  end

  describe 'when the school is electricity only I can visit the teacher dashboard and it only shows me a ' do
    let!(:electricity_meter)  { create(:electricity_meter, school: school)}
    it 'electricity chart' do
      visit teachers_school_path(school)
      expect(page.has_content? 'Electricity').to be true
      expect(page.has_content? 'Gas').to be false
    end
  end
end

