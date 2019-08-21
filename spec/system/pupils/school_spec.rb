require 'rails_helper'

RSpec.describe "pupils school view", type: :system do

  let(:school_name) { 'Theresa Green Infants'}
  let!(:school) { create(:school, name: school_name)}
  let!(:user)  { create(:user, role: :staff, school: school)}


  let(:equivalence_type)  { create(:equivalence_type )}
  let(:equivalence_type_content)  { create(:equivalence_type_content_version, equivalence_type: equivalence_type, equivalence: 'Your school spent {{gbp}} on electricity last year!')}
  let!(:equivalence)  { create(:equivalence, school: school, content_version: equivalence_type_content, data: {'gbp' => {'formatted_equivalence' => '£2.00'}})}

  describe 'when logged in as pupil' do
    before(:each) do
      sign_in(user)
    end

    it 'I can visit the pupil dashboard' do
      visit pupils_school_path(school)
      expect(page).to have_content(school_name)
      expect(page).to have_content('Your school spent £2.00 on electricity last year!')
    end
  end
end
