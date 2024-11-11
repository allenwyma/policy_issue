defmodule PolicyIssue.Accounts.SocialMedia.Type do
  use Gettext, backend: PolicyIssueWeb.Gettext

  use Ash.Type.Enum,
    values: [
      linkedin: gettext("LinkedIn"),
      phone: gettext("Phone"),
      whatsapp: gettext("WhatsApp"),
      wechat: gettext("WeChat"),
      signal: gettext("Signal"),
      telegram: gettext("Telegram"),
      instagram: gettext("instagram")
    ]
end
