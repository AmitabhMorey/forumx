# frozen_string_literal: true

puts "== Cleaning existing records =="
ModerationLog.destroy_all
Report.destroy_all
Notification.destroy_all
Mention.destroy_all
Bookmark.destroy_all
Subscription.destroy_all
Vote.destroy_all
UserBadge.destroy_all
Badge.destroy_all
DiscussionTag.destroy_all
Tag.destroy_all
Reply.destroy_all
Discussion.destroy_all
Category.destroy_all
User.destroy_all

puts "== Creating Badges =="
badges = [
  { name: "First Post", slug: "first-post", description: "Contributed your first discussion or reply", icon: "sparkles", badge_type: "bronze" },
  { name: "Discussion Starter", slug: "discussion-starter", description: "Created 5 or more discussions", icon: "chat-bubble-left-right", badge_type: "silver" },
  { name: "Helpful Member", slug: "helpful-member", description: "Contributed 10 or more helpful replies", icon: "heart", badge_type: "silver" },
  { name: "Problem Solver", slug: "problem-solver", description: "Authored an accepted solution to a community question", icon: "check-badge", badge_type: "gold" },
  { name: "Top Contributor", slug: "top-contributor", description: "Earned 50+ community reputation", icon: "trophy", badge_type: "gold" }
]
created_badges = badges.map { |b| Badge.create!(b) }

puts "== Creating Demo Accounts & Users =="
# 1. Admin
admin = User.create!(
  email: "admin@forumx.io",
  username: "admin",
  display_name: "Lead Administrator",
  password: "Password123!",
  password_confirmation: "Password123!",
  role: :admin,
  reputation: 150,
  bio: "Platform architect and lead community administrator for ForumX.",
  location: "San Francisco, CA",
  website: "https://forumx.io"
)

# 2. Moderator
moderator = User.create!(
  email: "moderator@forumx.io",
  username: "mod_sarah",
  display_name: "Sarah Chen",
  password: "Password123!",
  password_confirmation: "Password123!",
  role: :moderator,
  reputation: 95,
  bio: "Senior systems engineer and ForumX moderation council member.",
  location: "Seattle, WA",
  website: "https://github.com"
)

# 3. Standard Demo User
demo_user = User.create!(
  email: "user@forumx.io",
  username: "alex_dev",
  display_name: "Alex Dev",
  password: "Password123!",
  password_confirmation: "Password123!",
  role: :user,
  reputation: 42,
  bio: "Full-stack web developer passionate about Rails, PostgreSQL, and Hotwire.",
  location: "Austin, TX",
  website: "https://alexdev.me"
)

# Additional 22 realistic community members
seed_user_data = [
  { username: "marcus_k", name: "Marcus Kowalski", email: "marcus@example.com", role: :user, rep: 68, loc: "Berlin, DE" },
  { username: "elena_v", name: "Elena Vasquez", email: "elena@example.com", role: :user, rep: 84, loc: "Madrid, ES" },
  { username: "liam_tech", name: "Liam O'Connor", email: "liam@example.com", role: :user, rep: 34, loc: "Dublin, IE" },
  { username: "priya_sharma", name: "Priya Sharma", email: "priya@example.com", role: :user, rep: 110, loc: "Bangalore, IN" },
  { username: "david_sec", name: "David Kim", email: "david@example.com", role: :user, rep: 56, loc: "Seoul, KR" },
  { username: "chloe_cloud", name: "Chloe Martin", email: "chloe@example.com", role: :user, rep: 72, loc: "Montreal, CA" },
  { username: "kenji_s", name: "Kenji Sato", email: "kenji@example.com", role: :user, rep: 90, loc: "Tokyo, JP" },
  { username: "nathan_b", name: "Nathan Brooks", email: "nathan@example.com", role: :user, rep: 22, loc: "London, UK" },
  { username: "zoe_ai", name: "Zoe Patel", email: "zoe@example.com", role: :user, rep: 125, loc: "Boston, MA" },
  { username: "gabriel_m", name: "Gabriel Silva", email: "gabriel@example.com", role: :user, rep: 48, loc: "São Paulo, BR" },
  { username: "amira_h", name: "Amira Hassan", email: "amira@example.com", role: :user, rep: 62, loc: "Cairo, EG" },
  { username: "thomas_w", name: "Thomas Weber", email: "thomas@example.com", role: :user, rep: 30, loc: "Zurich, CH" },
  { username: "olivia_r", name: "Olivia Rossi", email: "olivia@example.com", role: :user, rep: 50, loc: "Milan, IT" },
  { username: "devon_codes", name: "Devon Clark", email: "devon@example.com", role: :user, rep: 18, loc: "Denver, CO" },
  { username: "maya_lin", name: "Maya Lin", email: "maya@example.com", role: :user, rep: 96, loc: "Singapore, SG" },
  { username: "samuel_p", name: "Samuel Perez", email: "samuel@example.com", role: :user, rep: 40, loc: "Mexico City, MX" },
  { username: "ananya_g", name: "Ananya Gupta", email: "ananya@example.com", role: :user, rep: 76, loc: "New Delhi, IN" },
  { username: "josh_frontend", name: "Josh Evans", email: "josh@example.com", role: :user, rep: 58, loc: "Sydney, AU" },
  { username: "hannah_sys", name: "Hannah Schmidt", email: "hannah@example.com", role: :user, rep: 82, loc: "Vienna, AT" },
  { username: "lucas_data", name: "Lucas Moreau", email: "lucas@example.com", role: :user, rep: 64, loc: "Paris, FR" },
  { username: "bad_actor", name: "Troll Account", email: "spammer@example.com", role: :user, rep: 0, loc: "Unknown" },
  { username: "sophie_ops", name: "Sophie Taylor", email: "sophie@example.com", role: :moderator, rep: 105, loc: "Toronto, CA" }
]

