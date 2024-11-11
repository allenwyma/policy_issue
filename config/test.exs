import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :policy_issue, PolicyIssue.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "policy_issue_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :policy_issue, PolicyIssueWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "PiB8cP4Hj6z9xfiRh33y4t6/Vidd+JRsFm7mpAIrgK8mpZ4yQqcikVTok5R3W4As",
  server: false

# In test we don't send emails
config :policy_issue, PolicyIssue.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
  config :ash, :policies, show_policy_breakdowns?: true, log_policy_breakdowns: :error, log_successful_policy_breakdowns: :error