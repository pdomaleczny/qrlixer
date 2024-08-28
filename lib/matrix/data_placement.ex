defmodule QRlixer.DataPlacement do
  @moduledoc """
  Handles the placement of encoded data onto a QR code matrix.

  This module provides functionality to place encoded data bits onto a QR code matrix
  according to the QR code specification. It supports QR code versions 1 through 40
  and handles reserved areas in the matrix.
  """

  def place_data(matrix, encoded_data, version) when version >= 1 and version <= 40 do
    size = length(matrix)
    bits = for <<bit::1 <- encoded_data>>, do: bit
    coordinates = generate_coordinates(size)
    place_bits_helper(matrix, bits, coordinates)
  end

  defp generate_coordinates(size) do
    for col <-
          (size - 1)..0 |> Enum.reverse() |> Enum.chunk_every(2) |> Enum.flat_map(&Enum.reverse/1),
        row <- if(rem(col + 1, 2) == 0, do: (size - 1)..0, else: 0..(size - 1)),
        do: {row, col}
  end

  defp place_bits_helper(matrix, [], _), do: matrix
  defp place_bits_helper(matrix, _, []), do: matrix

  defp place_bits_helper(matrix, [bit | rest], [{row, col} | remaining_coords]) do
    case get_in(matrix, [Access.at(row), Access.at(col)]) do
      nil ->
        new_matrix = put_in(matrix, [Access.at(row), Access.at(col)], bit)
        place_bits_helper(new_matrix, rest, remaining_coords)

      :reserved ->
        place_bits_helper(matrix, [bit | rest], remaining_coords)

      _ ->
        place_bits_helper(matrix, [bit | rest], remaining_coords)
    end
  end
end