all_users = [admin, moderator, demo_user]
seed_user_data.each do |ud|
  u = User.create!(
    email: ud[:email],
    username: ud[:username],
    display_name: ud[:name],
    password: "Password123!",
    password_confirmation: "Password123!",
    role: ud[:role],
    reputation: ud[:rep],
    bio: "Community member exploring software development, distributed architectures, and modern web applications.",
    location: ud[:loc]
  )
  all_users << u
end

# Suspend the bad actor user to demo moderation capability
bad_user = User.find_by(username: "bad_actor")
bad_user.suspend!(reason: "Spamming commercial affiliate links across discussion topics.")
ModerationLog.create!(
  moderator: admin,
  action: "suspend_user",
  target_type: "User",
  target_id: bad_user.id,
  reason: "Spamming commercial affiliate links",
  metadata: { username: "bad_actor" }
)

puts "== Creating Categories =="
categories_data = [
  { name: "Web Development", slug: "web-development", description: "Frontend and backend frameworks, Hotwire, Tailwind CSS, API architectures, and web standards.", color: "#4f46e5", pos: 1 },
  { name: "Programming", slug: "programming", description: "Language syntax, algorithms, data structures, and best coding practices.", color: "#06b6d4", pos: 2 },
  { name: "Cybersecurity", slug: "cybersecurity", description: "Application security, authentication systems, cryptography, and vulnerability defense.", color: "#e11d48", pos: 3 },
  { name: "Artificial Intelligence", slug: "artificial-intelligence", description: "Machine learning, LLMs, NLP, neural architectures, and intelligent agent workflows.", color: "#8b5cf6", pos: 4 },
  { name: "Open Source", slug: "open-source", description: "Collaborative project maintainership, open licensing, RFCs, and contribution guides.", color: "#10b981", pos: 5 },
  { name: "Career", slug: "career", description: "Career development, engineering leadership, interview prep, and tech industry insights.", color: "#f59e0b", pos: 6 },
  { name: "Technology", slug: "technology", description: "Hardware innovations, cloud infrastructure, distributed systems, and tech news.", color: "#3b82f6", pos: 7 },
  { name: "Gaming", slug: "gaming", description: "Game engine design, graphics rendering, multiplayer networking, and game dev pipelines.", color: "#ec4899", pos: 8 },
  { name: "Project Showcase", slug: "project-showcase", description: "Present your completed apps, open-source gems, and community tools for peer feedback.", color: "#14b8a6", pos: 9 },
  { name: "General Discussion", slug: "general-discussion", description: "Casual watercooler conversations, developer setups, productivity habits, and book recommendations.", color: "#64748b", pos: 10 }
]

created_categories = {}
categories_data.each do |cdata|
  created_categories[cdata[:slug]] = Category.create!(
    name: cdata[:name],
    slug: cdata[:slug],
    description: cdata[:description],
    color_accent: cdata[:color],
    position: cdata[:pos]
  )
end

puts "== Creating Tags =="
tag_names = %w[ruby rails postgresql javascript typescript security hotwire turbo stimulus devops ai architecture render sidekiq career testing rspec performance api docker]
created_tags = {}
tag_names.each do |tname|
  created_tags[tname] = Tag.create!(name: tname, slug: tname)
