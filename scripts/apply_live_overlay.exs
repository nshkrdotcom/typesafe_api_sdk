path = "mix.exs"
source = File.read!(path)

extras_entry = ~s({"guides/live-verification.md", title: "Live Verification"})
extras_anchor = ~s(        {"guides/runtime-controls.md", title: "Runtime Controls"},)

group_entry = ~s(          "guides/live-verification.md")
group_anchor = ~s(          "guides/runtime-controls.md")

source =
  if String.contains?(source, extras_entry) do
    source
  else
    unless String.contains?(source, extras_anchor) do
      raise "could not find Runtime Controls ExDoc extras anchor in mix.exs"
    end

    String.replace(
      source,
      extras_anchor,
      extras_anchor <> "\n        " <> extras_entry <> ",",
      global: false
    )
  end

source =
  if String.contains?(source, group_entry) do
    source
  else
    unless String.contains?(source, group_anchor) do
      raise "could not find Runtime Controls API-group anchor in mix.exs"
    end

    String.replace(
      source,
      group_anchor,
      group_anchor <> ",\n" <> group_entry,
      global: false
    )
  end

File.write!(path, source)
