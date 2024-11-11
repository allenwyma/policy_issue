defmodule PolicyIssue.Accounts.Domain do
  use Ash.Domain

  resources do
    resource PolicyIssue.Accounts.Connection
    resource PolicyIssue.Accounts.SocialMedia
    resource PolicyIssue.Accounts.User
  end
end
