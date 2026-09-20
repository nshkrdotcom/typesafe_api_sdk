defmodule TypeSafeAPISDK.NoulAnswer do
  @moduledoc "Typed yes/no probability returned by the TypeSafe System One API."

  @enforce_keys [:noul]
  defstruct [:noul, :id, :raw]

  @type t :: %__MODULE__{
          noul: number(),
          id: String.t() | nil,
          raw: map() | nil
        }
end
