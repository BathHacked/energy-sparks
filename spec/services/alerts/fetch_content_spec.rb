require 'rails_helper'

describe Alerts::FetchContent do

  let(:school)  { create(:school) }
  let!(:alert){ create(:alert, school: school, rating: rating)}

  let(:rating){ 5.0 }
  let(:active){ true }
  let!(:alert){ create(:alert, school: school, rating: rating)}
  let!(:alert_type_rating){ create :alert_type_rating, alert_type: alert.alert_type, rating_from: 1, rating_to: 6, find_out_more_active: true}

  let(:service) { Alerts::FetchContent.new(alert) }

  context 'with content' do

    let!(:content_version){ create :alert_type_rating_content_version, alert_type_rating: alert_type_rating }

    it 'finds matching content for the alert type that matches the rating' do
      expect(service.content_versions(scope: :find_out_more)).to match_array([content_version])
    end

    context 'with a newer content version' do
      let!(:new_content_version){ create(:alert_type_rating_content_version, alert_type_rating: alert_type_rating) }

      before do
        content_version.update!(replaced_by: new_content_version)
      end

      it 'uses the latest version of the content' do
        expect(service.content_versions(scope: :find_out_more)).to match_array([new_content_version])
      end
    end

    context 'where the rating is too precise but rounds down' do
      let(:rating){ 6.02 }
      it 'still returns the content' do
        expect(service.content_versions(scope: :find_out_more)).to match_array([content_version])
      end
    end

    context 'where the rating rounds up' do
      let(:rating){ 6.09 }
      it 'does not return any content' do
        expect(service.content_versions(scope: :find_out_more)).to match_array([])
      end
    end

    context 'where the rating is nil' do
      let(:rating){ nil }
      it 'does not return any content' do
        expect(service.content_versions(scope: :find_out_more)).to match_array([])
      end
    end

    context 'where the rating does not match the range' do
      let!(:alert_type_rating){ create :alert_type_rating, alert_type: create(:alert_type), rating_from: 1, rating_to: 4}
      it 'returns no content' do
        expect(service.content_versions(scope: :find_out_more)).to match_array([])
      end
    end

    context 'the scope is inactive' do
      let!(:alert_type_rating){ create :alert_type_rating, alert_type: create(:alert_type), rating_from: 1, rating_to: 6, find_out_more_active: false}
      it 'returns no content' do
        expect(service.content_versions(scope: :find_out_more)).to match_array([])
      end
    end
  end

  context 'when there is no content' do
    it 'returns no content' do
      expect(service.content_versions(scope: :find_out_more)).to match_array([])
    end
  end
end
