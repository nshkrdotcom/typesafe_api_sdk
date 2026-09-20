defmodule TypeSafeAPISDK.Models do
  @moduledoc "Low-level TypeSafe model-list API resource."

  alias TypeSafeAPISDK.{Client, ListModelsResponse}
  alias TypeSafeAPISDK.Generated.Models, as: GeneratedModels

  @spec list(Client.t(), keyword()) :: {:ok, ListModelsResponse.t()} | {:error, term()}
  def list(%Client{} = client, opts \\ []) when is_list(opts) do
    case GeneratedModels.list(client, %{}, opts) do
      {:ok, body} -> ListModelsResponse.decode(body)
      {:error, error} -> {:error, error}
    end
  end
end
