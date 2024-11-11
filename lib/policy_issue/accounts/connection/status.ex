defmodule PolicyIssue.Accounts.Connection.Status do
  use Gettext, backend: PolicyIssueWeb.Gettext

  use Ash.Type.Enum,
    values: [
      pending: gettext("Pending"),
      accepted: gettext("Accepted"),
      rejected: gettext("Rejected")
    ]
end
