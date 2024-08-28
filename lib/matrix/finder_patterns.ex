defmodule QRlixer.FinderPatterns do
  @moduledoc """
  Handles the generation and placement of finder patterns in QR code matrices.

  Finder patterns are the three identical structures located in the upper-left,
  upper-right, and lower-left corners of the QR code. They are used by readers
  to recognize the QR code and determine its orientation.

  This module also handles the addition of separator lines around the finder patterns.
  """

  def add_finder_patterns(matrix) do
    finder_pattern = [
      [1, 1, 1, 1, 1, 1, 1],
      [1, 0, 0, 0, 0, 0, 1],
      [1, 0, 1, 1, 1, 0, 1],
      [1, 0, 1, 1, 1, 0, 1],
      [1, 0, 1, 1, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 1],
      [1, 1, 1, 1, 1, 1, 1]
    ]

    size = length(matrix)

    matrix
    |> place_pattern(finder_pattern, 0, 0)
    |> place_pattern(finder_pattern, 0, size - 7)
    |> place_pattern(finder_pattern, size - 7, 0)
    |> add_separators()
  end

  defp add_separators(matrix) do
    size = length(matrix)
    separator_indices = for i <- 0..7, do: i

    separator_coords = [
      Enum.map(separator_indices, &{&1, 7}),
      Enum.map(separator_indices, &{7, &1}),
      Enum.map(separator_indices, &{&1, size - 8}),
      Enum.map(separator_indices, &{size - 8, &1}),
      Enum.map(separator_indices, &{size - &1 - 1, 7}),
      Enum.map(separator_indices, &{7, size - &1 - 1})
    ]

    Enum.reduce(List.flatten(separator_coords), matrix, fn {row, col}, acc ->
      put_in(acc, [Access.at(row), Access.at(col)], 0)
    end)
  end

  defp place_pattern(matrix, pattern, row, col) do
    Enum.reduce(Enum.with_index(pattern), matrix, fn {row_data, r}, acc ->
      Enum.reduce(Enum.with_index(row_data), acc, fn {value, c}, inner_acc ->
        put_in(inner_acc, [Access.at(row + r), Access.at(col + c)], value)
      end)
    end)
  end
end
