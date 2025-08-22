defmodule Mix.Tasks.Jean do
  alias Actions.New.Handlers.Executor, as: New
  @moduledoc """
  Documentation for `Jean`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Jean.hello()
      :world

  """

  use Mix.Task

  def run([cmd | params] = args) when is_bitstring(cmd) do
    case cmd do
      "new" -> New.execute(params)
    end

    {:ok, args}
  end
end
