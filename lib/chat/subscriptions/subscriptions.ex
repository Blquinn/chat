defmodule Chat.Subscriptions do
  @moduledoc """
  The Subscriptions context.
  """

  import Ecto.Query, warn: false
  alias Chat.Repo
  alias Chat.User

  alias Chat.Subscriptions.ChatSubscription
  alias Chat.ChatRoom

  @doc """
  Returns the list of chat_subscriptions.

  ## Examples

      iex> list_chat_subscriptions()
      [%ChatSubscription{}, ...]

  """
  def list_chat_subscriptions do
    Repo.all(ChatSubscription)
  end

  @doc """
  Returns a list of subscribed chat rooms
  """
  def list_subscribed_rooms(user_id) do
    query = from r in ChatRoom, 
      inner_join: s in ChatSubscription, 
      on: s.chat_room_id == r.id,
      where: s.user_id == ^user_id,
      select: r
    Repo.all(query)
  end

  @doc """
  Gets a single chat_subscription.

  Raises `Ecto.NoResultsError` if the Chat subscription does not exist.

  ## Examples

      iex> get_chat_subscription!(123)
      %ChatSubscription{}

      iex> get_chat_subscription!(456)
      ** (Ecto.NoResultsError)

  """
  def get_chat_subscription!(id), do: Repo.get!(ChatSubscription, id)

  @doc """
  Creates a chat_subscription.

  ## Examples

      iex> create_chat_subscription(%{field: value})
      {:ok, %ChatSubscription{}}

      iex> create_chat_subscription(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chat_subscription(attrs \\ %{}) do
    %ChatSubscription{}
    |> ChatSubscription.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Insert a chat subscription with a room_id and username.
  """
  def create_chat_subscription_username(%{"chat_room_id" => room_id, "username" => username}) do
    query = from u in User,
      where: u.username == ^username,
      select: u.id

    case Repo.one(query) do
      nil -> {:error, "User not found"}
      uid -> 
        Repo.insert(%ChatSubscription{
          chat_room_id: room_id,
          user_id: uid
        })
    end
  end

  @doc """
  Updates a chat_subscription.

  ## Examples

      iex> update_chat_subscription(chat_subscription, %{field: new_value})
      {:ok, %ChatSubscription{}}

      iex> update_chat_subscription(chat_subscription, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chat_subscription(%ChatSubscription{} = chat_subscription, attrs) do
    chat_subscription
    |> ChatSubscription.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ChatSubscription.

  ## Examples

      iex> delete_chat_subscription(chat_subscription)
      {:ok, %ChatSubscription{}}

      iex> delete_chat_subscription(chat_subscription)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chat_subscription(%ChatSubscription{} = chat_subscription) do
    Repo.delete(chat_subscription)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chat_subscription changes.

  ## Examples

      iex> change_chat_subscription(chat_subscription)
      %Ecto.Changeset{source: %ChatSubscription{}}

  """
  def change_chat_subscription(%ChatSubscription{} = chat_subscription) do
    ChatSubscription.changeset(chat_subscription, %{})
  end
end
