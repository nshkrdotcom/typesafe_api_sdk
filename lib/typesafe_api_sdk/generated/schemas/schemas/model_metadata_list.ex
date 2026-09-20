defmodule TypeSafeAPISDK.Generated.Schemas.ModelMetadataList do
  @moduledoc """
  Generated Typesafe API Sdk type module `TypeSafeAPISDK.Generated.Schemas.ModelMetadataList`.
  """

  alias TypeSafeAPISDK.Generated.RuntimeSchema, as: RuntimeSchema

  @enforce_keys [:models]
  defstruct [:models]

  @type t :: %__MODULE__{
          models: [TypeSafeAPISDK.Generated.Schemas.ModelMetadata.t()]
        }
  @doc false
  @spec __fields__(atom()) :: keyword()
  def __fields__(type \\ :t)

  def __fields__(:t) do
    [
      models: {:array, {TypeSafeAPISDK.Generated.Schemas.ModelMetadata, :t}}
    ]
  end

  @doc false
  @spec __openapi_fields__(atom()) :: [map()]
  def __openapi_fields__(type \\ :t)

  def __openapi_fields__(:t) do
    [
      %{
        description:
          "Available models and aliases. Use a model's name in POST /v1/systemone requests.",
        name: "models",
        nullable: false,
        required: true,
        type: {:array, {TypeSafeAPISDK.Generated.Schemas.ModelMetadata, :t}}
      }
    ]
  end

  @doc false
  @spec __schema__(atom()) :: Sinter.Schema.t()
  def __schema__(type \\ :t) when is_atom(type) do
    RuntimeSchema.build_schema(__openapi_fields__(type))
  end

  @doc false
  @spec decode(map(), atom()) :: {:ok, term()} | {:error, term()}
  def decode(data, type \\ :t)

  def decode(data, type) when is_map(data) and is_atom(type) do
    RuntimeSchema.decode_module_type(__MODULE__, type, data)
  end
end
