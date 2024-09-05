defmodule QRlixer.Matrix.AlignmentPattern do
  @moduledoc """
  Handles the addition of alignment patterns to QR code matrices.

  Alignment patterns are additional position detection patterns placed in larger QR codes
  (version 2 and above) to help scanners with orientation and distortion correction.
  """

  @doc """
  Adds alignment patterns to the given QR code matrix based on its version.

  ## Parameters

    - matrix: The QR code matrix (2D list)
    - version: The QR code version (1-40)

  ## Returns

    The updated matrix with alignment patterns added
  """
  def add(matrix, version) when version in 1..40 do
    if version == 1 do
      # Version 1 doesn't have alignment patterns
      matrix
    else
      positions = alignment_pattern_positions(version)
      add_patterns(matrix, positions)
    end
  end

  defp add_patterns(matrix, positions) do
    size = length(matrix)

    for center_x <- positions, center_y <- positions, reduce: matrix do
      acc ->
        # Skip if the position conflicts with finder patterns
        if conflicting_with_finder_pattern?(center_x, center_y, size) do
          acc
        else
          add_single_pattern(acc, center_x, center_y)
        end
    end
  end

  defp add_single_pattern(matrix, center_x, center_y) do
    pattern = [
      [1, 1, 1, 1, 1],
      [1, 0, 0, 0, 1],
      [1, 0, 1, 0, 1],
      [1, 0, 0, 0, 1],
      [1, 1, 1, 1, 1]
    ]

    Enum.reduce(-2..2, matrix, fn y_offset, acc ->
      List.update_at(acc, center_y + y_offset, fn row ->
        Enum.reduce(-2..2, row, fn x_offset, row_acc ->
          List.replace_at(
            row_acc,
            center_x + x_offset,
            Enum.at(Enum.at(pattern, y_offset + 2), x_offset + 2)
          )
        end)
      end)
    end)
  end

  defp conflicting_with_finder_pattern?(x, y, size) do
    (x < 8 and y < 8) or (x > size - 9 and y < 8) or (x < 8 and y > size - 9)
  end

  defp alignment_pattern_positions(version) do
    table = [
      nil,
      [],
      [6, 18],
      [6, 22],
      [6, 26],
      [6, 30],
      [6, 34],
      [6, 22, 38],
      [6, 24, 42],
      [6, 26, 46],
      [6, 28, 50],
      [6, 30, 54],
      [6, 32, 58],
      [6, 34, 62],
      [6, 26, 46, 66],
      [6, 26, 48, 70],
      [6, 26, 50, 74],
      [6, 30, 54, 78],
      [6, 30, 56, 82],
      [6, 30, 58, 86],
      [6, 34, 62, 90],
      [6, 28, 50, 72, 94],
      [6, 26, 50, 74, 98],
      [6, 30, 54, 78, 102],
      [6, 28, 54, 80, 106],
      [6, 32, 58, 84, 110],
      [6, 30, 58, 86, 114],
      [6, 34, 62, 90, 118],
      [6, 26, 50, 74, 98, 122],
      [6, 30, 54, 78, 102, 126],
      [6, 26, 52, 78, 104, 130],
      [6, 30, 56, 82, 108, 134],
      [6, 34, 60, 86, 112, 138],
      [6, 30, 58, 86, 114, 142],
      [6, 34, 62, 90, 118, 146],
      [6, 30, 54, 78, 102, 126, 150],
      [6, 24, 50, 76, 102, 128, 154],
      [6, 28, 54, 80, 106, 132, 158],
      [6, 32, 58, 84, 110, 136, 162],
      [6, 26, 54, 82, 110, 138, 166],
      [6, 30, 58, 86, 114, 142, 170]
    ]

    Enum.at(table, version)
  end
end
