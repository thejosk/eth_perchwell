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

