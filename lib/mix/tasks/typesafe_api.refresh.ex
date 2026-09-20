defmodule Mix.Tasks.TypesafeApi.Refresh do
  use Mix.Task
  @moduledoc false
  @shortdoc "Fetches the upstream OpenAPI document and regenerates TypeSafeAPISDK"
  @impl true
  def run(args),
    do: Mix.Task.run("pristine.codegen.refresh", ["TypeSafeAPISDK.Codegen.Provider" | args])
end
