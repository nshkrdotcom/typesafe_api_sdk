defmodule TypeSafeAPISDK do
  @moduledoc """
  Minimal Elixir client for the TypeSafe System One API.

  This package intentionally owns only the provider-specific HTTP/wire surface.
  Higher-level System One semantics, evaluation workflows, and local inference
  belong in `system_one_sdk` and the self-hosted runtime packages.
  """

  alias TypeSafeAPISDK.{Choice, Client, Models, Noul, Score, SystemOne}

  @version "0.1.0"

  @spec version() :: String.t()
  def version, do: @version

  @spec new_client(keyword()) :: Client.t()
  defdelegate new_client(opts \\ []), to: Client, as: :new

  @doc "Build a wire-oriented Noul question struct."
  defdelegate noul(attrs \\ []), to: Noul, as: :new

  @doc "Build a wire-oriented Choice question struct."
  defdelegate choice(criteria, opts \\ []), to: Choice, as: :new

  @doc "Build a wire-oriented Score question struct."
  defdelegate score(criteria, opts \\ []), to: Score, as: :new

  @spec system_one(Client.t(), term(), map(), keyword()) ::
          {:ok, TypeSafeAPISDK.SystemOneResponse.t()} | {:error, term()}
  defdelegate system_one(client, state, questions, opts \\ []), to: SystemOne, as: :run

  @doc "Run a System One request and raise a normalized SDK error on failure."
  def system_one!(client, state, questions, opts \\ []),
    do: unwrap!(system_one(client, state, questions, opts))

  @spec list_models(Client.t(), keyword()) ::
          {:ok, TypeSafeAPISDK.ListModelsResponse.t()} | {:error, term()}
  defdelegate list_models(client, opts \\ []), to: Models, as: :list

  @doc "List models and raise a normalized SDK error on failure."
  def list_models!(client, opts \\ []), do: unwrap!(list_models(client, opts))

  defp unwrap!({:ok, value}), do: value
  defp unwrap!({:error, %{__exception__: true} = error}), do: raise(error)
  defp unwrap!({:error, error}), do: raise(RuntimeError, message: inspect(error))
end