end

puts "== Creating Realistic Discussions & Nested Replies =="

discussions_templates = [
  {
    title: "Best practices for architecting PostgreSQL Full-Text Search in Rails 8?",
    cat: "web-development",
    author: demo_user,
    tags: %w[rails postgresql architecture performance],
    body: <<~MARKDOWN
      When building a scalable search experience without introducing external search clusters like Elasticsearch, what are the recommended patterns for PostgreSQL Full-Text Search?

      Specifically:
      * Should we use generated columns with `tsvector` or index on expression `to_tsvector('english', title || ' ' || body)`?
      * How do you handle multi-table search ranking with `ts_rank`?
      * What are the indexing tradeoffs between GiST and GIN in high-write forum applications?

      Would appreciate insights from anyone running high-throughput FTS in production!
    MARKDOWN
  },
  {
    title: "How to properly secure Devise authentication against session hijacking and brute-force?",
    cat: "cybersecurity",
    author: "david_sec",
    tags: %w[security rails architecture],
    body: <<~MARKDOWN
      Security audit checklist for modern Rails web applications using Devise:

      ```ruby
      # config/initializers/devise.rb
      config.lock_strategy = :failed_attempts
      config.unlock_strategy = :time
      config.maximum_attempts = 5
      config.unlock_in = 1.hour
      ```

      Beyond standard Devise configuration:
      1. How do you configure strict Content Security Policy (`CSP`) headers for Hotwire applications?
      2. What is the recommended strategy for expiring stale sessions on password resets?
      3. Are there automated scanning tools you integrate with CI/CD alongside Brakeman?
    MARKDOWN
  },
  {
    title: "Hotwire vs SPA Frameworks in 2026: Why Rails + Turbo is winning developer velocity",
    cat: "web-development",
    author: "priya_sharma",
    tags: %w[hotwire turbo rails javascript],
    body: <<~MARKDOWN
      Over the past few years, our engineering team migrated several legacy React applications back to Rails 8 with Hotwire (Turbo Drive, Frames, Streams, and Stimulus).

      Key advantages observed:
      * **Single codebase**: Server-rendered ERB with Turbo Streams eliminated 80% of our custom state management.
      * **Instant responses**: Turbo Frames allow granular component updates without full page reloads.
      * **Zero JSON serialization boilerplate**: No need to duplicate models into TypeScript interfaces.

      What has been your experience transitioning to Hotwire for rich, interactive community platforms?
    MARKDOWN
  },
  {
    title: "Implementing Background Job Processing with Sidekiq and Redis on Render",
    cat: "web-development",
    author: "chloe_cloud",
    tags: %w[rails sidekiq devops render],
    body: <<~MARKDOWN
      When deploying Rails to cloud PaaS like Render, separating web processes from asynchronous worker processes is critical for request latency:

      ```yaml
      # render.yaml snippet
      services:
        - type: worker
          name: forumx-worker
          env: ruby
          buildCommand: bundle install
          startCommand: bundle exec sidekiq
      ```

      Key recommendations:
      - Always configure connection pooling for Redis in `config/initializers/sidekiq.rb`.
      - Use Active Job with Sidekiq adapter for mailers, notification deliveries, and mention parsing.
      - Keep jobs idempotent so retries do not duplicate state.
    MARKDOWN
  },
  {
    title: "Understanding Recursive Common Table Expressions (CTEs) for Hierarchical Discussion Trees",
    cat: "programming",
    author: "marcus_k",
    tags: %w[postgresql architecture performance],
    body: <<~MARKDOWN
      Recursive threaded comment trees can be queried efficiently using PostgreSQL Recursive CTEs:

      ```sql
      WITH RECURSIVE reply_tree AS (
        SELECT id, parent_reply_id, body, 0 AS depth
        FROM replies
        WHERE parent_reply_id IS NULL AND discussion_id = 1
        UNION ALL
        SELECT r.id, r.parent_reply_id, r.body, rt.depth + 1
        FROM replies r
        INNER JOIN reply_tree rt ON r.parent_reply_id = rt.id
      )
      SELECT * FROM reply_tree ORDER BY depth, id;
      ```

      This avoids deep N+1 queries when loading nested comment threads.
    MARKDOWN
  },
  {
    title: "AI Agent Orchestration: Best practices for integrating LLMs into web services",
    cat: "artificial-intelligence",
    author: "zoe_ai",
    tags: %w[ai api architecture],
    body: <<~MARKDOWN
      As autonomous agents and LLMs become standard components of modern software architectures:

      1. How do you implement robust fallback mechanisms when LLM inference endpoints fail?
      2. What caching strategies (semantic caching via vector embeddings) do you employ to reduce token consumption?
      3. How do you safeguard against prompt injection when processing user-generated text?
    MARKDOWN
  },
  {
    title: "Showcase: ForumX - Final-Year Academic Capstone Project built with Rails & Hotwire",
    cat: "project-showcase",
    author: demo_user,
    tags: %w[rails hotwire postgresql architecture],
    body: <<~MARKDOWN
      Hey everyone! Excited to showcase **ForumX**, my final-year university capstone project.

      ### Architecture Overview:
      * **Backend**: Ruby on Rails with Active Record & PostgreSQL
      * **Frontend**: Vanilla Hotwire (Turbo Drive, Turbo Frames, Turbo Streams) + Stimulus + Tailwind CSS
      * **Auth & Authorization**: Devise + Pundit policy engine
      * **Search**: Native PostgreSQL full-text search with GIN index
      * **DevOps**: Native Render deployment, Sidekiq background jobs, Zero Docker!

      Check out the repository and let me know your thoughts on code structure and UX polish!
    MARKDOWN
  },
  {
    title: "Career Advice: Navigating the transition from Junior to Senior Software Engineer",
    cat: "career",
    author: "maya_lin",
    tags: %w[career architecture],
    body: <<~MARKDOWN
      The biggest differentiator between mid-level and senior engineers is rarely raw syntax speed.

      Instead, senior engineering revolves around:
      1. **System design and tradeoff evaluation**: Choosing boring, maintainable tech over trendy hype.
      2. **Communication and mentorship**: Unblocking teammates and writing clear technical design docs.
      3. **Operational empathy**: Building observability, logging, and automated tests into every feature.

      What was the single most pivotal habit that accelerated your career growth?
    MARKDOWN
  },
  {
    title: "Preventing N+1 Queries in Complex Relational Rails Applications",
    cat: "web-development",
    author: "liam_tech",
    tags: %w[rails postgresql performance],
    body: <<~MARKDOWN
      Always remember to eager load polymorphic associations and nested relations:

      ```ruby
      # In controller
      @discussions = Discussion.includes(:user, :category, :tags).latest.page(params[:page])
      ```

      Tools like `bullet` and Rails 8's strict loading (`strict_loading_by_default`) ensure queries remain bounded and performant.
    MARKDOWN
  },
  {
    title: "Open Source Governance: How to maintain healthy contributor communities",
    cat: "open-source",
    author: "elena_v",
    tags: %w[open-source career],
    body: <<~MARKDOWN
      Maintaining an active open source library requires more than code:
      * Clear `CONTRIBUTING.md` and issue templates
      * Automated CI workflows verifying tests, linters, and security scanners
      * Timely, encouraging code reviews for first-time contributors
      * Welcoming code of conduct enforced consistently
    MARKDOWN
  }
]

