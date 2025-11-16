require 'rails_helper'

RSpec.describe CustomFieldValue, type: :model do
  subject { build(:custom_field_value) }

  describe 'validations' do
    it { should validate_presence_of(:building) }
    it { should validate_presence_of(:custom_field) }
    it { should validate_uniqueness_of(:building_id).scoped_to(:custom_field_id) }

    context 'value validation' do
      let(:client) { create(:client) }
      let(:building) { create(:building, client: client) }
      let(:number_field) { create(:custom_field, :number, client: client) }

      it 'validates value matches field type' do
        value = build(:custom_field_value, building: building, custom_field: number_field, value: "not_a_number")
        expect(value).not_to be_valid
        expect(value.errors[:value]).to include("must be a number")
      end

      it 'is valid with matching value type' do
        value = build(:custom_field_value, building: building, custom_field: number_field, value: "123")
        expect(value).to be_valid
      end
    end
  end

  describe 'associations' do
    it { should belong_to(:building) }
    it { should belong_to(:custom_field) }
  end
end
