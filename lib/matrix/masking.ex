defmodule QRlixer.Masking do
  @moduledoc """
  Handles the application and evaluation of data masks for QR codes.

  This module provides functionality to:
  - Apply different mask patterns to a QR code matrix
  - Evaluate the effectiveness of each mask pattern
  - Select the optimal mask pattern for a given QR code

  Data masking is used to break up patterns in the QR code that might confuse a scanner,
  such as large blank areas or misleading features. The module applies eight different
  mask patterns and evaluates them based on four penalty rules to find the optimal mask.

  Main functions:
  - `apply_best_mask/3`: Applies all mask patterns and selects the best one
  - `mask/2`: Applies a specific mask pattern to a matrix
  - `evaluate_mask/1`: Calculates the penalty score for a given masked matrix

  The evaluation is based on four penalty rules:
  1. Adjacent modules in row/column in same color
  2. Block of modules in same color
  3. Patterns that look similar to the finder pattern
  4. Balance of dark and light modules
  """

  import Bitwise, only: [bxor: 2]

  def apply_best_mask(matrix, _version, _error_correction) do
    masks = for i <- 0..7, do: mask(matrix, i)

    {best_matrix, best_pattern} =
      Enum.min_by(Enum.zip(masks, 0..7), fn {matrix, _} -> evaluate_mask(matrix) end)

    {best_matrix, best_pattern}
  end

  def mask(matrix, pattern) do
    size = length(matrix)

    for row <- 0..(size - 1) do
      for col <- 0..(size - 1) do
        case Enum.at(matrix, row) |> Enum.at(col) do
          nil ->
            nil

          :reserved ->
            :reserved

          bit when is_integer(bit) ->
            mask_bit = mask_function(pattern, row, col)
            bxor(bit, mask_bit)

          _ ->
            raise "Invalid matrix value at position (#{row}, #{col})"
        end
      end
    end
  end

  def mask_function(0, row, col), do: if(rem(row + col, 2) == 0, do: 1, else: 0)
  def mask_function(1, row, _col), do: if(rem(row, 2) == 0, do: 1, else: 0)
  def mask_function(2, _row, col), do: if(rem(col, 3) == 0, do: 1, else: 0)
  def mask_function(3, row, col), do: if(rem(row + col, 3) == 0, do: 1, else: 0)
  def mask_function(4, row, col), do: if(rem(div(row, 2) + div(col, 3), 2) == 0, do: 1, else: 0)

  def mask_function(5, row, col),
    do: if(rem(row * col, 2) + rem(row * col, 3) == 0, do: 1, else: 0)

  def mask_function(6, row, col),
    do: if(rem(rem(row * col, 2) + rem(row * col, 3), 2) == 0, do: 1, else: 0)

  def mask_function(7, row, col),
    do: if(rem(rem(row + col, 2) + rem(row * col, 3), 2) == 0, do: 1, else: 0)

  def evaluate_mask([]), do: 0
  def evaluate_mask([row]) when length(row) < 2, do: 0

  def evaluate_mask(matrix) do
    evaluate_consecutive_modules(matrix) +
      evaluate_2x2_blocks(matrix) +
      evaluate_finder_like_patterns(matrix) +
      evaluate_balance(matrix)
  end

  defp evaluate_consecutive_modules(matrix) when length(matrix) < 2, do: 0

  defp evaluate_consecutive_modules(matrix) do
    size = length(matrix)
    row_score = evaluate_consecutive_in_lines(matrix, size)
    col_score = evaluate_consecutive_in_lines(transpose(matrix), size)
    row_score + col_score
  end

  defp evaluate_consecutive_in_lines(matrix, size) do
    Enum.reduce(matrix, 0, fn row, score ->
      {score, _} =
        Enum.reduce(0..(size - 1), {score, {0, nil}}, fn i, {score, {count, last}} ->
          current = Enum.at(row, i)

          cond do
            i == size - 1 and current == last ->
              {score + penalty(count + 1), {0, nil}}

            current == last ->
              {score, {count + 1, last}}

            true ->
              new_score = score + penalty(count)
              {new_score, {1, current}}
          end
        end)

      score
    end)
  end

  defp penalty(count) when count >= 5, do: count - 2
  defp penalty(_), do: 0

  defp evaluate_2x2_blocks(matrix) when length(matrix) < 2, do: 0

  defp evaluate_2x2_blocks(matrix) do
    size = length(matrix)

    Enum.reduce(0..(size - 2), 0, fn row, score ->
      Enum.reduce(0..(size - 2), score, fn col, score ->
        if Enum.at(Enum.at(matrix, row), col) == Enum.at(Enum.at(matrix, row), col + 1) and
             Enum.at(Enum.at(matrix, row), col) == Enum.at(Enum.at(matrix, row + 1), col) and
             Enum.at(Enum.at(matrix, row), col) == Enum.at(Enum.at(matrix, row + 1), col + 1) do
          score + 3
        else
          score
        end
      end)
    end)
  end

  defp evaluate_finder_like_patterns(matrix) when length(matrix) < 7, do: 0

  defp evaluate_finder_like_patterns(matrix) do
    pattern1 = [1, 0, 1, 1, 1, 0, 1]
    pattern2 = Enum.reverse(pattern1)
    horizontal_score = find_pattern_occurrences(matrix, pattern1, pattern2)
    vertical_score = find_pattern_occurrences(transpose(matrix), pattern1, pattern2)
    (horizontal_score + vertical_score) * 40
  end

  defp find_pattern_occurrences(matrix, pattern1, pattern2) do
    Enum.reduce(matrix, 0, fn row, score ->
      score + count_pattern(row, pattern1) + count_pattern(row, pattern2)
    end)
  end

  defp count_pattern(row, pattern) do
    row
    |> Enum.chunk_every(7, 1, :discard)
    |> Enum.count(&(&1 == pattern))
  end

  defp evaluate_balance(matrix) when length(matrix) < 2, do: 0

  defp evaluate_balance(matrix) do
    dark_count = Enum.sum(for row <- matrix, cell <- row, is_integer(cell) and cell == 1, do: 1)
    total_count = length(matrix) * length(hd(matrix))
    percentage = dark_count / total_count * 100
    base = trunc(abs(percentage - 50) / 5)
    base * 10
  end

  defp transpose(matrix) do
    matrix
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end
end
