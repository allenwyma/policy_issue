defmodule PolicyIssue.Repo do
  use AshPostgres.Repo, otp_app: :policy_issue

  def installed_extensions, do: ["uuid-ossp", "citext", "ash-functions"]

  def min_pg_version, do: %Version{major: 16, minor: 0, patch: 0}
end
