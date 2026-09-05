# FORUMX Local Development & Setup Guide

## 1. Prerequisites (Strictly Docker-Free)

FORUMX runs natively on macOS and Linux without Docker or container virtualization overhead. Ensure the following tools are installed:

- **Ruby**: Version `3.3.0` or higher (Managed via `rbenv`, `asdf`, or Homebrew)
- **PostgreSQL**: Version `15` or higher
- **Redis**: Version `7.0` or higher
- **Node.js**: (Optional, standard Rails asset compilation is self-contained with Tailwind standalone executable)

### Verifying Installed Versions:
```bash
ruby -v           # ruby 3.3.x
psql --version    # psql 15+
redis-server -v   # Redis server v=7+
```

---

## 2. Installation & Database Setup

### Step 1: Clone Repository & Install Dependencies
```bash
cd /path/to/forumx
bundle install
```

### Step 2: Configure Environment Variables
Copy the template configuration:
```bash
cp .env.example .env
```
Ensure your local PostgreSQL and Redis services are running:
```bash
# macOS (Homebrew)
brew services start postgresql@15
brew services start redis

# Ubuntu / Debian Linux
sudo systemctl start postgresql
sudo systemctl start redis-server
```

### Step 3: Initialize Database & Seed Realistic Data
```bash
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
```

The seed script will populate:
- **3 Demo Accounts** with pre-configured roles (Admin, Moderator, Regular User).
- **25 Realistic Users** with bios, locations, avatars, and karma reputations.
- **10 Core Topic Categories** with custom branding hex colors and icons.
- **52 Engaging Discussions** covering systems architecture, Ruby tricks, DevOps, AI, security, and career topics.
- **330+ Multi-Level Hierarchical Replies** demonstrating nested conversation threads.
- Real votes, bookmarks, subscriptions, and community badges.

---

## 3. Demo Credentials

| Role | Email | Username | Password |
| :--- | :--- | :--- | :--- |
| **Administrator** | `admin@forumx.io` | `admin` | `Password123!` |
| **Moderator** | `moderator@forumx.io` | `moderator` | `Password123!` |
| **Standard User** | `user@forumx.io` | `user` | `Password123!` |

---

## 4. Running the Platform Locally

### Using `bin/dev` (Foreman / Overmind with Tailwind & Rails Server):
```bash
./bin/dev
```

### Or Running Processes Individually in Separate Terminals:
**Terminal 1: Rails Web Server**
```bash
bundle exec rails server -p 3000
```

**Terminal 2: Tailwind CSS Watcher**
```bash
bundle exec rails tailwindcss:watch
```

**Terminal 3: Sidekiq Asynchronous Worker**
```bash
bundle exec sidekiq -C config/sidekiq.yml
```

Open your browser at `http://localhost:3000`.

---

## 5. Running the Test Suite & Quality Linters

### Execute RSpec Test Suite:
```bash
bundle exec rspec
```

### Execute Security Static Analysis (Brakeman):
```bash
bundle exec brakeman -q
```

### Execute Code Style Verification (RuboCop):
```bash
bundle exec rubocop
```
