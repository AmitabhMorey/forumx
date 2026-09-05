# FORUMX Moderation & Governance Engine

## 1. Overview & Community Governance Model

FORUMX features a first-class, comprehensive moderation suite that balances community safety with transparency. All administrative actions are strictly audited and permanently logged in the database.

---

## 2. Role Hierarchy & Permissions

### 2.1 Standard User (`role: 0`)
- Can create discussions, post replies, and submit votes.
- Can edit and delete their own open discussions and comments.
- Can flag abusive content by submitting a formal report.
- Can bookmark threads and subscribe to notification feeds.

### 2.2 Community Moderator (`role: 1`)
- Access to the `/admin` moderation portal.
- Can **pin/unpin** discussions to highlight community notices.
- Can **lock/unlock** discussions to prevent further comments during flame wars.
- Can **hide/restore** inappropriate or abusive replies.
- Can review and resolve the flagged content queue (`/admin/reports`).
- Can temporarily or permanently **suspend users** from the platform.
- Cannot alter user roles or delete categories.

### 2.3 System Administrator (`role: 2`)
- Full superuser capabilities.
- Can promote users to moderators or demote them.
- Can create, edit, colorize, and delete platform categories.
- Can view platform-wide business analytics and usage metrics.

---

## 3. Moderation Features & Workflows

### 3.1 The Moderation Dashboard (`/admin`)
The admin dashboard provides high-level health metrics:
- Active vs. Suspended user counts.
- Pending reported items needing urgent review.
- Recent moderation action stream.
- Category breakdown and discussion density.

### 3.2 Thread Actions
Moderators can perform actions directly from discussion pages or from `/admin/discussions`:
- **Pin / Unpin**: Pinned discussions always float to the top of the feed with an amber pin badge.
- **Lock / Unlock**: Locked discussions disable all reply forms for non-moderators while preserving existing comments.
- **Archive / Remove**: Discussions violating safety policies are archived and hidden from public searches.

### 3.3 Flag & Report Queue (`/admin/reports`)
When a community member clicks "Report" on a discussion or reply, they can select a violation category:
- `spam`
- `harassment`
- `hate_speech`
- `inappropriate`
- `off_topic`
- `other`

Moderators can:
1. Review the flagged content in context.
2. Mark the report as **Resolved** (taking corrective action on the author or post).
3. Mark the report as **Dismissed** (false positive).

### 3.4 Moderation Audit Trail (`moderation_logs`)
Every action taken by a moderator writes an immutable audit record:
- `moderator_id`: The staff member executing the action.
- `action`: e.g. `lock_discussion`, `remove_reply`, `suspend_user`, `update_role`.
- `target_type` & `target_id`: Polymorphic reference to the modified record.
- `reason`: Required rationale entered by the moderator.
- `metadata`: JSON payload recording previous state and supplemental details.
