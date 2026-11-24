-- The GitHub bot's review sessions for a pull request (review requests and
-- auto-reviews; mentions are never rows here).
--
-- superseded_by is NULL on the pull request's current review. A newer review
-- sets it on the one it replaces and then cancels that session; once the
-- cancel succeeds the row is deleted. A row with superseded_by set is
-- therefore a displaced review whose cancel has not succeeded yet: the next
-- review of the same pull request retries it by session id, and the control
-- plane refuses the github-bot's prompts to it.
CREATE TABLE github_pr_review_sessions (
  session_id TEXT PRIMARY KEY,
  repository_id INTEGER NOT NULL,
  pull_number INTEGER NOT NULL,
  superseded_by TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE UNIQUE INDEX idx_github_pr_review_sessions_current
  ON github_pr_review_sessions (repository_id, pull_number)
  WHERE superseded_by IS NULL;

CREATE INDEX idx_github_pr_review_sessions_cancel_pending
  ON github_pr_review_sessions (repository_id, pull_number)
  WHERE superseded_by IS NOT NULL;
