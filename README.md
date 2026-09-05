# FORUMX — Modern Online Discussion Platform

[![Ruby Version](https://img.shields.io/badge/Ruby-3.3.0+-CC342D?logo=ruby&logoColor=white)](https://www.ruby-lang.org)
[![Rails Version](https://img.shields.io/badge/Rails-8.0+-CC0000?logo=rubyonrails&logoColor=white)](https://rubyonrails.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org)
[![Hotwire](https://img.shields.io/badge/Hotwire-Turbo%20%26%20Stimulus-F59E0B)](https://hotwired.dev)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-v4.0-06B6D4?logo=tailwindcss&logoColor=white)](https://tailwindcss.com)
[![Brakeman](https://img.shields.io/badge/Security-Brakeman%20Passed%20(0%20warnings)-success)](docs/security.md)
[![Tests](https://img.shields.io/badge/RSpec-100%25%20Passing-brightgreen)](spec/)
[![Render](https://img.shields.io/badge/Deploy%20to-Render-46E3B7?logo=render&logoColor=white)](docs/deployment.md)

**FORUMX** is a full-featured, production-ready online community and discussion platform built from the ground up using **Ruby on Rails 8**, **PostgreSQL**, **Hotwire (Turbo & Stimulus)**, and **Tailwind CSS**. 

Engineered as an advanced, production-grade application without any containerization overhead, FORUMX demonstrates enterprise-grade relational database design, asynchronous event processing, fine-grained role-based authorization, XSS-hardened Markdown rendering, and PostgreSQL full-text search.

---

## 🌟 Key Features

### 💬 Community & Discussion Mechanics
- **Hierarchical Nested Replies**: Infinite-depth threaded comments powered by an adjacency-list tree model with instant collapsible replies.
- **Accepted Solutions**: Discussion authors and moderators can designate a specific answer as the official solution, visually pinned with a emerald solved badge.
- **Bi-Directional Voting Engine**: StackOverflow-style upvoting (+1) and downvoting (-1) with atomic score recalculation and dynamic karma reputation.
- **Rich Markdown Composer**: GitHub-Flavored Markdown (GFM) with syntax formatting, blockquotes, code blocks, tables, and hardened HTML sanitization.
- **User Mentions & Smart Notifications**: Real-time `@username` parsing triggering notifications for mentioned members.
- **Subscriptions & Bookmarks**: Follow active conversations to receive updates and save threads to your personal bookmark library.
- **Automated Gamification**: Multi-tier reputation system awarding milestone community badges (e.g. *First Step*, *Century*, *Problem Solver*, *Opinion Leader*).

### 🔍 Search & Discovery
- **PostgreSQL Native Full-Text Search**: Accelerated via GIN `tsvector` index over titles and discussion bodies with English stemming, prefix matching, and relevance ranking.
- **Multi-Facet Filtering**: Filter discussions by category, solution status, vote count, or recent activity.
- **Categorized Forums**: Custom themed categories with individual color accents, icons, and live discussion density counters.

### 🛡️ Moderation & Administrative Control
- **Dedicated Admin Portal (`/admin`)**: Real-time platform analytics, user directory, flagged report queue, and category manager.
- **Thread Management**: Pin, unpin, lock, unlock, archive, and move threads across categories.
- **Flagged Content Queue**: Members can flag spam, hate speech, or abuse. Staff can triage, resolve, or dismiss reports in seconds.
- **Disciplinary Enforcement**: Temporary or permanent account suspensions with immediate session revocation.
- **Immutable Audit Trail**: Every staff action records a structured `ModerationLog` capturing moderator identity, action type, target entity, reason, and metadata.

---

## 🏗️ Technical Architecture

| Component | Technology | Purpose |
| :--- | :--- | :--- |
| **Backend Framework** | Ruby on Rails 8 | RESTful controllers, ActiveRecord ORM, Puma web server |
| **Relational Database** | PostgreSQL 15+ | 14 normalized tables, foreign key constraints, GIN FTS index |
| **Frontend UI** | Tailwind CSS v4 & ERB | Responsive, accessible, custom modern dark/light typography |
| **Reactivity** | Hotwire (Turbo + Stimulus) | Turbo Frames & Streams for zero-reload real-time interactions |
| **Authentication** | Devise & Bcrypt | Hardened password hashing, session expiration, strong params |
| **Authorization** | Pundit | Declarative policy objects (`app/policies/`) for all domain models |
| **Background Jobs** | Sidekiq & Redis | Asynchronous mention dispatching, notification delivery, badge audits |
| **Markdown Engine** | Kramdown & Sanitize | GFM rendering paired with an XSS-proof HTML element whitelist |
| **Security Scanner** | Brakeman | Static application security testing (0 vulnerabilities detected) |
| **Test Suite** | RSpec & FactoryBot | Comprehensive unit, request, and integration test coverage |

---

## 🚀 Quick Start (Docker-Free Setup)

FORUMX runs natively on your machine without Docker.

### 1. Prerequisites
Ensure you have installed:
- **Ruby 3.3+**
- **PostgreSQL 15+**
- **Redis 7+**

### 2. Clone & Install
```bash
git clone https://github.com/your-username/forumx.git
cd forumx
bundle install
```

### 3. Setup Database & Seed Realistic Data
```bash
cp .env.example .env

bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
```

The seed command populates **3 demo accounts**, **25 realistic users**, **10 categories**, **52 rich discussions**, and **330+ nested replies**!

### 4. Start the Application
```bash
./bin/dev
```
*Or in separate terminal tabs:*
```bash
# Terminal 1: Web Server
bundle exec rails server -p 3000

# Terminal 2: Tailwind CSS Watcher
bundle exec rails tailwindcss:watch

# Terminal 3: Asynchronous Worker
bundle exec sidekiq -C config/sidekiq.yml
```

Visit **`http://localhost:3000`** in your browser!

---

## 🔑 Demo Accounts

Use these pre-seeded accounts to explore all user roles:

| Role | Email | Username | Password |
| :--- | :--- | :--- | :--- |
| **👑 Administrator** | `admin@forumx.io` | `admin` | `Password123!` |
| **🛡️ Moderator** | `moderator@forumx.io` | `moderator` | `Password123!` |
| **👤 Standard User** | `user@forumx.io` | `user` | `Password123!` |

---

## 🧪 Testing & Code Quality

```bash
# Run all unit, service, model, and request specs
bundle exec rspec

# Run Brakeman security vulnerability scanner
bundle exec brakeman -q

# Run RuboCop static code analysis
bundle exec rubocop
```

---

## ☁️ Production Deployment on Render

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/AmitabhMorey/forumx)

FORUMX is turnkey-ready for **Render** using native Linux environments (strictly zero Docker).

1. Click the **Deploy to Render** button above or connect your repository in the [Render Blueprint Dashboard](https://dashboard.render.com/blueprints/new).
2. Select your repository: `https://github.com/AmitabhMorey/forumx`.
3. Render automatically reads the included [`render.yaml`](render.yaml) Blueprint to provision:
   - **PostgreSQL Database** (`forumx-postgres`)
   - **Redis Key-Value Cache** (`forumx-redis`)
   - **Puma Web Service** (`forumx-web`)
   - **Sidekiq Background Worker** (`forumx-sidekiq`)
4. The automated [`bin/render-build.sh`](bin/render-build.sh) script will install gems, precompile Tailwind assets, clean cache, and execute database migrations automatically.
5. Once deployed, run `bundle exec rails db:seed` in the Render Shell (or via Render CLI) to seed initial production data.

For step-by-step instructions, see the [Render Deployment Guide](docs/deployment.md).

---

## 📚 Detailed Documentation

- 🏛️ [System Architecture](docs/architecture.md)
- 🗄️ [Database Schema & GIN Indexing](docs/database.md)
- 🔒 [Security & Threat Model](docs/security.md)
- 💻 [Local Development Guide](docs/development.md)
- ⚖️ [Moderation & Governance](docs/moderation.md)
- 🚀 [Render Deployment Manual](docs/deployment.md)
- 🔌 [Internal API & Endpoint Reference](docs/api.md)

---

## 📄 License
Released under the [MIT License](LICENSE).
