defmodule QRlixer.Matrix.FinderPattern do
  @moduledoc """
  Handles the addition of finder patterns to QR code matrices.

  Finder patterns are special markers placed in three corners of the QR code
  (top-left, top-right, and bottom-left) to help scanners locate and orient the code.
  """

  @finder_pattern [
    [1, 1, 1, 1, 1, 1, 1],
    [1, 0, 0, 0, 0, 0, 1],
    [1, 0, 1, 1, 1, 0, 1],
    [1, 0, 1, 1, 1, 0, 1],
    [1, 0, 1, 1, 1, 0, 1],
    [1, 0, 0, 0, 0, 0, 1],
    [1, 1, 1, 1, 1, 1, 1]
  ]

  @doc """
  Adds finder patterns to the given QR code matrix.

  ## Parameters

    - matrix: The initial QR code matrix (2D list)
    - version: The QR code version (1-40)

  ## Returns

    The updated matrix with finder patterns added
  """
  def add(matrix, version) do
    size = 4 * version + 17

    matrix
    |> add_finder_pattern(0, 0)                 # Top-left
    |> add_finder_pattern(size - 7, 0)          # Top-right
    |> add_finder_pattern(0, size - 7)          # Bottom-left
    |> add_separators(size)
  end

  defp add_finder_pattern(matrix, row, col) do
    Enum.reduce(0..6, matrix, fn r, acc ->
      List.update_at(acc, row + r, fn row_data ->
        Enum.with_index(row_data)
        |> Enum.map(fn
          {_, i} when i >= col and i < col + 7 -> Enum.at(@finder_pattern, r) |> Enum.at(i - col)
          {val, _} -> val
        end)
      end)
    end)
  end

  defp add_separators(matrix, size) do
    matrix
    |> add_horizontal_separator(7, 0)            # Top-left
    |> add_horizontal_separator(size - 8, 0)     # Top-right
    |> add_horizontal_separator(7, size - 8)     # Bottom-left
    |> add_vertical_separator(0, 7)              # Top-left
    |> add_vertical_separator(size - 8, 7)       # Top-right
    |> add_vertical_separator(0, size - 8)       # Bottom-left
  end

  defp add_horizontal_separator(matrix, row, col) do
    List.update_at(matrix, row, fn row_data ->
      Enum.with_index(row_data)
      |> Enum.map(fn
        {_, i} when i >= col and i < col + 8 -> 0
        {val, _} -> val
      end)
    end)
  end

  defp add_vertical_separator(matrix, row, col) do
    Enum.with_index(matrix)
    |> Enum.map(fn
      {row_data, i} when i >= row and i < row + 8 ->
        List.update_at(row_data, col, fn _ -> 0 end)
      {row_data, _} -> row_data
    end)
  end
end
