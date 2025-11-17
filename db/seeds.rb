puts "Seeding database..."

puts "Creating Client 1: Thejo Client1..."
client1 = Client.find_or_create_by!(name: "Thejo Client1")

cf1_area_sqft = CustomField.find_or_create_by!(
  client: client1,
  name: "area_sqft"
) do |cf|
  cf.field_type = "number"
end

cf1_roof_type = CustomField.find_or_create_by!(
  client: client1,
  name: "roof_type"
) do |cf|
  cf.field_type = "enum"
  cf.enum_options = ["Shingle", "Metal"]
end

cf1_brick_color = CustomField.find_or_create_by!(
  client: client1,
  name: "brick_color"
) do |cf|
  cf.field_type = "freeform"
end

# Building for Client 1
building1 = Building.find_or_create_by!(
  client: client1,
  street: "1 Main St"
) do |b|
  b.city = "Austin"
  b.state = "TX"
  b.zip = "10000"
  b.country = "US"
end
building1.set_custom_field_values!({
  area_sqft: "25000",
  roof_type: "Shingle",
  brick_color: "Red"
})

building2 = Building.find_or_create_by!(
  client: client1,
  street: "2 Main St"
) do |b|
  b.city = "Dallas"
  b.state = "TX"
  b.zip = "10001"
  b.country = "US"
end
building2.set_custom_field_values!({
  area_sqft: "85000",
  roof_type: "Metal",
  brick_color: "Blue"
})

puts "Creating Client 2: Thejo Client2..."
client2 = Client.find_or_create_by!(name: "Thejo Client2")

cf2_rock_wall_length = CustomField.find_or_create_by!(
  client: client2,
  name: "rock_wall_length"
) do |cf|
  cf.field_type = "number"
end

cf2_area_sqft = CustomField.find_or_create_by!(
  client: client2,
  name: "area_sqft"
) do |cf|
  cf.field_type = "number"
end

cf2_rock_wall_size = CustomField.find_or_create_by!(
  client: client2,
  name: "rock_wall_size"
) do |cf|
  cf.field_type = "number"
end

cf2_type = CustomField.find_or_create_by!(
  client: client2,
  name: "building_type"
) do |cf|
  cf.field_type = "enum"
  cf.enum_options = ["Single Family", "Multi Family"]
end

# Buildings for Client 2
building3 = Building.find_or_create_by!(
  client: client2,
  street: "100 Some Street"
) do |b|
  b.city = "Some City"
  b.state = "Some State"
  b.zip = "99999"
  b.country = "US"
end
building3.set_custom_field_values!({
  rock_wall_length: "250",
  area_sqft: "25000",
  rock_wall_size: "10",
  building_type: "Single Family"
})

building4 = Building.find_or_create_by!(
  client: client2,
  street: "200 Some Street"
) do |b|
  b.city = "Some City 2"
  b.state = "Some State 2"
  b.zip = "88888"
  b.country = "US"
end
building4.set_custom_field_values!({
  rock_wall_length: "250",
  area_sqft: "25000",
  rock_wall_size: "10",
  building_type: "Multi Family"
})

puts "Creating Client 3: Thejo Client3..."
client3 = Client.find_or_create_by!(name: "Thejo Client3")

cf3_type = CustomField.find_or_create_by!(
  client: client3,
  name: "type"
) do |cf|
  cf.field_type = "enum"
  cf.enum_options = ["New", "Existing"]
end

cf3_year = CustomField.find_or_create_by!(
  client: client3,
  name: "year"
) do |cf|
  cf.field_type = "number"
end

# Buildings for Client 3
building5 = Building.find_or_create_by!(
  client: client3,
  street: "999 Some Street"
) do |b|
  b.city = "Some City 3"
  b.state = "Some State 3"
  b.zip = "11111"
  b.country = "US"
end
building5.set_custom_field_values!({
  type: "New",
  year: "2022",
})

building6 = Building.find_or_create_by!(
  client: client3,
  street: "400 Some Street"
) do |b|
  b.city = "Some City 4"
  b.state = "Some State 4"
  b.zip = "22222"
  b.country = "US"
end
building6.set_custom_field_values!({
  type: "Existing",
  year: "1925",
})

puts "Creating Client 4: Thejo Client4..."
client4 = Client.find_or_create_by!(name: "Thejo Client4")

cf4_windows = CustomField.find_or_create_by!(
  client: client4,
  name: "windows"
) do |cf|
  cf.field_type = "number"
end

cf4_ceiling = CustomField.find_or_create_by!(
  client: client4,
  name: "ceiling_type"
) do |cf|
  cf.field_type = "enum"
  cf.enum_options = ["Flat", "Vaulted"]
end

# Buildings for Client 4
building7 = Building.find_or_create_by!(
  client: client4,
  street: "500 Some Street"
) do |b|
  b.city = "Some City 5"
  b.state = "Some State 5"
  b.zip = "33333"
  b.country = "US"
end
building7.set_custom_field_values!({
  windows: "20",
  ceiling_type: "Vaulted",
})

building8 = Building.find_or_create_by!(
  client: client4,
  street: "600 Some Street"
) do |b|
  b.city = "Some City 6"
  b.state = "Some State 6"
  b.zip = "44444"
  b.country = "US"
end
building8.set_custom_field_values!({
  windows: "15",
  ceiling_type: "Flat",
})

puts "Creating Client 5: Thejo Client5..."
client5 = Client.find_or_create_by!(name: "Thejo Client5")

cf5_type = CustomField.find_or_create_by!(
  client: client5,
  name: "type"
) do |cf|
  cf.field_type = "enum"
  cf.enum_options = ["Commercial", "Residential"]
end

# Buildings for Client 5
building9 = Building.find_or_create_by!(
  client: client5,
  street: "700 Some Street"
) do |b|
  b.city = "Some City 7"
  b.state = "Some State 7"
  b.zip = "55555"
  b.country = "US"
end
building9.set_custom_field_values!({
  type: "Commercial",
})

building10 = Building.find_or_create_by!(
  client: client5,
  street: "800 Some Street"
) do |b|
  b.city = "Some City 8"
  b.state = "Some State 8"
  b.zip = "66666"
  b.country = "US"
end
building10.set_custom_field_values!({
  type: "Residential"
})

puts "\n"
puts "Seed Complete"
puts "Created #{Client.count} clients"
puts "Created #{CustomField.count} custom fields"
puts "Created #{Building.count} buildings"
puts "Created #{CustomFieldValue.count} custom field values"
