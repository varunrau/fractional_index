defmodule FractionalIndex do
  alias FractionalIndex.Errors
  alias FractionalIndex.Constants

  @moduledoc """
  Documentation for `FractionalIndex`.
  """

  @spec midpoint(String.t(), String.t() | nil) ::
          {:ok, String.t()} | {:error, {Errors.midpointError(), String.t()}}
  def midpoint(a, b) do
    cond do
      !is_nil(b) && a >= b ->
        {:error, {:wrong_order, "#{a} >= #{b}"}}

      !is_nil(b) && String.last(b) == "0" && String.last(a) == "0" ->
        {:error, {:trailing_zero, ""}}

      !is_nil(b) ->
        common_prefix_size = find_common_prefix_size(a, b)

        if common_prefix_size > 0 do
          {:ok, midpoint_result} =
            midpoint_of_distinct_strings(
              String.slice(a, common_prefix_size..String.length(a)),
              String.slice(b, common_prefix_size..String.length(b))
            )

          {:ok, "#{String.slice(b, 0..(common_prefix_size - 1))}#{midpoint_result}"}
        else
          midpoint_of_distinct_strings(a, b)
        end

      true ->
        midpoint_of_distinct_strings(a, b)
    end
  end

  @spec midpoint_of_distinct_strings(String.t(), String.t() | nil) ::
          {:ok, String.t()}
  defp midpoint_of_distinct_strings(a, b) do
    digitA =
      if a == "",
        do: 0,
        else:
          Enum.find_index(String.graphemes(Constants.digits()), fn c ->
            c == String.first(a)
          end)

    digitB =
      if !is_nil(b),
        do:
          Enum.find_index(String.graphemes(Constants.digits()), fn c ->
            c == String.first(b)
          end),
        else: String.length(Constants.digits())

    if digitB - digitA > 1 do
      mid = round(0.5 * (digitA + digitB))
      {:ok, String.at(Constants.digits(), mid)}
    else
      if !is_nil(b) && String.length(b) > 1 do
        {:ok, String.first(b)}
      else
        {:ok, midpoint_result} =
          FractionalIndex.midpoint(String.slice(a, 1..String.length(a)), nil)

        {:ok, "#{String.at(Constants.digits(), digitA)}#{midpoint_result}"}
      end
    end
  end

  def find_common_prefix_size(a, b) do
    find_common_prefix_size(a, b, 0)
  end

  @spec find_common_prefix_size(String.t(), String.t() | nil, integer()) :: integer()
  def find_common_prefix_size(a, b, n) do
    if (String.at(a, n) || "0") == String.at(b, n) do
      find_common_prefix_size(a, b, n + 1)
    else
      n
    end
  end

  @spec validate_integer(String.t()) :: :ok | {:error, Errors.keyError()}
  def validate_integer(intStr) do
    case get_integer_length(String.first(intStr)) do
      {:ok, length} ->
        if length == String.length(intStr) do
          :ok
        else
          {:error, :invalid_order_key_head}
        end

      error ->
        error
    end
  end

  @spec get_integer_length(String.t()) ::
          {:ok, integer()} | {:error, Errors.keyError()}
  def get_integer_length(head) do
    cond do
      head >= "a" && head <= "z" ->
        {:ok, ascii_code(head) - ascii_code("a") + 2}

      head >= "A" && head <= "Z" ->
        {:ok, ascii_code("Z") - ascii_code(head) + 2}

      true ->
        {:error, :invalid_order_key_head}
    end
  end

  @spec get_integer_part(String.t()) :: {:ok, String.t()} | {:error, Errors.keyError()}
  def get_integer_part(key) do
    case get_integer_length(String.first(key)) do
      {:ok, length} ->
        if length > String.length(key) do
          {:error, :invalid_order_key_head}
        else
          {:ok, String.slice(key, 0..(length - 1))}
        end

      error ->
        error
    end
  end

  @spec validate_order_key(String.t()) :: :ok | Errors.keyError()
  # smallest integer
  def validate_order_key("A00000000000000000000000000"), do: :invalid_key

  def validate_order_key(key) do
    with {:ok, i} <- get_integer_part(key) do
      f = String.slice(key, String.length(i)..String.length(key))

      case String.last(f) do
        "0" -> :invalid_key
        _ -> :ok
      end
    end
  end

  @spec increment_integer(String.t()) :: String.t() | nil
  def increment_integer(x) do
    :ok = validate_integer(x)
    head = String.first(x)
    tail = String.slice(x, 1..String.length(x))

    {carry, digs} = increment_with_carry(String.length(tail) - 1, tail, true)

    if carry do
      h = to_string([ascii_code(head) + 1])

      cond do
        head == "Z" ->
          "a0"

        head == "z" ->
          nil

        h > "a" ->
          "#{h}#{digs}0"

        true ->
          "#{h}#{String.slice(digs, 0..(String.length(digs) - 1))}"
      end
    else
      "#{head}#{digs}"
    end
  end

  def increment_with_carry(i, tail, carry) do
    if i >= 0 && carry do
      d =
        Enum.find_index(String.graphemes(Constants.digits()), fn c ->
          c == String.at(tail, i)
        end) + 1

      if d == String.length(Constants.digits()) do
        increment_with_carry(i - 1, replace_char_at(tail, i, "0"), carry)
      else
        increment_with_carry(
          i - 1,
          replace_char_at(tail, i, String.at(Constants.digits(), d)),
          false
        )
      end
    else
      {carry, tail}
    end
  end

  @spec decrement_integer(String.t()) :: String.t() | nil
  def decrement_integer(x) do
    :ok = validate_integer(x)
    head = String.first(x)
    tail = String.slice(x, 1..String.length(x))
    {borrow, digs} = decrement_with_borrow(String.length(tail) - 1, tail, true)

    if borrow do
      h = to_string([ascii_code(head) - 1])

      cond do
        head == "a" ->
          "Z#{String.last(Constants.digits())}"

        head == "A" ->
          nil

        h < "Z" ->
          "#{h}#{digs}#{String.last(Constants.digits())}"

        true ->
          "#{h}#{String.slice(digs, 0..(String.length(digs) - 2))}"
      end
    else
      "#{head}#{digs}"
    end
  end

  def decrement_with_borrow(i, tail, borrow) do
    if i >= 0 && borrow do
      d =
        Enum.find_index(String.graphemes(Constants.digits()), fn c ->
          c == String.at(tail, i)
        end) - 1

      if d == -1 do
        decrement_with_borrow(
          i - 1,
          replace_char_at(tail, i, String.last(Constants.digits())),
          borrow
        )
      else
        decrement_with_borrow(
          i - 1,
          replace_char_at(tail, i, String.at(Constants.digits(), d)),
          false
        )
      end
    else
      {borrow, tail}
    end
  end

  @spec generate_key_between(String.t() | nil, String.t() | nil) ::
          {:ok, String.t()} | {:error, Errors.error()}
  def generate_key_between(a, b) do
    cond do
      !validate_input(a) ->
        {:error, :invalid_order_key}

      !validate_input(b) ->
        {:error, :invalid_order_key}

      !is_nil(a) && !is_nil(b) && a >= b ->
        {:error, :wrong_order}

      true ->
        generate_key_between_validated(a, b)
    end
  end

  @spec generate_key_between_validated(String.t() | nil, String.t() | nil) ::
          {:ok, String.t()} | {:error, Errors.error()}
  def generate_key_between_validated(a, b) do
    cond do
      is_nil(a) ->
        cond do
          is_nil(b) ->
            {:ok, Constants.zero()}

          true ->
            {:ok, ib} = get_integer_part(b)
            fb = String.slice(b, String.length(ib)..String.length(b))

            cond do
              ib == Constants.smallest_integer() ->
                {:ok, midpoint_result} = midpoint("", fb)
                {:ok, "#{ib}#{midpoint_result}"}

              ib < b ->
                {:ok, ib}

              true ->
                case decrement_integer(ib) do
                  nil -> {:error, :smallest_integer}
                  res -> {:ok, res}
                end
            end
        end

      is_nil(b) ->
        {:ok, ia} = get_integer_part(a)
        fa = String.slice(a, String.length(ia)..String.length(a))

        case increment_integer(ia) do
          nil ->
            {:ok, midpoint_result} = midpoint(fa, nil)
            {:ok, "#{ia}#{midpoint_result}"}

          i ->
            {:ok, i}
        end

      true ->
        {:ok, ia} = get_integer_part(a)
        fa = String.slice(a, String.length(ia)..String.length(a))
        {:ok, ib} = get_integer_part(b)
        fb = String.slice(b, String.length(ib)..String.length(b))

        if ia == ib do
          {:ok, midpoint_result} = midpoint(fa, fb)
          {:ok, "#{ia}#{midpoint_result}"}
        else
          case increment_integer(ia) do
            nil ->
              {:error, :largest_integer}

            i ->
              if i < b do
                {:ok, i}
              else
                {:ok, result} = midpoint(fa, nil)
                {:ok, "#{ia}#{result}"}
              end
          end
        end
    end
  end

  def validate_input(i) do
    case is_nil(i) do
      true -> true
      false -> :ok == validate_order_key(i)
    end
  end

  defp replace_char_at(str, i, char) do
    list = String.graphemes(str)

    Enum.with_index(list)
    |> Enum.map(fn {g, idx} -> if idx == i, do: char, else: g end)
    |> to_string()
  end

  def ascii_code(str) do
    str |> String.to_charlist() |> hd
  end
end
