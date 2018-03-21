defmodule Chat.Messages do
  @moduledoc """
  The Messages context.
  """

  import Ecto.Query, warn: false
  alias Chat.Repo
  alias Chat.Messages.Message
  alias Chat.User
  alias Ecto.UUID

  @paginate_by 30

  @doc """
  Returns the list of chat_messages.

  ## Examples

      iex> list_chat_messages()
      [%Message{}, ...]

  """
  def list_chat_messages do
    Repo.all(Message)
  end

  @doc """
  List all messages in a chat room.
  """
  def list_chat_room_messages(room_id, user_id) do
    query = from m in Message,
        where: m.chat_room_id == ^room_id, 
        order_by: [desc: m.inserted_at],
        limit: @paginate_by
      
    query = from sq in subquery(query),
      order_by: [asc: sq.inserted_at],
      preload: :user

    Repo.all(query)
  end
  
  @doc """
  List all messages in a chat room older than 'older_than'
  """
  def list_chat_room_messages(room_id, user_id, older_than) do
    query = from m in Message,
      where: m.chat_room_id == ^room_id and m.inserted_at < ^older_than,
      order_by: [desc: m.inserted_at],
      limit: @paginate_by
    
    query = from sq in subquery(query),
      order_by: [asc: sq.inserted_at],
      preload: :user

    Repo.all(query)
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{source: %Message{}}

  """
  def change_message(%Message{} = message) do
    Message.changeset(message, %{})
  end
end
