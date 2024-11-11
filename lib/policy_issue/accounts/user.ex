defmodule PolicyIssue.Accounts.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: PolicyIssue.Accounts.Domain,
    authorizers: [Ash.Policy.Authorizer]

  use Gettext, backend: PolicyIssueWeb.Gettext

  postgres do
    table "users"
    repo PolicyIssue.Repo
  end

  identities do
    identity :unique_email, [:email]
  end

  attributes do
    uuid_primary_key :id
    attribute :email, :ci_string, allow_nil?: false, public?: true
    attribute :first_name, :string, allow_nil?: false, public?: true
    attribute :last_name, :string, allow_nil?: false, public?: true
    attribute :photo_url, :string, allow_nil?: true
    attribute :locale, PolicyIssue.Accounts.Locale, default: :en, allow_nil?: false, public?: true

    attribute :type, PolicyIssue.Accounts.UserType,
      allow_nil?: false,
      public?: true,
      default: :attendee

    attribute :admin, :boolean,
      allow_nil?: false,
      writable?: false,
      public?: false,
      default: false

    timestamps()
  end

  relationships do
    has_many :social_medias, PolicyIssue.Accounts.SocialMedia, public?: true

    has_many :connections, PolicyIssue.Accounts.Connection do
      no_attributes? true
      filter expr(to_user_id == parent(id) or from_user_id == parent(id))
    end

    has_many :accepted_connections, PolicyIssue.Accounts.Connection do
      no_attributes? true

      filter expr(
               (to_user_id == parent(id) or from_user_id == parent(id)) and status == :accepted
             )
    end

    has_many :pending_connections, PolicyIssue.Accounts.Connection do
      no_attributes? true
      filter expr(to_user_id == parent(id) and status == :pending)
    end

    has_many :sent_connections, PolicyIssue.Accounts.Connection do
      no_attributes? true
      filter expr(from_user_id == parent(id) and status == :pending)
    end

    has_many :friends, __MODULE__ do
      no_attributes? true

      filter expr(
               (accepted_connections.to_user_id == parent(id) or
                  accepted_connections.from_user_id == parent(id)) and id != parent(id)
             )
    end
  end

  actions do
    defaults [:read]
  end

  policies do
    policy action_type(:read) do
      authorize_if always()
    end
  end

  field_policies do
    field_policy_bypass :* do
      authorize_if actor_attribute_equals(:admin, true)
    end

    field_policy [:email] do
      authorize_if expr(id == ^actor(:id))
      authorize_if relates_to_actor_via(:friends)
    end

    field_policy :* do
      authorize_if actor_present()
    end
  end
end
