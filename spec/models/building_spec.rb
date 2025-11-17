require 'rails_helper'

RSpec.describe Building, type: :model do
  subject { build(:building) }

  describe 'validations' do
    it { should validate_presence_of(:street) }
    it { should validate_presence_of(:client) }
  end

  describe 'associations' do
    it { should belong_to(:client) }
    it { should have_many(:custom_field_values).dependent(:destroy) }
    it { should have_many(:custom_fields).through(:custom_field_values) }
  end

  describe '#custom_field_values_hash' do
    let(:client) { create(:client) }
    let(:building) { create(:building, client: client) }
    let(:text_field) { create(:custom_field, name: "text_field", field_type: "freeform", client: client) }
    let(:number_field) { create(:custom_field, :number, name: "number_field", client: client) }

    before do
      create(:custom_field_value, building: building, custom_field: text_field, value: "test value")
      create(:custom_field_value, building: building, custom_field: number_field, value: "100")
    end

    it 'returns custom field values as a hash' do
      data = building.custom_field_values_hash
      expect(data["text_field"]).to eq("test value")
      expect(data["number_field"]).to eq("100")
    end

    it 'returns empty string for fields without values' do
      empty_field = create(:custom_field, name: "empty_field", field_type: "freeform", client: client)
      data = building.custom_field_values_hash
      expect(data["empty_field"]).to eq("")
    end
  end

  describe '#set_custom_field_values!' do
    let(:client) { create(:client) }
    let(:building) { create(:building, client: client) }
    let!(:number_field) { create(:custom_field, :number, name: "building_size", client: client) }
    let!(:text_field) { create(:custom_field, name: "brick_color", field_type: "freeform", client: client) }
    let!(:enum_field) { create(:custom_field, :enum, name: "status", client: client) }

    it 'creates custom field values' do
      building.set_custom_field_values!({
        "building_size" => "5000",
        "brick_color" => "Red"
      })
      expect(building.custom_field_values.count).to eq(2)
      expect(building.custom_field_values_hash["building_size"]).to eq("5000")
      expect(building.custom_field_values_hash["brick_color"]).to eq("Red")
    end

    it 'updates existing custom field values' do
      create(:custom_field_value, building: building, custom_field: number_field, value: "5000")

      building.set_custom_field_values!({ "building_size" => "6000" })

      expect(building.custom_field_values.count).to eq(1)
      expect(building.custom_field_values_hash["building_size"]).to eq("6000")
    end

    it 'validates values and adds errors for invalid ones' do
      building.set_custom_field_values!({ "building_size" => "not_a_number" })

      expect(building.errors[:base]).to include("Invalid value for custom field 'building_size': must be a number")
      expect(building.custom_field_values.count).to eq(0)
    end

    it 'ignores unknown field names' do
      building.set_custom_field_values!({
        "building_size" => "5000",
        "unknown_field" => "value"
      })

      expect(building.custom_field_values.count).to eq(1)
      expect(building.custom_field_values_hash["building_size"]).to eq("5000")
    end

    it 'accepts case-insensitive enum values' do
      building.set_custom_field_values!({ "status" => "option 1" })

      expect(building.custom_field_values_hash["status"]).to eq("option 1")
    end

    it 'returns early if data is not a hash' do
      building.set_custom_field_values!("not a hash")

      expect(building.custom_field_values.count).to eq(0)
    end

    it 'accepts symbol keys' do
      building.set_custom_field_values!({ building_size: "5000" })

      expect(building.custom_field_values_hash["building_size"]).to eq("5000")
    end
  end
end
