class Building < ApplicationRecord
  belongs_to :client
  has_many :custom_field_values, dependent: :destroy
  has_many :custom_fields, through: :custom_field_values

  validates :street, presence: true
  validates :client, presence: true

  #Returns hash of custom field names to their values
  #Returns empty string for fields that haven't been set yet
  def custom_field_values_hash
    result = {}
    fresh_values = CustomFieldValue.where(building_id: id).index_by(&:custom_field_id)
    
    client.custom_fields.each do |custom_field|
      field_value = fresh_values[custom_field.id]
      result[custom_field.name] = field_value&.value || ""
    end
  
    result
  end

  #Sets custom field values from a actioncontroller parameters (or hash) of field names to values
  #validates each value and adds errors for invalid ones
  def set_custom_field_values!(data)
    return if data.nil?
    return unless data.is_a?(Hash) || data.respond_to?(:to_unsafe_h)
    
    hash_data = data.is_a?(Hash) ? data : data.to_unsafe_h
    hash_data = hash_data.with_indifferent_access
    return if hash_data.empty?
    
    fields_by_name = client.custom_fields.index_by(&:name)

    hash_data.each do |field_name, value|
      custom_field = fields_by_name[field_name]
      next unless custom_field

      unless custom_field.valid_value?(value)
        errors.add(:base, "Invalid value for custom field '#{field_name}': #{custom_field.validation_error(value)}")
        next
      end

      field_value = CustomFieldValue.find_or_initialize_by(
        building_id: self.id,
        custom_field_id: custom_field.id
      )
      field_value.value = value.to_s
      field_value.save!
    end
  end
end