# Generate additional 42 discussions across categories to reach 52 total discussions
extra_discussion_topics = [
  "Understanding Ruby 3.3 YJIT Performance Gains in Real-World Web Apps",
  "How to configure Tailwind CSS v4 with modern Rails asset pipelines",
  "Design Patterns: When to use Service Objects vs Model Concerns in Rails",
  "Zero-Downtime Database Migrations in PostgreSQL with Active Record",
  "Testing Turbo Streams and Stimulus controllers effectively with RSpec",
  "Demystifying Content Security Policy (CSP) for WebSocket and ActionCable",
  "Building an Auditable Moderation Engine for Online Communities",
  "State of Open Source Game Engines in 2026: Godot vs Bevy",
  "How to architect multi-tenant SaaS databases: Schema vs Row-level separation",
  "Clean Code in Ruby: Structuring thin controllers and focused models",
  "Mastering Git: Rebase vs Merge workflows in collaborative engineering teams",
  "Database Indexing Strategies for B-Tree, Hash, and GIN indexes in PostgreSQL",
  "Building Accessible Web Applications: ARIA labels, focus traps, and keyboard navigation",
  "Managing Environment Variables and Production Secrets without Leaks",
  "Asynchronous Event Notification Patterns: Webhooks vs Message Queues",
  "Setting up RuboCop and Brakeman for automated CI code quality gates",
  "Microservices vs Modular Monolith: Why monolithic Rails remains the gold standard",
  "Deploying Production Rails Web Services on Render without Docker",
  "Optimizing SQL queries with EXPLAIN ANALYZE and Index Only Scans",
  "Creating Custom Error Pages (404, 403, 500) matching your design system",
  "Designing User Reputation and Badge Systems to incentivize helpful contributions",
  "Securing File Uploads with Active Storage and Direct S3/Blob Uploads",
  "How to handle @mentions parsing safely without regex catastrophic backtracking",
  "Best practices for Database Seeding: Creating realistic demo datasets",
  "The Role of FactoryBot and Faker in Test-Driven Development",
  "Building Responsive Mobile Drawers with Stimulus without bloated JS libraries",
  "Handling Soft Deletions and Content Archival gracefully in relational databases",
  "Designing High-Impact Capstone Projects for Computer Science Degrees",
  "Understanding Pundit Policy Scopes for multi-role authorization",
  "Preventing Self-Voting and Sybil Attacks in Community Platforms",
  "How to scale Redis caching for frequent database reads",
  "Modern CSS Layouts: Grid vs Flexbox for complex editorial interfaces",
  "Engineering Productivity: Terminal workflows, tmux, and developer ergonomics",
  "Building a Dark Mode theme with Tailwind CSS and CSS Custom Properties",
  "Database Transactions in Rails: Handling nested savepoints and rollbacks",
  "API Design: RESTful conventions vs GraphQL for community platforms",
  "Implementing Toast Notifications with Hotwire Turbo Streams",
  "How to write clear technical documentation in markdown for GitHub",
  "Refactoring Legacy Codebases: Safe incremental modernization techniques",
  "Understanding Cross-Site Request Forgery (CSRF) protection in Rails",
  "Setting up automated database backups and disaster recovery plans",
  "The Future of Web Development: Native browsers, importmaps, and Hotwire"
]

