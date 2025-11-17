require 'rails_helper'

RSpec.describe BuildingSerializer do
  let(:client) { create(:client, name: "Test Client") }
  let(:building) { create(:building, client: client, street: "123 Main St", city: "Test City") }
  let(:custom_field) { create(:custom_field, name: "building_size", field_type: "number", client: client) }

  before do
    create(:custom_field_value, building: building, custom_field: custom_field, value: "5000")
  end

  describe 'serialization' do
    it 'include all attributes and custom fields' do
      another_field = create(:custom_field, name: "color", field_type: "freeform", client: client)
      
      serializer = BuildingSerializer.new(building)
      attributes = serializer.serializable_hash[:data][:attributes]
      
      expect(attributes[:id]).to eq(building.id)
      expect(attributes[:address]).to eq("123 Main St, Test City, NY, 10000, USA")
      expect(attributes[:client_name]).to eq("Test Client")
      expect(attributes[:custom_fields]).to be_a(Hash)
      expect(attributes[:custom_fields]["building_size"]).to eq("5000")
      expect(attributes[:custom_fields]["color"]).to eq("")
    end

    it 'handles partial address correctly' do
      building_with_partial = create(:building, client: client, street: "45 Main St", city: nil, state: nil, zip: nil, country: nil)
      serializer = BuildingSerializer.new(building_with_partial)
      attributes = serializer.serializable_hash[:data][:attributes]
      
      expect(attributes[:address]).to eq("45 Main St")
    end
  end
end
