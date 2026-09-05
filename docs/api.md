# FORUMX Endpoint & Internal API Reference

## 1. Overview & Protocol Design

FORUMX employs a clean RESTful resource architecture. Endpoints respond with either standard semantic HTML or reactive Hotwire Turbo Streams (`Accept: text/vnd.turbo-stream.html`).

---

## 2. Public Endpoints

### 2.1 Discussions & Feeds
- **`GET /`**: Home feed of discussions.
  - Query parameters:
    - `category`: Category slug filter (e.g. `?category=ruby-on-rails`).
    - `filter`: Sort option (`latest`, `top`, `unanswered`, `popular`).
    - `page`: Page index (default: `1`, 20 items per page).
- **`GET /discussions/:slug`**: Full thread view with recursive nested replies tree, author metadata, badges, and view counter increments.
- **`GET /categories`**: Directory of all discussion topics with discussion counts and latest activities.
- **`GET /categories/:slug`**: Scoped discussions feed within a specific category.

### 2.2 PostgreSQL Full-Text Search
- **`GET /search`**: Multi-criteria search query.
  - Parameters:
    - `q`: Search string (e.g. `q=database indexing`).
    - `category`: Filter by category ID or slug.
    - `filter`: `top` (by votes) or `latest` (by timestamp).
    - `solved`: `true` to filter solely for resolved questions.

---

## 3. Authenticated User Endpoints

All mutating actions require an active session via Devise cookie authentication and valid CSRF token in the `X-CSRF-Token` header.

### 3.1 Discussions
- **`GET /discussions/new`**: Render discussion creation form with live Markdown preview support.
- **`POST /discussions`**: Create a discussion.
  - Parameters: `discussion[title]`, `discussion[category_id]`, `discussion[body]`, `discussion[tag_list]`.
- **`GET /discussions/:slug/edit`**: Edit existing thread (Pundit authorized: owner or moderator).
- **`PATCH /discussions/:slug`**: Update title, body, or tags.
- **`DELETE /discussions/:slug`**: Soft-delete / archive discussion.
- **`POST /discussions/:slug/accept_answer`**: Mark a specific reply as the accepted solution.
  - Parameters: `reply_id: Integer`.

### 3.2 Replies & Nested Tree
- **`POST /discussions/:discussion_slug/replies`**: Add a reply or child reply.
  - Parameters:
    - `reply[body]`: Markdown comment content.
    - `reply[parent_reply_id]`: (Optional) ID of parent reply to nest under.
  - Responses:
    - HTML redirect to discussion anchor `#reply_<id>`.
    - Turbo Stream appending the rendered partial to `#replies_list` or the parent's nested replies container.
- **`DELETE /discussions/:discussion_slug/replies/:id`**: Soft-delete reply.

### 3.3 Interactive Engagement
- **`POST /votes`**: Cast or toggle an upvote (+1) or downvote (-1).
  - Parameters: `voteable_type` (`Discussion` or `Reply`), `voteable_id`, `value` (`1` or `-1`).
  - Response: Updates cached `vote_score` and swaps vote button styles via Turbo Stream.
- **`POST /discussions/:slug/bookmark`**: Save/unsave thread to user's personal bookmarks library.
- **`POST /discussions/:slug/subscribe`**: Toggle thread notification updates.

### 3.4 Notifications & Profile
- **`GET /notifications`**: List unread and recent notifications with actor avatars and target links.
- **`POST /notifications/mark_all_read`**: Mark all notifications as read.
- **`GET /users/:username`**: Public user profile featuring karma reputation, earned badges, recent threads, and replies.
- **`GET /dashboard`**: User overview with their discussions, bookmarks, and activity history.

---

## 4. Administration & Moderation Endpoints

Protected by `Admin::BaseController` guards (`ensure_moderator_or_admin!` and `ensure_admin!`).

| Method | Path | Action | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/admin` | `dashboard#index` | High-level platform health & stats |
| `GET` | `/admin/statistics` | `dashboard#statistics` | Platform-wide time-series metrics |
| `GET` | `/admin/users` | `users#index` | Searchable user database with role & status filters |
| `GET` | `/admin/users/:username` | `users#show` | Detailed audit profile for specific user |
| `POST` | `/admin/users/:username/suspend` | `users#suspend` | Suspend user account with reason |
| `POST` | `/admin/users/:username/unsuspend` | `users#unsuspend` | Lift account suspension |
| `POST` | `/admin/users/:username/update_role` | `users#update_role` | Update user role (`user`, `moderator`, `admin`) |
| `POST` | `/admin/discussions/:slug/lock` | `discussions#lock` | Lock discussion thread |
| `POST` | `/admin/discussions/:slug/unlock` | `discussions#unlock` | Unlock discussion thread |
| `POST` | `/admin/discussions/:slug/pin` | `discussions#pin` | Pin discussion to top of forum |
| `POST` | `/admin/discussions/:slug/unpin` | `discussions#unpin` | Unpin discussion |
| `GET` | `/admin/reports` | `reports#index` | Flagged content moderation queue |
| `POST` | `/admin/reports/:id/resolve` | `reports#resolve` | Mark violation resolved |
| `POST` | `/admin/reports/:id/dismiss` | `reports#dismiss` | Dismiss false report |
