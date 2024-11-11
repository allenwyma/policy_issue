defmodule PolicyIssue.Accounts.Connection do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: PolicyIssue.Accounts.Domain,
    authorizers: [Ash.Policy.Authorizer]

  use Gettext, backend: PolicyIssueWeb.Gettext
  require Ash.Query

  postgres do
    table "connections"
    repo PolicyIssue.Repo

    references do
      reference :from_user, on_delete: :delete, index?: true
    end

    references do
      reference :to_user, on_delete: :delete, index?: true
    end
  end

  identities do
    identity :unique_connection, [:from_user_id, :to_user_id]
  end

  actions do
    defaults [:read]

    create :create do
      accept [:to_user_id]
      change set_attribute(:status, :pending)
      change relate_actor(:from_user)

      change fn changeset, %{actor: %{id: from_user_id}} ->
        Ash.Changeset.before_action(changeset, fn changeset ->
          to_user_id = Ash.Changeset.get_attribute(changeset, :to_user_id)

          query =
            Ash.Query.filter(
              __MODULE__,
              to_user_id == ^from_user_id and from_user_id == ^to_user_id
            )

          if Ash.exists?(query, authorize?: false) do
            Ash.Changeset.add_error(changeset,
              field: :to_user_id,
              message: gettext("cannot connect to this user")
            )
          else
            changeset
          end
        end)
      end
    end

    update :accept do
      accept []
      change set_attribute(:status, :accepted)
    end

    update :reject do
      accept []
      change set_attribute(:status, :rejected)
    end
  end

  relationships do
    belongs_to :from_user, PolicyIssue.Accounts.User, allow_nil?: false, public?: true
    belongs_to :to_user, PolicyIssue.Accounts.User, allow_nil?: false, public?: true
  end

  attributes do
    uuid_primary_key :id

    attribute :status, PolicyIssue.Accounts.Connection.Status,
      allow_nil?: false,
      default: :pending,
      public?: true

    timestamps()
  end

  policies do
    bypass actor_attribute_equals(:admin, true) do
      authorize_if always()
    end

    policy action(:create) do
      authorize_if always()
    end

    policy action(:read) do
      authorize_if relates_to_actor_via(:to_user)
      authorize_if relates_to_actor_via(:from_user)
    end

    policy action([:accept, :reject]) do
      authorize_if relates_to_actor_via(:to_user)
    end
  end
end
