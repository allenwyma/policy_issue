defmodule PolicyIssue.Accounts.Locale do
  use Ash.Type.Enum, values: [en: "English", zh_CN: "简体", zh_HK: "繁體"]
end
