defmodule QRlixer.Masking do
  @moduledoc """
  Handles the application and evaluation of data masks for QR codes.

  Data masking is used to break up patterns in the QR code that might confuse a scanner,
  such as large blank areas or misleading features. This module applies different mask
  patterns to the QR code matrix and evaluates them to find the optimal mask.
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
        case get_in(matrix, [Access.at(row), Access.at(col)]) do
          nil -> nil
          :reserved -> :reserved
          bit -> bxor(bit, mask_function(pattern, row, col))
        end
      end
    end
  end

  defp mask_function(0, row, col), do: (rem(row + col, 2) == 0 && 1) || 0
  defp mask_function(1, row, _col), do: (rem(row, 2) == 0 && 1) || 0
  defp mask_function(2, _row, col), do: (rem(col, 3) == 0 && 1) || 0
  defp mask_function(3, row, col), do: (rem(row + col, 3) == 0 && 1) || 0
  defp mask_function(4, row, col), do: (rem(div(row, 2) + div(col, 3), 2) == 0 && 1) || 0
  defp mask_function(5, row, col), do: (rem(row * col, 2) + rem(row * col, 3) == 0 && 1) || 0

  defp mask_function(6, row, col),
    do: (rem(rem(row * col, 2) + rem(row * col, 3), 2) == 0 && 1) || 0

  defp mask_function(7, row, col),
    do: (rem(rem(row + col, 2) + rem(row * col, 3), 2) == 0 && 1) || 0

  def evaluate_mask(matrix) do
    score1 = evaluate_consecutive_modules(matrix)
    score2 = evaluate_2x2_blocks(matrix)
    score3 = evaluate_finder_like_patterns(matrix)
    score4 = evaluate_balance(matrix)
    score1 + score2 + score3 + score4
  end

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
          cond do
            i == size - 1 and row[i] == last ->
              {score + penalty(count + 1), {0, nil}}

            row[i] == last ->
              {score, {count + 1, last}}

            true ->
              new_score = score + penalty(count)
              {new_score, {1, row[i]}}
          end
        end)

      score
    end)
  end

  defp penalty(count) when count >= 5, do: count - 2
  defp penalty(_), do: 0

  defp evaluate_2x2_blocks(matrix) do
    size = length(matrix)

    Enum.reduce(0..(size - 2), 0, fn row, score ->
      Enum.reduce(0..(size - 2), score, fn col, score ->
        if matrix[row][col] == matrix[row][col + 1] and
             matrix[row][col] == matrix[row + 1][col] and
             matrix[row][col] == matrix[row + 1][col + 1] do
          score + 3
        else
          score
        end
      end)
    end)
  end

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

  defp evaluate_balance(matrix) do
    dark_count = Enum.sum(for row <- matrix, cell <- row, cell == 1, do: 1)
    total_count = length(matrix) * length(matrix)
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
