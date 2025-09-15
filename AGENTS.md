# Repository Guidelines

## Project Structure & Module Organization
- Rails API-only app. Key paths: `app/controllers`, `app/models`, `app/services`, `app/serializers` (optional), `config/routes.rb`, `db/migrate`, `spec/`.
- Place HTTP endpoints under `Api::V1::*` and route them under `/api/v1/...`.
- Database is Postgres from `docker-compose.yml`. Configure via `DATABASE_URL` or `config/database.yml`.

## Build, Test, and Development Commands
- `bundle install` — Install gems.
- `make setup` — Start Postgres container.
- `rails db:prepare` — Create, migrate, and seed (honors `RAILS_ENV`).
- `make run` — `./bin/start.sh` should run `bundle exec rails s -p 8080 -b 0.0.0.0`.
- `make test` — Curl smoke tests. For specs: `bundle exec rspec`.
Examples: `make setup && bundle install && rails db:prepare && make run`

## Coding Style & Naming Conventions
- Use RuboCop with Rails cops (`bundle exec rubocop`); 2-space indent.
- Controllers RESTful (`MessagesController`), models singular (`Message`), files `snake_case.rb`.
- Keep controllers thin; business logic in `app/services`; use strong params and validations.

## Testing Guidelines
- Framework: RSpec. Locations: `spec/requests` (API), `spec/models`, `spec/services`.
- Use `factory_bot` and `faker`; mock external providers; enable SimpleCov for coverage.
- Run: `bundle exec rspec`; ensure `make test` returns 2xx responses from the running server.

## Commit & Pull Request Guidelines
- Commit subject imperative, ≤50 chars; body for context.
- Link issues; include migration notes; update `bin/test.sh` if endpoints/ports change.
- PRs include description, testing steps, and sample `curl` or spec output. Run `rubocop` and `rspec` locally.

## Security & Configuration Tips
- Do not commit secrets, `.env*`, or `config/master.key`. Use Rails credentials.
- Set `RAILS_ENV`, `PORT=8080`, `DATABASE_URL=postgres://messaging_user:messaging_password@127.0.0.1:55432/messaging_service`.
- Prefer migrations over raw SQL; keep seeds idempotent.
