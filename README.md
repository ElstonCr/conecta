# Conecta

![CI](https://github.com/ElstonCr/conecta/actions/workflows/ci.yml/badge.svg)

Rails API backend for Conecta.

## Stack

Ruby 4.0.2, Rails 8.1 (API only), PostgreSQL, Solid Queue / Cache / Cable.

## Setup

```bash
bundle install
bin/rails db:prepare
bin/rails server   # http://localhost:3000
```

Set `DB_USERNAME` and `DB_PASSWORD` in a `.env` file (loaded by dotenv in dev/test).

## API

| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/api/v1/users` | no | Sign up, returns a token |
| POST | `/api/v1/login` | no | Log in, returns a token (10 attempts / 3 min / IP) |
| GET | `/api/v1/me` | Bearer token | Current user greeting |

Authenticated requests send `Authorization: Bearer <token>`. Tokens expire after 1 day and are invalidated when the password changes.

## Tests

```bash
bin/rails test      # test suite + coverage report in coverage/index.html
bin/rubocop         # style
bin/brakeman        # security scan
```

CI runs all three on every pull request.
