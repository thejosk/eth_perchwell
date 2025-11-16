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
    values_by_field_id = custom_field_values.index_by(&:custom_field_id)
    
    client.custom_fields.each do |custom_field|
      field_value = values_by_field_id[custom_field.id]
      result[custom_field.name] = field_value&.value || ""
    end
  
    result
  end

  #Sets custom field values from a hash of field names to values
  #Validates each value and adds errors for invalid ones
  #Unknown field names are silently ignored
  def set_custom_field_values(data)
    return unless data.is_a?(Hash)

    data = data.with_indifferent_access
    fields_by_name = client.custom_fields.index_by(&:name)

    data.each do |field_name, value|
      custom_field = fields_by_name[field_name]
      next unless custom_field

      unless custom_field.valid_value?(value)
        errors.add(:base, "Invalid value for custom field '#{field_name}': #{custom_field.validation_error(value)}")
        next
      end

      field_value = custom_field_values.find_or_initialize_by(custom_field: custom_field)
      field_value.value = value.to_s
      field_value.save
    end
  end
end
