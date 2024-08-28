defmodule QRlixer.TimingPatterns do
  @moduledoc """
  Handles the generation and placement of timing patterns in QR code matrices.

  Timing patterns are horizontal and vertical lines of alternating dark and light modules
  that run between the finder patterns. They help the decoder software determine the
  width of a single module.
  """
  def add_timing_patterns(matrix) do
    size = length(matrix)
    horizontal = for col <- 8..(size - 8), do: {6, col}
    vertical = for row <- 8..(size - 8), do: {row, 6}

    Enum.reduce(horizontal ++ vertical, matrix, fn {row, col}, acc ->
      value = if rem(row + col, 2) == 0, do: 1, else: 0
      put_in(acc, [Access.at(row), Access.at(col)], value)
    end)
  end
end
