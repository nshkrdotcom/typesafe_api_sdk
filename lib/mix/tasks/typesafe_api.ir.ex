defmodule Mix.Tasks.TypesafeApi.Ir do
  use Mix.Task
  @moduledoc false
  @shortdoc "Prints the compiled TypeSafeAPISDK ProviderIR"
  @impl true
  def run(args), do: Mix.Task.run("pristine.codegen.ir", ["TypeSafeAPISDK.Codegen.Provider" | args])
end
