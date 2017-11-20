defmodule Chat.Subscriptions do
  @moduledoc """
  The Subscriptions context.
  """

  import Ecto.Query, warn: false
  alias Chat.Repo

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
    Repo.all(from r in ChatRoom, inner_join: s in ChatSubscription, where: s.user_id == ^user_id, select: r)
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
