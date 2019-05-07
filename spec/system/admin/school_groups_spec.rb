require 'rails_helper'

RSpec.describe 'school groups', :school_groups, type: :system do

  let!(:admin)                { create(:user, role: 'admin') }
  let!(:scoreboard)           { create(:scoreboard, name: 'BANES and Frome') }
  let!(:dark_sky_weather_area) { create(:dark_sky_area, title: 'BANES dark sky weather') }

  describe 'when logged in' do
    before(:each) do
      sign_in(admin)
    end

    it 'can add a new school group with validation' do
      visit school_groups_path
      click_on 'New School group'
      click_on 'Create School group'
      expect(page).to have_content("Name can't be blank")

      fill_in 'Name', with: 'BANES'
      fill_in 'Description', with: 'Bath & North East Somerset'
      select 'BANES and Frome', from: 'Scoreboard'
      select 'BANES dark sky weather', from: 'Default Dark Sky Weather Data Feed Area'

      click_on 'Create School group'

      expect(SchoolGroup.where(name: 'BANES').count).to eq(1)
    end

    it 'can edit a school group' do
      school_group = create(:school_group, name: 'BANES')
      visit school_groups_path
      click_on 'Edit'
      fill_in 'Name', with: 'B & NES'
      click_on 'Update School group'

      school_group.reload
      expect(school_group.name).to eq('B & NES')
    end

    it 'can delete a school group' do
      school_group = create(:school_group)
      visit school_groups_path

      expect {
        click_on 'Delete'
      }.to change{SchoolGroup.count}.from(1).to(0)
      expect(page).to have_content('There are no School groups')
    end
  end

end
