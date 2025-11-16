class CustomFieldValue < ApplicationRecord
  belongs_to :building
  belongs_to :custom_field

  validates :building, presence: true
  validates :custom_field, presence: true
  validates :building_id, uniqueness: { scope: :custom_field_id }
  validate :value_matches_field_type

  private

  def value_matches_field_type
    return if value.blank? # Allow empty values

    unless custom_field.valid_value?(value)
      errors.add(:value, custom_field.validation_error(value))
    end
  end
end
