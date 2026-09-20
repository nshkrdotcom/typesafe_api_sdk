defmodule TypeSafeAPISDK.ScoreAnswer do
  @moduledoc "Typed ordinal score answer returned by the TypeSafe System One API."

  @enforce_keys [:score, :confidence, :legend, :probabilities]
  defstruct [:score, :confidence, :legend, :probabilities, :id, :raw]

  @type t :: %__MODULE__{
          score: number(),
          confidence: number(),
          legend: %{integer() => term()},
          probabilities: %{integer() => number()},
          id: String.t() | nil,
          raw: map() | nil
        }
end
