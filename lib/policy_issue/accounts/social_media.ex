defmodule PolicyIssue.Accounts.SocialMedia do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: PolicyIssue.Accounts.Domain,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    repo PolicyIssue.Repo
    table "social_medias"
  end

  attributes do
    uuid_primary_key :id
    attribute :type, PolicyIssue.Accounts.SocialMedia.Type, allow_nil?: false, public?: true
    attribute :handle, :string, allow_nil?: false, public?: true
    timestamps()
  end

  relationships do
    belongs_to :user, PolicyIssue.Accounts.User, allow_nil?: false, public?: true
  end

  actions do
    defaults [:read, :update]
    default_accept [:type, :handle]

    create :create do
      change relate_actor(:user)
    end
  end

  policies do
    bypass actor_attribute_equals(:admin, true) do
      authorize_if always()
    end

    policy action(:create) do
      authorize_if always()
    end

    policy action(:read) do
      authorize_if relates_to_actor_via(:user)
      authorize_if relates_to_actor_via([:user, :friends])
    end

    policy action(:update) do
      authorize_if relates_to_actor_via(:user)
    end
  end
end