all_discussions = []

# Create the 10 featured discussions
discussions_templates.each_with_index do |dt, idx|
  author = dt[:author].is_a?(User) ? dt[:author] : User.find_by(username: dt[:author]) || all_users.sample
  cat = created_categories[dt[:cat]] || created_categories.values.sample

  disc = Discussion.create!(
    user: author,
    category: cat,
    title: dt[:title],
    body: dt[:body],
    pinned: idx == 0 || idx == 6,
    status: idx == 1 ? :locked : :open,
    view_count: rand(45..350),
    vote_score: rand(5..45),
    created_at: (15 - idx).days.ago
  )

  # Attach tags
  dt[:tags].each do |tname|
    tag = created_tags[tname] || Tag.find_or_create_by!(name: tname)
    DiscussionTag.create!(discussion: disc, tag: tag)
  end

  all_discussions << disc
end

# Create the extra 42 discussions
extra_discussion_topics.each_with_index do |topic, idx|
  author = (all_users - [bad_user]).sample
  cat = created_categories.values.sample

  disc = Discussion.create!(
    user: author,
    category: cat,
    title: topic,
    body: "In this thread, let's explore detailed patterns, tradeoffs, and practical architectural advice regarding #{topic}. What approaches have worked best in your production environments?",
    pinned: false,
    status: :open,
    view_count: rand(10..220),
    vote_score: rand(0..25),
    created_at: (30 - idx / 2).days.ago + rand(1..20).hours
  )

  # Random tags
  created_tags.values.sample(rand(2..4)).each do |tag|
    DiscussionTag.find_or_create_by(discussion: disc, tag: tag)
  end

  all_discussions << disc
end

puts "Created #{all_discussions.size} discussions."

puts "== Creating 160+ Replies with Nested Threads =="
replies_count = 0

sample_replies_content = [
  "Excellent points raised! In our experience, using generated `tsvector` columns with GIN indexes in PostgreSQL yielded 10x query speedups compared to runtime conversion.",
  "Agreed. Make sure to also configure `pg_search` or custom ActiveRecord scopes with `ts_rank` to order by relevance.",
  "Don't forget to sanitize any user-supplied terms before querying `to_tsquery` to prevent syntax exceptions.",
  "This is a crucial security consideration. We always enforce session invalidation on password changes in Devise.",
  "Great summary. We also pair Brakeman with Bundler Audit in our GitHub Actions pipeline for complete dependency vulnerability scanning.",
  "I transitioned from a complex Next.js SPA to Rails 8 with Hotwire last year and our delivery speed tripled.",
  "Hotwire's Turbo Frames make multi-step workflows incredibly smooth without managing client-side routers.",
  "For Sidekiq on Render, make sure to set `concurrency: 5` or match your database connection pool limit in `config/database.yml`.",
  "The Recursive CTE pattern is brilliant. It completely eliminates unbounded queries when rendering comment hierarchies.",
  "Senior engineering is definitely about managing complexity and communicating tradeoffs rather than just writing more code.",
  "Always check for N+1 queries during code reviews using bullet or strict loading in development.",
  "Really impressed by the clean layout and responsive design in ForumX! Great capstone demonstration.",
  "Make sure to test edge cases where locked discussions reject inline replies gracefully.",
  "Thanks for sharing this! Bookmarked for my team's upcoming architecture refactoring sprint."
]

