if bootstrap = System.get_env("MIX_WORKSPACE_OPS_BOOTSTRAP"), do: Code.require_file(bootstrap)

defmodule TypeSafeAPISDK.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/nshkrdotcom/typesafe_api_sdk"

  def project do
    [
      app: :typesafe_api_sdk,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      description: description(),
      package: package(),
      name: "TypeSafeAPISDK",
      source_url: @source_url,
      homepage_url: @source_url,
      docs: docs(),
      aliases: aliases(),
      dialyzer: [
        plt_add_apps:
          [:ex_unit, :mix, :pristine] ++
            if(maintenance?(), do: [:pristine_codegen], else: [])
      ]
    ]
  end

  def application do
    [extra_applications: [:logger, :crypto]]
  end

  defp elixirc_paths(:test) do
    base = ["lib", "test/support"]
    if maintenance?(), do: base ++ ["codegen"], else: base
  end

  defp elixirc_paths(:dev) do
    if maintenance?(), do: ["lib", "codegen"], else: ["lib"]
  end

  defp elixirc_paths(_env), do: ["lib"]

  defp deps do
    [
      workspace_dep({:pristine, "~> 0.4.0"}),
      {:jason, "~> 1.4.5"},
      maintenance_deps(),
      {:ex_doc, "~> 0.40.4", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4.8", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7.19", only: [:dev, :test], runtime: false}
    ]
    |> List.flatten()
  end

  defp maintenance_deps do
    if maintenance?() do
      [workspace_dep({:pristine_codegen, "~> 0.1.0", only: [:dev, :test], runtime: false})]
    else
      []
    end
  end

  defp maintenance?, do: System.get_env("TYPESAFE_API_SDK_MAINTENANCE") == "1"

  defp workspace_dep(committed) do
    if Code.ensure_loaded?(MixWorkspaceOpsBootstrap) and
         function_exported?(MixWorkspaceOpsBootstrap, :dep, 2) do
      apply(MixWorkspaceOpsBootstrap, :dep, [committed, __DIR__])
    else
      committed
    end
  end

  defp description do
    "Minimal Elixir SDK for the TypeSafe System One API, generated from TypeSafe OpenAPI and executed through Pristine."
  end

  defp package do
    [
      name: "typesafe_api_sdk",
      description: description(),
      files:
        ~w(lib priv/upstream priv/generated guides docs examples README.md CHANGELOG.md LICENSE mix.exs assets),
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md"
      },
      maintainers: ["nshkrdotcom"]
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      canonical: "https://hexdocs.pm/typesafe_api_sdk",
      logo: "assets/typesafe_api_sdk.svg",
      assets: %{"assets" => "assets"},
      extras: [
        {"README.md", title: "Overview"},
        {"guides/index.md", title: "Guide Index", filename: "guide-index"},
        {"guides/getting-started.md", title: "Getting Started"},
        {"guides/client-configuration.md", title: "Client Configuration"},
        {"guides/system-one-and-questions.md", title: "System One Wire API"},
        {"guides/models.md", title: "Models API"},
        {"guides/errors-and-retries.md", title: "Errors and Retries"},
        {"guides/runtime-controls.md", title: "Runtime Controls"},
        {"guides/live-verification.md", title: "Live Verification"},
        {"guides/extraction-boundary.md", title: "Extraction Boundary"},
        {"guides/generation-and-verification.md", title: "Generation and Verification"},
        {"docs/implementation/0.1.0/README.md",
         title: "0.1.0 Implementation Architecture", filename: "implementation-0-1-0"},
        "CHANGELOG.md",
        {"LICENSE", title: "License", filename: "license"}
      ],
      groups_for_extras: [
        "Start Here": [
          "README.md",
          "guides/index.md",
          "guides/getting-started.md",
          "guides/client-configuration.md"
        ],
        "Wire API": [
          "guides/system-one-and-questions.md",
          "guides/models.md",
          "guides/errors-and-retries.md",
          "guides/runtime-controls.md",
          "guides/live-verification.md"
        ],
        Architecture: [
          "guides/extraction-boundary.md",
          "guides/generation-and-verification.md",
          "docs/implementation/0.1.0/README.md"
        ],
        Project: [
          "CHANGELOG.md",
          "LICENSE"
        ]
      ],
      groups_for_modules: [
        "Client & Execution": [
          TypeSafeAPISDK,
          TypeSafeAPISDK.Client,
          TypeSafeAPISDK.SystemOne,
          TypeSafeAPISDK.Models
        ],
        "Wire Questions": [
          TypeSafeAPISDK.Question,
          TypeSafeAPISDK.Noul,
          TypeSafeAPISDK.NoulCriteria,
          TypeSafeAPISDK.Choice,
          TypeSafeAPISDK.Score
        ],
        "Wire Responses": [
          TypeSafeAPISDK.SystemOneResponse,
          TypeSafeAPISDK.ListModelsResponse,
          TypeSafeAPISDK.ModelMetadata,
          TypeSafeAPISDK.NoulAnswer,
          TypeSafeAPISDK.ChoiceAnswer,
          TypeSafeAPISDK.ScoreAnswer,
          TypeSafeAPISDK.Usage
        ],
        "Configuration & Errors": [
          TypeSafeAPISDK.Error,
          TypeSafeAPISDK.RetryPolicy,
          TypeSafeAPISDK.Constants,
          TypeSafeAPISDK.RuntimeCapabilities
        ],
        "Transport & Runtime": [
          TypeSafeAPISDK.ProviderProfile,
          TypeSafeAPISDK.ResultClassifier,
          TypeSafeAPISDK.TransportError,
          TypeSafeAPISDK.TransportResponse
        ],
        "Generated API": ~r/^TypeSafeAPISDK\.Generated\./,
        "Maintenance Tasks": ~r/^Mix\.Tasks\.TypesafeApi\./
      ]
    ]
  end

  defp aliases do
    [
      ci: [
        "deps.get",
        "format --check-formatted",
        "compile --warnings-as-errors",
        "test --warnings-as-errors",
        "credo --strict",
        "dialyzer",
        "docs --warnings-as-errors"
      ]
    ]
  end
end
