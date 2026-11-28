# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Conecta is a Rails 8.1 **API-only** backend (Ruby 4.0.2 via `mise.toml`, PostgreSQL, Solid Queue/Cache/Cable). A separate frontend calls it; the default CORS origin is `http://localhost:5173` (Vite).

## Commands

```bash
bundle install
bin/rails db:prepare                 # create + migrate dev DB
bin/rails server                     # http://localhost:3000

bin/rails test                                               # full suite (+ SimpleCov report in coverage/index.html)
bin/rails test test/controllers/api/v1/me_controller_test.rb # one file
bin/rails test test/models/user_test.rb:12                   # one test by line number

bin/rubocop          # lint (rubocop-rails-omakase); add -a to autocorrect
bin/brakeman         # security scan
```

CI (`.github/workflows/ci.yml`) runs brakeman, rubocop, and `bin/rails db:test:prepare test` on every PR. With `CI` set, SimpleCov enforces minimum coverage of **85% line / 80% branch**, so new code needs tests or CI fails.

DB credentials come from `DB_USERNAME` / `DB_PASSWORD` in `.env` (dotenv, dev/test only). `CORS_ORIGINS` (comma-separated) overrides the allowed origins.

## Architecture

- **Routing/versioning:** all endpoints live under `namespace :api { namespace :v1 }` in `config/routes.rb`, with controllers in `app/controllers/api/v1/` named `Api::V1::*Controller`. Keep the README's API table in sync when adding endpoints.
- **Authentication is stateless and token-based, with no tokens table.** `User` uses `has_secure_password` and `generates_token_for :api_auth, expires_in: 1.day`, keyed on part of `password_salt`, so changing the password invalidates every existing token. Tokens are issued by signup (`UsersController#create`) and login (`SessionsController#create`).
- **Protecting an endpoint:** add `before_action :authenticate!` (defined in `ApplicationController`). It reads `Authorization: Bearer <token>`, resolves the user with `User.find_by_token_for(:api_auth, ...)`, sets `@current_user`, and otherwise renders `401 { message: "Unauthorized" }`.
- **Rate limiting:** login uses Rails' built-in `rate_limit` (10 per 3 minutes per IP), not Rack::Attack.
- **Conventions:** strong params use `params.expect(resource: [...])`; responses are hand-built `render json:` hashes (no serializers or jbuilder); validation failures return `422 { errors: [...full_messages] }`; emails are normalized (strip + downcase) on the model.
- **CORS:** `config/initializers/cors.rb` allows only `/api/*` with GET/POST/OPTIONS/HEAD. Extend the `methods` list when adding PATCH/PUT/DELETE endpoints (covered by `test/integration/cors_test.rb`).

## Testing

Minitest with fixtures, run in parallel. Controller tests are `ActionDispatch::IntegrationTest` hitting real paths (`get "/api/v1/me"`). They usually create users inline with `User.create!`, and get tokens from `user.generate_token_for(:api_auth)`. Fixture users in `test/fixtures/users.yml` all have the password `password123`.

## Deployment

Not deployed yet. Planned target: Render.
Kamal config (`config/deploy.yml`, `.kamal/`) came with the Rails generator and isn't used.

## Git workflow

- Never commit to `main`. Work on branches: `feature/...`, `fix/...`, `chore/...`
- Commit messages: conventional style (`feat:`, `fix:`, `chore:`, `test:`, `docs:`)
- Before any commit, run `bin/rubocop`, `bin/brakeman` and `bin/rails test`. All three must pass.
- Don't commit, push or open PRs unless I ask. I review and merge PRs myself.

## Running things

- Don't start `bin/rails server` unless I ask. I usually have it running already. Use tests to check changes.
- Ask before running migrations or anything that changes the dev database (`db:migrate`, `db:reset`, `db:seed`).
- Ask before creating/ editing files in the codebase