all_discussions.each_with_index do |disc, d_idx|
  # Create 2 to 5 root replies per discussion
  num_roots = rand(2..5)
  num_roots.times do |r_idx|
    author = (all_users - [bad_user, disc.user]).sample || admin
    body_text = sample_replies_content.sample

    # Occasionally include a mention
    if rand < 0.35
      body_text += " What are your thoughts @#{disc.user.username}?"
    end

    root_reply = Reply.create!(
      discussion: disc,
      user: author,
      body: body_text,
      vote_score: rand(1..18),
      created_at: disc.created_at + (r_idx + 1).hours
    )
    replies_count += 1

    # Check for @mentions in seed reply
    Mentions::MentionParser.parse_and_notify!(root_reply, author)

    # 50% chance of 1 or 2 nested child replies
    if rand > 0.4
      child_author = (all_users - [bad_user, author]).sample || moderator
      child_reply = Reply.create!(
        discussion: disc,
        user: child_author,
        parent_reply: root_reply,
        body: "Building on @#{author.username}'s response: another critical aspect is monitoring latency metrics in production.",
        vote_score: rand(0..8),
        created_at: root_reply.created_at + 30.minutes
      )
      replies_count += 1

      # 25% chance of level 2 nested reply (child of child)
      if rand > 0.6
        grandchild_author = disc.user
        Reply.create!(
          discussion: disc,
          user: grandchild_author,
          parent_reply: child_reply,
          body: "Thank you both! That clarifies the exact tradeoff I was evaluating.",
          vote_score: rand(1..5),
          created_at: child_reply.created_at + 15.minutes
        )
        replies_count += 1
      end
    end
  end

  # For first 5 discussions, mark one reply as accepted answer
  if d_idx < 5 && disc.replies.any?
    accepted = disc.replies.first
    disc.accept_reply!(accepted)
  end
end

puts "Created #{replies_count} replies."

puts "== Creating Votes, Bookmarks, and Subscriptions =="
all_discussions.take(20).each do |disc|
  # Voters
  voters = (all_users - [disc.user, bad_user]).sample(rand(3..8))
  voters.each do |voter|
    Vote.create!(user: voter, voteable: disc, value: 1) rescue nil
  end

  # Bookmark
  bookmarkers = (all_users - [bad_user]).sample(rand(2..5))
  bookmarkers.each do |bm|
    Bookmark.create!(user: bm, discussion: disc) rescue nil
  end

  # Subscriptions
  subscribers = (all_users - [bad_user]).sample(rand(2..6))
  subscribers.each do |sub|
    Subscription.create!(user: sub, discussion: disc) rescue nil
  end
end

puts "== Creating Reports & Moderation Logs =="
# User reports
report_target = all_discussions.last
Report.create!(
  reporter: demo_user,
  reportable: report_target,
  reason: "Off-topic",
  description: "Discussion topic seems somewhat tangential to current channel goals.",
  status: :pending
)

Report.create!(
  reporter: all_users[3],
  reportable: all_discussions.first.replies.first,
  reason: "Spam",
  description: "Automated test report to demonstrate moderator review queue.",
  status: :pending
)

# Award badges to active users
all_users.each do |u|
  Badges::BadgeAwarder.check_and_award!(u)
end

puts "================================================="
puts "ForumX Database Seed Completed Successfully!"
puts "Total Users:       #{User.count}"
puts "Total Categories:  #{Category.count}"
puts "Total Discussions: #{Discussion.count}"
puts "Total Replies:     #{Reply.count}"
puts "Total Badges:      #{Badge.count}"
puts "Demo Accounts:"
puts "  Admin:     admin@forumx.io      / Password123!"
puts "  Moderator: moderator@forumx.io  / Password123!"
puts "  User:      user@forumx.io       / Password123!"
puts "================================================="
