defmodule QRlixer.Matrix.TimingPattern do
  @moduledoc """
  Handles the addition of timing patterns to QR code matrices.

  Timing patterns are alternating dark and light modules that help scanners
  determine the position of each data module in the QR code. They are present
  in all versions of QR codes.
  """

  @doc """
  Adds timing patterns to the given QR code matrix.

  ## Parameters

    - matrix: The QR code matrix (2D list)

  ## Returns

    The updated matrix with timing patterns added
  """
  def add(matrix) do
    size = length(matrix)

    matrix
    |> add_horizontal_timing_pattern(6, size)
    |> add_vertical_timing_pattern(6, size)
  end

  defp add_horizontal_timing_pattern(matrix, row, size) do
    List.update_at(matrix, row, fn row_data ->
      Enum.with_index(row_data)
      |> Enum.map(fn
        {_, i} when i >= 8 and i < size - 8 -> rem(i, 2)
        {val, _} -> val
      end)
    end)
  end

  defp add_vertical_timing_pattern(matrix, col, size) do
    Enum.with_index(matrix)
    |> Enum.map(fn
      {row_data, i} when i >= 8 and i < size - 8 ->
        List.update_at(row_data, col, fn _ -> rem(i, 2) end)

      {row_data, _} ->
        row_data
    end)
  end
end
