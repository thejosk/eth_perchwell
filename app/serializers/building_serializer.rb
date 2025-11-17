class BuildingSerializer
  include JSONAPI::Serializer

  attributes :id

  attribute :client_name do |building|
    building.client.name
  end

  attribute :address do |building|
    [
      building.street,
      building.city,
      building.state,
      building.zip,
      building.country
    ].compact.reject(&:blank?).join(', ')
  end

  attribute :custom_fields do |building|
    building.custom_field_values_hash
  end
end
