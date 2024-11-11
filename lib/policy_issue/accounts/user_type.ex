defmodule PolicyIssue.Accounts.UserType do
  use Gettext, backend: PolicyIssueWeb.Gettext
  use Ash.Type.Enum, values: [staff: gettext("Staff"), attendee: gettext("Attendee")]
end
