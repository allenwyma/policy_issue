defmodule PolicyIssue.Accounts.UserTest do
  use PolicyIssue.DataCase, async: true
  alias PolicyIssue.Accounts.{Connection, SocialMedia, User}

  describe "friends" do
    setup do
      user1 = insert!(User)
      user2 = insert!(User)
      {:ok, user1: user1, user2: user2}
    end

    test "users are friends when the status is accepted", %{
      user1: %{id: user1_id} = user1,
      user2: %{id: user2_id} = user2
    } do
      insert!(Connection, relate: [from_user: user1, to_user: user2], attrs: %{status: :accepted})
      assert %{friends: [%{id: ^user2_id}]} = Ash.load!(user1, [:friends])
      assert %{friends: [%{id: ^user1_id}]} = Ash.load!(user2, [:friends])
    end

    test "users are not friends until the to_user has accepted", %{user1: user1, user2: user2} do
      assert %{status: :pending} =
               connection =
               Connection
               |> Ash.Changeset.for_create(:create, %{to_user_id: user2.id}, actor: user1)
               |> Ash.create!()

      assert %{friends: []} = Ash.load!(user1, [:friends])
      assert %{friends: []} = Ash.load!(user2, [:friends])
      connection_changeset = Ash.Changeset.for_update(connection, :accept, %{})
      refute Ash.can?(connection_changeset, user1)
      assert Ash.can?(connection_changeset, user2)
      assert %{status: :accepted} = Ash.update!(connection_changeset, actor: user2)
    end

    test "to_user can reject connection only", %{user1: user1, user2: user2} do
      assert %{status: :pending} =
               connection =
               Connection
               |> Ash.Changeset.for_create(:create, %{to_user_id: user2.id}, actor: user1)
               |> Ash.create!()

      assert %{friends: []} = Ash.load!(user1, [:friends])
      assert %{friends: []} = Ash.load!(user2, [:friends])
      connection_changeset = Ash.Changeset.for_update(connection, :reject, %{})
      refute Ash.can?(connection_changeset, user1)
      assert Ash.can?(connection_changeset, user2)
      assert %{status: :rejected} = Ash.update!(connection_changeset, actor: user2)
    end

    test "cannot friend request 2 times", %{user1: user1, user2: user2} do
      insert!(Connection, relate: [from_user: user1, to_user: user2], attrs: %{status: :accepted})

      assert {:error, _changeset} =
               Connection
               |> Ash.Changeset.for_create(:create, %{to_user_id: user2.id}, actor: user1)
               |> Ash.create()

      assert {:error, %{errors: [%{field: :to_user_id, message: "cannot connect to this user"}]}} =
               Connection
               |> Ash.Changeset.for_create(:create, %{to_user_id: user1.id}, actor: user2)
               |> Ash.create()
    end

    test "cannot see email of other user until we are connected", %{
      user1: user1,
      user2: %{email: email} = user2
    } do
      assert %{email: %Ash.ForbiddenField{}} = Ash.get!(User, user2.id, actor: user1)
      insert!(Connection, relate: [from_user: user1, to_user: user2], attrs: %{status: :accepted})
      assert %{email: ^email} = Ash.get!(User, user2.id, actor: user1)
    end
  end

  describe "social medias" do
    setup do
      user1 = insert!(User)
      user2 = insert!(User)
      {:ok, user1: user1, user2: user2}
    end

    test "cannot see a users social until they are friends", %{user1: %{id: user1_id} = user1, user2: %{id: user2_id} = user2} do
      %{id: social_media_id} = social_media =
        SocialMedia
        |> Ash.Changeset.for_create(:create, %{type: :wechat, handle: "test123"}, actor: user2)
        |> Ash.create!()
      assert %{social_medias: []} = Ash.load!(user2, [:social_medias], actor: user1)

      assert %{social_medias: [%{id: ^social_media_id}]} =
               Ash.load!(user2, [:social_medias], actor: user2)

      # TODO: look into this, why it's not working
      insert!(Connection, relate: [from_user: user1, to_user: user2], attrs: %{status: :accepted})
      assert %{friends: [%{id: ^user2_id}]} = Ash.load!(user1, [:friends], authorize?: false)
      assert %{friends: [%{id: ^user1_id}]} = Ash.load!(user2, [:friends], authorize?: false)
      assert Ash.can?({social_media, :read}, user1)
      assert %{social_medias: [%{id: ^social_media_id}]} = Ash.load!(user2, [:social_medias], actor: user1)
    end
  end
end
