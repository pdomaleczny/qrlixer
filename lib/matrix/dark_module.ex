defmodule QRlixer.Matrix.DarkModule do
  @moduledoc """
  Handles the addition of the dark module to QR code matrices.

  The dark module is a single module that's always dark (1) and helps with alignment.
  It's present in all QR code versions except version 1.
  """

  @doc """
  Adds the dark module to the given QR code matrix based on its version.

  ## Parameters

    - matrix: The QR code matrix (2D list)
    - version: The QR code version (1-40)

  ## Returns

    The updated matrix with the dark module added
  """
  def add(matrix, version) when version in 1..40 do
    if version == 1 do
      # Version 1 doesn't have a dark module
      matrix
    else
      size = length(matrix)
      row = 4 * version + 9
      col = 8

      List.update_at(matrix, row, fn row_data ->
        List.replace_at(row_data, col, 1)
      end)
    end
  end
end
