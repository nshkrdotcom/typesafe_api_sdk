defmodule TypeSafeAPISDK.Question do
  @moduledoc "Wire-oriented question normalization for the TypeSafe API."

  alias TypeSafeAPISDK.{Choice, Error, Noul, Score}

  @type t :: Noul.t() | Choice.t() | Score.t() | map()

  @spec normalize_questions(map()) :: {:ok, map()} | {:error, Error.t()}
  def normalize_questions(questions) when is_map(questions) and map_size(questions) > 0 do
    Enum.reduce_while(questions, {:ok, %{}}, fn {name, question}, {:ok, acc} ->
      case normalize_question(name, question) do
        {:ok, normalized} -> {:cont, {:ok, Map.put(acc, to_string(name), normalized)}}
        {:error, error} -> {:halt, {:error, error}}
      end
    end)
  end

  def normalize_questions(_questions),
    do: {:error, Error.configuration("At least one question is required")}

  defp normalize_question(_name, %Noul{} = question) do
    {:ok,
     %{"type" => "noul"}
     |> maybe_put("instructions", question.instructions)
     |> maybe_put("criteria", question.criteria)}
  end

  defp normalize_question(_name, %Choice{} = question) do
    {:ok,
     %{"type" => "choice", "criteria" => question.criteria}
     |> maybe_put("instructions", question.instructions)}
  end

  defp normalize_question(name, %Score{} = question) do
    if is_list(question.criteria) and question.criteria != [] do
      {:ok,
       %{"type" => "score", "criteria" => question.criteria}
       |> maybe_put("instructions", question.instructions)}
    else
      invalid(name, "has no criteria; at least one score is required")
    end
  end

  defp normalize_question(name, question) when is_map(question) and not is_struct(question) do
    question = stringify_top_level_keys(question)

    with :ok <- validate_map_question(name, question) do
      {:ok, question}
    end
  end

  defp normalize_question(name, _question),
    do: invalid(name, "must be a question struct or a map with a nonempty string type")

  defp validate_map_question(name, %{"type" => type} = question) do
    if valid_type?(type) do
      validate_type_criteria(name, type, question)
    else
      invalid(name, "must be a question struct or a map with a nonempty string type")
    end
  end

  defp validate_map_question(name, _question) do
    invalid(name, "must be a question struct or a map with a nonempty string type")
  end

  defp valid_type?(type) when is_binary(type), do: String.trim(type) != ""
  defp valid_type?(_), do: false

  defp validate_type_criteria(name, type, question) when type in ["choice", "score"] do
    case Map.fetch(question, "criteria") do
      :error ->
        invalid(name, "requires criteria")

      {:ok, criteria} when type == "score" and (not is_list(criteria) or criteria == []) ->
        invalid(name, "has no score criteria; at least one score is required")

      _ ->
        :ok
    end
  end

  defp validate_type_criteria(_name, _type, _question), do: :ok

  defp invalid(name, detail),
    do: {:error, Error.configuration("Question #{inspect(to_string(name))} #{detail}")}

  defp stringify_top_level_keys(map),
    do: Map.new(map, fn {key, value} -> {to_string(key), value} end)

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
