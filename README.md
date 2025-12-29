# Parking Control API

A RESTful API for managing parking lot operations built with Ruby on Rails 8.

## Features

- 🚗 **Vehicle Entry** - Register vehicle entrance with license plate
- 💳 **Payment Processing** - Process parking payments
- 🚪 **Vehicle Exit** - Register vehicle departure (requires payment)
- 📜 **History** - View parking history by license plate

## Tech Stack

- **Ruby** 3.4.7
- **Rails** 8.1.1
- **PostgreSQL** 18
- **Docker & Docker Compose**

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Getting Started

### 1. Clone the repository

```bash
git clone <repository-url>
cd parking_control
```

### 2. Build and start the containers

```bash
docker compose up --build
```

This will:
- Build the Rails application image
- Start PostgreSQL database
- Start the Rails server on port 3000

### 3. Setup the database

In a new terminal, run:

```bash
docker compose exec app bin/rails db:create db:migrate
```

### 4. Access the API

The API will be available at `http://localhost:3000`

## Docker Commands

### Start services
```bash
docker compose up
```

### Start services in background
```bash
docker compose up -d
```

### Stop services
```bash
docker compose down
```

### View logs
```bash
docker compose logs -f app
```

### Access Rails console
```bash
docker compose exec app bin/rails console
```

### Run database migrations
```bash
docker compose exec app bin/rails db:migrate
```

### Run tests
```bash
docker compose run --rm app bundle exec rspec
```

### Rebuild containers (after Gemfile changes)
```bash
docker compose up --build
```

## API Endpoints

### Register Vehicle Entry

```http
POST /api/v1/parking
Content-Type: application/json

{
  "plate": "ABC-1234"
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "plate": "ABC-1234",
  "message": "Entrada registrada com sucesso"
}
```

### Process Payment

```http
PUT /api/v1/parking/:plate/pay
```

**Example:**
```bash
curl -X PUT http://localhost:3000/api/v1/parking/ABC-1234/pay
```

**Response (200 OK):**
```json
{
  "message": "Pagamento realizado com sucesso"
}
```

### Register Vehicle Exit

```http
PUT /api/v1/parking/:plate/out
```

**Example:**
```bash
curl -X PUT http://localhost:3000/api/v1/parking/ABC-1234/out
```

**Response (200 OK):**
```json
{
  "message": "Baixa realizado com sucesso"
}
```

### Get Parking History

```http
GET /api/v1/parking/:plate
```

**Example:**
```bash
curl http://localhost:3000/api/v1/parking/ABC-1234
```

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "time": "45 minutos",
    "paid": true,
    "left": true
  }
]
```

## License Plate Format

License plates must follow the format: `AAA-0000` (3 uppercase letters, hyphen, 4 digits)

**Valid examples:** `ABC-1234`, `XYZ-9999`

**Invalid examples:** `ABC1234`, `AB-123`, `ABCD-1234`

## Development

### Project Structure

```
app/
├── controllers/api/v1/    # API endpoints
├── models/                # ActiveRecord models
├── presenters/            # Response formatters
└── services/parkings/     # Business logic
    ├── duration_service.rb
    ├── enter_service.rb
    ├── history_service.rb
    ├── leave_service.rb
    ├── pay_service.rb
    └── plate_validator.rb
```

### Running Tests

```bash
# Run all tests
docker compose run --rm app bundle exec rspec

# Run with verbose output
docker compose run --rm app bundle exec rspec --format documentation

# Run specific test file
docker compose run --rm app bundle exec rspec spec/models/parking_spec.rb
```

### Code Quality

```bash
# Run RuboCop
docker compose run --rm app bin/rubocop

# Run security audit
docker compose run --rm app bin/brakeman --no-pager
docker compose run --rm app bin/bundler-audit
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_HOST` | PostgreSQL host | `db` |
| `DATABASE_USERNAME` | Database username | `postgres` |
| `DATABASE_PASSWORD` | Database password | `postgres` |
| `DATABASE_NAME` | Database name | `parking_control_development` |

## License

This project is available as open source.
