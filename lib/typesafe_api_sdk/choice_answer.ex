defmodule TypeSafeAPISDK.ChoiceAnswer do
  @moduledoc "Typed categorical answer returned by the TypeSafe System One API."

  @enforce_keys [:choice, :confidence, :probabilities]
  defstruct [:choice, :confidence, :probabilities, :id, :raw]

  @type t :: %__MODULE__{
          choice: String.t(),
          confidence: number(),
          probabilities: %{String.t() => number()},
          id: String.t() | nil,
          raw: map() | nil
        }
end
