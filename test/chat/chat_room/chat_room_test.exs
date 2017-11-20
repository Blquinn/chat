defmodule Chat.ChatRoomTest do
  use Chat.DataCase

  alias Chat.ChatRoom

  describe "chat_subscriptions" do
    alias Chat.ChatRoom.ChatSubscription

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def chat_subscription_fixture(attrs \\ %{}) do
      {:ok, chat_subscription} =
        attrs
        |> Enum.into(@valid_attrs)
        |> ChatRoom.create_chat_subscription()

      chat_subscription
    end

    test "list_chat_subscriptions/0 returns all chat_subscriptions" do
      chat_subscription = chat_subscription_fixture()
      assert ChatRoom.list_chat_subscriptions() == [chat_subscription]
    end

    test "get_chat_subscription!/1 returns the chat_subscription with given id" do
      chat_subscription = chat_subscription_fixture()
      assert ChatRoom.get_chat_subscription!(chat_subscription.id) == chat_subscription
    end

    test "create_chat_subscription/1 with valid data creates a chat_subscription" do
      assert {:ok, %ChatSubscription{} = chat_subscription} = ChatRoom.create_chat_subscription(@valid_attrs)
    end

    test "create_chat_subscription/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ChatRoom.create_chat_subscription(@invalid_attrs)
    end

    test "update_chat_subscription/2 with valid data updates the chat_subscription" do
      chat_subscription = chat_subscription_fixture()
      assert {:ok, chat_subscription} = ChatRoom.update_chat_subscription(chat_subscription, @update_attrs)
      assert %ChatSubscription{} = chat_subscription
    end

    test "update_chat_subscription/2 with invalid data returns error changeset" do
      chat_subscription = chat_subscription_fixture()
      assert {:error, %Ecto.Changeset{}} = ChatRoom.update_chat_subscription(chat_subscription, @invalid_attrs)
      assert chat_subscription == ChatRoom.get_chat_subscription!(chat_subscription.id)
    end

    test "delete_chat_subscription/1 deletes the chat_subscription" do
      chat_subscription = chat_subscription_fixture()
      assert {:ok, %ChatSubscription{}} = ChatRoom.delete_chat_subscription(chat_subscription)
      assert_raise Ecto.NoResultsError, fn -> ChatRoom.get_chat_subscription!(chat_subscription.id) end
    end

    test "change_chat_subscription/1 returns a chat_subscription changeset" do
      chat_subscription = chat_subscription_fixture()
      assert %Ecto.Changeset{} = ChatRoom.change_chat_subscription(chat_subscription)
    end
  end
end
