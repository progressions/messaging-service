.PHONY: setup run test clean help db-up db-down db-logs db-shell db-bootstrap db-url

help:
	@echo "Available commands:"
	@echo "  setup    - Set up the project environment and start database"
	@echo "  run      - Run the application"
	@echo "  test     - Run tests"
	@echo "  clean    - Clean up temporary files and stop containers"
	@echo "  db-up    - Start the PostgreSQL database"
	@echo "  db-down  - Stop the PostgreSQL database"
	@echo "  db-logs  - Show database logs"
	@echo "  db-shell - Connect to the database shell"
	@echo "  db-bootstrap - Create messaging_user role and databases in container"
	@echo "  db-url   - Print local DATABASE_URLs used by Rails"
	@echo "  help     - Show this help message"

setup:
	@echo "Setting up the project..."
	@echo "Starting PostgreSQL database..."
	@docker-compose up -d
	@echo "Waiting for database to be ready..."
	@sleep 5
	@echo "Setup complete!"

run:
	@echo "Running the application..."
	@./bin/start.sh

test:
	@echo "Running tests..."
	@echo "Starting test database if not running..."
	@docker-compose up -d
	@echo "Running test script..."
	@./bin/test.sh

clean:
	@echo "Cleaning up..."
	@echo "Stopping and removing containers..."
	@docker-compose down -v
	@echo "Removing any temporary files..."
	@rm -rf *.log *.tmp

db-up:
	@echo "Starting PostgreSQL database..."
	@docker-compose up -d

db-down:
	@echo "Stopping PostgreSQL database..."
	@docker-compose down

db-logs:
	@echo "Showing database logs..."
	@docker-compose logs -f postgres

db-shell:
	@echo "Connecting to database shell..."
	@docker-compose exec postgres psql -U messaging_user -d messaging_service

db-bootstrap:
	@echo "Bootstrapping Postgres role and databases inside container..."
	@echo "Ensuring role messaging_user exists..."
	@docker-compose exec -T postgres psql -U messaging_user -d postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='messaging_user'" | grep -q 1 \
		|| docker-compose exec -T postgres psql -U messaging_user -d postgres -c "CREATE ROLE messaging_user WITH LOGIN PASSWORD 'messaging_password' SUPERUSER;" \
		|| docker-compose exec -T postgres psql -U postgres -d postgres -c "CREATE ROLE messaging_user WITH LOGIN PASSWORD 'messaging_password' SUPERUSER;" || true
	@echo "Ensuring database messaging_service exists..."
	@docker-compose exec -T postgres psql -U messaging_user -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='messaging_service'" | grep -q 1 \
		|| docker-compose exec -T postgres psql -U messaging_user -d postgres -c "CREATE DATABASE messaging_service OWNER messaging_user;"
	@echo "Ensuring database messaging_service_test exists..."
	@docker-compose exec -T postgres psql -U messaging_user -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='messaging_service_test'" | grep -q 1 \
		|| docker-compose exec -T postgres psql -U messaging_user -d postgres -c "CREATE DATABASE messaging_service_test OWNER messaging_user;"
	@echo "Bootstrap complete. Example connection URL:"
	@echo "  postgres://messaging_user:messaging_password@127.0.0.1:5432/messaging_service"

db-url:
	@echo "Rails will use these URLs by default (unless DATABASE_URL is set):"
	@echo "  dev : postgres://messaging_user:messaging_password@127.0.0.1:55432/messaging_service"
	@echo "  test: postgres://messaging_user:messaging_password@127.0.0.1:55432/messaging_service_test"
	@echo "Examples:"
	@echo "  env -u DATABASE_URL bundle exec rails db:prepare"
	@echo "  DATABASE_URL=postgres://messaging_user:messaging_password@127.0.0.1:55432/messaging_service make run"
