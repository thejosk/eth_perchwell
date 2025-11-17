# Setup

1. Build and start the Docker containers:
```bash
docker compose build
docker compose up
```

2. To seed the database with sample Client, Buildings and Custom Fields:
```bash
docker compose exec web bundle exec rails db:create db:migrate db:seed
```

3. Setup the test database:
```bash
docker compose exec -e RAILS_ENV=test web bundle exec rails db:create db:schema:load
```

4. To run the tests:
```bash
docker compose exec -e RAILS_ENV=test web bundle exec rspec
```

# Api Examples

### List All Buildings
```bash
curl http://localhost:3000/api/buildings | jq
```

### List Buildings with Pagination
```bash
curl "http://localhost:3000/api/buildings?page=1&per_page=5" | jq
```

### Create a Building
```bash
curl -X POST http://localhost:3000/api/buildings \
  -H "Content-Type: application/json" \
  -d '{
    "client_id": 1,
    "street": "123 Main St",
    "city": "Austin",
    "state": "TX",
    "zip": "11111",
    "country": "US",
    "custom_fields": {
      "area_sqft": "5000",
      "roof_type": "Shingle",
      "brick_color": "Red"
    }
  }' | jq
```

### Update a Building
```bash
curl -X PATCH http://localhost:3000/api/buildings/1 \
  -H "Content-Type: application/json" \
  -d '{
    "street": "456 Updated St",
    "custom_fields": {
      "area_sqft": "7500"
    }
  }' | jq
```

# Implementation Assumptions

The following implementation assumptions were made during development:

1. Only the `street` field is required in the Building model. The fields `city`, `state`, `zip`, and `country` are optional. The json api response includes an `address` key containing a comma-separated concatenation of all non blank address fields in the following order: street, city, state, zip, country.
   - Example (full address): `"address": "123 Main St, Austin, TX, 10000, USA"`
   - Example (partial address): `"address": "123 Main St"` (if only street is provided)

2. Custom fields of type "number" accept string input and validate that the value can be converted to a Float (will error if not convertible). Both input and output remain as strings in the api to maintain consistency with the provided example responses (e.g., `"rock_wall_size": "15"`).
   - Input: String value (e.g., `"5000"`)
   - Validation: Check if convertible to Float
   - Output: String value (e.g., `"5000"`)

3. Enum custom fields are made case-insensitive.   

4. The `per_page` parameter defaults to 10 when not present in the request. The maximum allowed value is set to 100 to prevent performance issues.

5. The creation and update of building is wrapped in an activerecord transaction for consistency. If custom field values are invalid, the transaction is rolled back and the error response is returned.

6. I have not enforced any uniqueness constraint on Building model. The same client (or different client) can create multiple buildings with the same address. Ideally, I think we could prevent this by using a standard address validator (Geocoder or a similar service). But I didn't go that far as address is a freeform text field.