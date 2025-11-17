require 'rails_helper'

RSpec.describe "Api::Buildings", type: :request do
  let!(:client) { Client.create!(name: "Test Client") }
  let!(:number_field) { client.custom_fields.create!(name: "num_field", field_type: "number") }
  let!(:text_field) { client.custom_fields.create!(name: "text_field", field_type: "freeform") }
  let!(:enum_field) { client.custom_fields.create!(name: "enum_field", field_type: "enum", enum_options: ["A", "B", "C"]) }

  describe "GET /api/buildings" do
    let!(:building1) { client.buildings.create!(street: "123 Test St", city: "Test City", state: "NY", zip: "12345") }
    let!(:building2) { client.buildings.create!(street: "456 Main St", city: "Main City", state: "TX", zip: "67890") }

    before do
      building1.custom_field_values.create!(custom_field: number_field, value: "100")
      building1.custom_field_values.create!(custom_field: text_field, value: "Test text")
      building1.custom_field_values.create!(custom_field: enum_field, value: "A")
    end

    it "returns buildings with attributes, custom fields, and pagination" do
      get "/api/buildings"
      expect(response).to have_http_status(:success)

      json = JSON.parse(response.body)
      expect(json["status"]).to eq("success")
      expect(json["buildings"].length).to eq(2)

      first_building = json["buildings"].first
      expect(first_building["client_name"]).to eq("Test Client")
      expect(first_building["address"]).to eq("123 Test St, Test City, NY, 12345")
      expect(first_building["num_field"]).to eq("100")
      expect(first_building["text_field"]).to eq("Test text")
      expect(first_building["enum_field"]).to eq("A")

      second_building = json["buildings"].last
      expect(second_building["address"]).to eq("456 Main St, Main City, TX, 67890")
      expect(second_building["num_field"]).to eq("")
      expect(second_building["text_field"]).to eq("")
      expect(second_building["enum_field"]).to eq("")

      expect(json["pagination"]["current_page"]).to eq(1)
      expect(json["pagination"]["per_page"]).to eq(10)
      expect(json["pagination"]["total_pages"]).to eq(1)
      expect(json["pagination"]["total_count"]).to eq(2)
    end

    it "handles pagination parameters correctly" do
      get "/api/buildings", params: { page: 1, per_page: 1 }
      json = JSON.parse(response.body)

      expect(json["buildings"].length).to eq(1)
      expect(json["pagination"]["current_page"]).to eq(1)
      expect(json["pagination"]["per_page"]).to eq(1)
      expect(json["pagination"]["total_pages"]).to eq(2)
    end

    it "enforces pagination limits" do
      get "/api/buildings", params: { page: 0, per_page: 200 }
      json = JSON.parse(response.body)

      expect(json["pagination"]["current_page"]).to eq(1)
      expect(json["pagination"]["per_page"]).to eq(100)
    end

    it "uses default per_page when not provided" do
      get "/api/buildings"
      json = JSON.parse(response.body)

      expect(json["pagination"]["per_page"]).to eq(10)
    end

    it "allows any per_page value between 1 and 100" do
      get "/api/buildings", params: { per_page: 3 }
      json = JSON.parse(response.body)

      expect(json["pagination"]["per_page"]).to eq(3)
    end
  end

  describe "POST /api/buildings" do
    let(:valid_attributes) do
      {
        client_id: client.id,
        street: "789 New St",
        city: "New City",
        state: "NC",
        zip: "11111",
        custom_fields: {
          num_field: "50",
          text_field: "Some text",
          enum_field: "B"
        }
      }
    end

    it "creates building with valid attributes and custom fields" do
      expect {
        post "/api/buildings", params: valid_attributes
      }.to change(Building, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["status"]).to eq("success")
      expect(json["message"]).to eq("Building created successfully")
      expect(json["building"]["address"]).to eq("789 New St, New City, NC, 11111")
      expect(json["building"]["num_field"]).to eq("50")
      expect(json["building"]["text_field"]).to eq("Some text")
      expect(json["building"]["enum_field"]).to eq("B")
    end

    it "handles various validation errors" do
      post "/api/buildings", params: { client_id: 99999, street: "Test" }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["errors"]).to include("Client not found")

      post "/api/buildings", params: { client_id: client.id }
      expect(response).to have_http_status(:unprocessable_entity)

      post "/api/buildings", params: { client_id: client.id, street: "Test", custom_fields: { num_field: "not_a_number" } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to include("Invalid value for 'num_field': must be a number")

      post "/api/buildings", params: { client_id: client.id, street: "Test", custom_fields: { enum_field: "INVALID" } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"].first).to include("Invalid value for 'enum_field'")

      post "/api/buildings", params: { client_id: client.id, street: "Test", custom_fields: { unknown_field: "value" } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to include("Unknown custom field 'unknown_field' for the client")
    end

    it "handles edge cases for custom fields" do
      post "/api/buildings", params: { client_id: client.id, street: "Test", custom_fields: { enum_field: "a" } }
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["building"]["enum_field"]).to eq("a")

      post "/api/buildings", params: { client_id: client.id, street: "Test2", custom_fields: { text_field: "" } }
      expect(response).to have_http_status(:created)

      expect {
        post "/api/buildings", params: { client_id: client.id, street: "Test3" }
      }.to change(Building, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it "roll back building creation if custom field save fails" do
      allow_any_instance_of(CustomFieldValue).to receive(:save!)
        .and_raise(ActiveRecord::RecordInvalid.new(CustomFieldValue.new))

      expect {
        post "/api/buildings", params: valid_attributes
      }.not_to change(Building, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["status"]).to eq("error")
      expect(json["errors"]).to be_present
    end
  end

  describe "PUT/PATCH /api/buildings/:id" do
    let!(:building) { client.buildings.create!(street: "Original Street", city: "Old City") }

    before do
      building.custom_field_values.create!(custom_field: number_field, value: "100")
    end

    it "updates building attributes and custom fields" do
      patch "/api/buildings/#{building.id}", params: { street: "Updated Street", city: "New City" }
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json["status"]).to eq("success")
      expect(json["building"]["address"]).to eq("Updated Street, New City")

      patch "/api/buildings/#{building.id}", params: { custom_fields: { num_field: "200", text_field: "New text" } }
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json["building"]["num_field"]).to eq("200")
      expect(json["building"]["text_field"]).to eq("New text")

      patch "/api/buildings/#{building.id}", params: { street: "New Street Only" }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)["building"]["address"]).to eq("New Street Only, New City")
    end

    it "handles update validation errors" do
      patch "/api/buildings/99999", params: { street: "Test" }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["errors"]).to include("Building not found")

      patch "/api/buildings/#{building.id}", params: { custom_fields: { num_field: "invalid" } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["status"]).to eq("error")
    end

    it "handles update edge cases for custom fields" do
      patch "/api/buildings/#{building.id}", params: { custom_fields: { num_field: "" } }
      expect(response).to have_http_status(:success)

      patch "/api/buildings/#{building.id}", params: { custom_fields: { enum_field: "b" } }
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json["building"]["enum_field"]).to eq("b")
    end

    it "roll back building update if custom field save fails" do
      original_street = building.street
      allow_any_instance_of(CustomFieldValue).to receive(:save!)
        .and_raise(ActiveRecord::RecordInvalid.new(CustomFieldValue.new))

      patch "/api/buildings/#{building.id}", params: { street: "New Street", custom_fields: { num_field: "999" } }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["status"]).to eq("error")
      expect(json["errors"]).to be_present

      building.reload
      expect(building.street).to eq(original_street)
      expect(building.custom_field_values.find_by(custom_field_id: number_field.id).value).to eq("100")
    end
  end
end
