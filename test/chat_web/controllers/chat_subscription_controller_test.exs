defmodule ChatWeb.ChatSubscriptionControllerTest do
  use ChatWeb.ConnCase

  alias Chat.Subscriptions
  alias Chat.Subscriptions.ChatSubscription

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:chat_subscription) do
    {:ok, chat_subscription} = Subscriptions.create_chat_subscription(@create_attrs)
    chat_subscription
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all chat_subscriptions", %{conn: conn} do
      conn = get conn, chat_subscription_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create chat_subscription" do
    test "renders chat_subscription when data is valid", %{conn: conn} do
      conn = post conn, chat_subscription_path(conn, :create), chat_subscription: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, chat_subscription_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, chat_subscription_path(conn, :create), chat_subscription: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update chat_subscription" do
    setup [:create_chat_subscription]

    test "renders chat_subscription when data is valid", %{conn: conn, chat_subscription: %ChatSubscription{id: id} = chat_subscription} do
      conn = put conn, chat_subscription_path(conn, :update, chat_subscription), chat_subscription: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, chat_subscription_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id}
    end

    test "renders errors when data is invalid", %{conn: conn, chat_subscription: chat_subscription} do
      conn = put conn, chat_subscription_path(conn, :update, chat_subscription), chat_subscription: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete chat_subscription" do
    setup [:create_chat_subscription]

    test "deletes chosen chat_subscription", %{conn: conn, chat_subscription: chat_subscription} do
      conn = delete conn, chat_subscription_path(conn, :delete, chat_subscription)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, chat_subscription_path(conn, :show, chat_subscription)
      end
    end
  end

  defp create_chat_subscription(_) do
    chat_subscription = fixture(:chat_subscription)
    {:ok, chat_subscription: chat_subscription}
  end
end
