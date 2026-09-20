defmodule Mix.Tasks.TypesafeApi.Generate do
  use Mix.Task
  @moduledoc false
  @shortdoc "Generates committed TypeSafeAPISDK artifacts from the OpenAPI snapshot"
  @impl true
  def run(args),
    do: Mix.Task.run("pristine.codegen.generate", ["TypeSafeAPISDK.Codegen.Provider" | args])
end
