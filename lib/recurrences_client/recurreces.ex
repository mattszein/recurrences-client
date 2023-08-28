defmodule RecurrencesClient.Recurreces do
  @moduledoc """
  The Recurreces context.
  """

  import Ecto.Query, warn: false
  alias RecurrencesClient.Repo

  alias RecurrencesClient.Recurreces.Rrules

  @doc """
  Returns the list of rrules.

  ## Examples

      iex> list_rrules()
      [%Rrules{}, ...]

  """
  def list_rrules do
    Repo.all(Rrules)
  end

  @doc """
  Gets a single rrules.

  Raises `Ecto.NoResultsError` if the Rrules does not exist.

  ## Examples

      iex> get_rrules!(123)
      %Rrules{}

      iex> get_rrules!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rrules!(id), do: Repo.get!(Rrules, id)

  @doc """
  Creates a rrules.

  ## Examples

      iex> create_rrules(%{field: value})
      {:ok, %Rrules{}}

      iex> create_rrules(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rrules(attrs \\ %{}) do
    %Rrules{}
    |> Rrules.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a rrules.

  ## Examples

      iex> update_rrules(rrules, %{field: new_value})
      {:ok, %Rrules{}}

      iex> update_rrules(rrules, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rrules(%Rrules{} = rrules, attrs) do
    rrules
    |> Rrules.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a rrules.

  ## Examples

      iex> delete_rrules(rrules)
      {:ok, %Rrules{}}

      iex> delete_rrules(rrules)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rrules(%Rrules{} = rrules) do
    Repo.delete(rrules)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rrules changes.

  ## Examples

      iex> change_rrules(rrules)
      %Ecto.Changeset{data: %Rrules{}}

  """
  def change_rrules(%Rrules{} = rrules, attrs \\ %{}) do
    Rrules.changeset(rrules, attrs)
  end
end
