defmodule PolicyIssue.Factory do
  use Smokestack

  factory PolicyIssue.Accounts.Connection do
    attribute :status, fn -> :pending end
  end

  factory PolicyIssue.Accounts.User do
    attribute :email, &Faker.Internet.email/0
    attribute :last_name, &Faker.Person.En.last_name/0
    attribute :first_name, &Faker.Person.En.first_name/0
    attribute :photo_url, &Faker.Avatar.image_url/0
    attribute :type, fn -> :staff end
    attribute :admin, fn -> false end
    attribute :locale, fn -> :en end
  end
end
