defmodule Mix.Tasks.TypesafeApi.Verify do
  use Mix.Task
  @moduledoc false
  @shortdoc "Verifies committed TypeSafeAPISDK generated artifacts"
  @impl true
  def run(args),
    do: Mix.Task.run("pristine.codegen.verify", ["TypeSafeAPISDK.Codegen.Provider" | args])
end
