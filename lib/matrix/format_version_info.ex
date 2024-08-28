defmodule QRlixer.FormatVersionInfo do
  @moduledoc """
  Handles the generation and placement of format and version information in QR codes.

  This module provides functionality for:
  1. Generating format information based on error correction level and mask pattern.
  2. Generating version information for QR codes version 7 and above.
  3. Adding version information to the QR code matrix.

  The format information encodes the error correction level and mask pattern used in the QR code.
  It is critical for the correct reading of the QR code.

  The version information is only present in QR codes version 7 and above. It encodes the size
  (version) of the QR code and is repeated twice in the QR code for redundancy.

  ## Key Functions

  - `generate_format_information/2`: Generates the format information.
  - `generate_version_information/1`: Generates the version information for versions 7-40.
  - `add_version_information/3`: Adds version information to the QR code matrix.

  ## Usage

  ```
  # Generate format information
  format_info = QRlixer.FormatVersionInfo.generate_format_information(:low, 0)

  # Generate version information
  version_info = QRlixer.FormatVersionInfo.generate_version_information(7)

  # Add version information to matrix
  {updated_matrix, bottom_left_bits} = QRlixer.FormatVersionInfo.add_version_information(matrix, 7, size)
  ```

  Note: This module uses bitwise operations extensively for encoding and manipulating
  the format and version information.
  """
  import Bitwise

  @format_info_poly 0b10100110111
  @format_mask 0b101010000010010

  @version_ec_codewords %{
    7 => 0b000111110010010100,
    8 => 0b001000010110111100,
    9 => 0b001001101010011001,
    10 => 0b001010010011010011,
    11 => 0b001011101111110110,
    12 => 0b001100011101100010,
    13 => 0b001101100001001111,
    14 => 0b001110011000001101,
    15 => 0b001111100100101000,
    16 => 0b010000101101111000,
    17 => 0b010001010001010111,
    18 => 0b010010101000010101,
    19 => 0b010011010100111000,
    20 => 0b010100101001111100,
    21 => 0b010101010101010001,
    22 => 0b010110101100010011,
    23 => 0b010111010000111110,
    24 => 0b011000110000001010,
    25 => 0b011001001100100111,
    26 => 0b011010110101100101,
    27 => 0b011011001001001000,
    28 => 0b011100111011011100,
    29 => 0b011101000111110001,
    30 => 0b011110011011000100,
    31 => 0b011111100111101001,
    32 => 0b100000100011000100,
    33 => 0b100001011111101001,
    34 => 0b100010100110101011,
    35 => 0b100011011010000110,
    36 => 0b100100101000010010,
    37 => 0b100101010100111111,
    38 => 0b100110101101111101,
    39 => 0b100111010001010000,
    40 => 0b101000100001000011
  }

  @error_correction_bits %{
    low: 0b01,
    medium: 0b00,
    quartile: 0b11,
    high: 0b10
  }

  @spec generate_format_information(atom(), integer()) :: integer()
  def generate_format_information(error_correction, mask_pattern) do
    data = bor(bsl(@error_correction_bits[error_correction], 3), mask_pattern)
    encoded_data = bch_encode_format(data)
    bxor(encoded_data, @format_mask)
  end

  @spec generate_version_information(integer()) :: integer()
  def generate_version_information(version) when version >= 7 and version <= 40 do
    Map.fetch!(@version_ec_codewords, version)
  end

  @spec add_version_information([[integer()]], integer(), integer()) ::
          {[[integer()]], [integer()]}
  def add_version_information(matrix, version, size) when version >= 7 and version <= 40 do
    version_info = generate_version_information(version)

    {updated_matrix, _top_right_bits} =
      add_version_info_to_corner(matrix, version_info, size, :top_right)

    {final_matrix, bottom_left_bits} =
      add_version_info_to_corner(updated_matrix, version_info, size, :bottom_left)

    {final_matrix, bottom_left_bits}
  end

  def add_version_information(matrix, _version, _size), do: {matrix, []}

  @spec add_format_information([[integer() | nil]], integer()) :: [[integer() | nil]]
  def add_format_information(matrix, format_info) do
    size = length(matrix)

    # Add format info around the top-left finder pattern
    matrix =
      Enum.reduce(0..14, matrix, fn i, acc ->
        bit = format_info >>> (14 - i) &&& 1

        cond do
          i < 6 -> put_in(acc, [Access.at(i), Access.at(8)], bit)
          i == 6 -> put_in(acc, [Access.at(7), Access.at(8)], bit)
          i == 7 -> put_in(acc, [Access.at(8), Access.at(8)], bit)
          i == 8 -> put_in(acc, [Access.at(8), Access.at(7)], bit)
          true -> put_in(acc, [Access.at(8), Access.at(14 - i)], bit)
        end
      end)

    # Add format info below the top-right finder pattern and to the left of the bottom-left finder pattern
    Enum.reduce(0..14, matrix, fn i, acc ->
      bit = format_info >>> (14 - i) &&& 1

      cond do
        i < 8 -> put_in(acc, [Access.at(8), Access.at(size - 1 - i)], bit)
        true -> put_in(acc, [Access.at(size - 15 + i), Access.at(8)], bit)
      end
    end)
  end

  defp add_version_info_to_corner(matrix, version_info, size, corner) do
    Enum.reduce(0..17, {matrix, []}, fn i, {acc, bits} ->
      bit = version_info >>> (17 - i) &&& 1
      {row, col} = get_coordinates(i, size, corner)
      updated_matrix = put_at(acc, row, col, bit)
      {updated_matrix, [bit | bits]}
    end)
    |> then(fn {matrix, bits} -> {matrix, Enum.reverse(bits)} end)
  end

  defp get_coordinates(i, size, :top_right) do
    {div(i, 3), size - 11 + rem(i, 3)}
  end

  defp get_coordinates(i, size, :bottom_left) do
    {size - 11 + rem(i, 3), div(i, 3)}
  end

  defp bch_encode_format(data) do
    g = @format_info_poly
    d = bsl(data, 10)

    remainder =
      Enum.reduce(14..0, d, fn i, acc ->
        if (acc &&& 1 <<< (i + 10)) != 0 do
          bxor(acc, bsl(g, i))
        else
          acc
        end
      end)

    bor(bsl(data, 10), band(remainder, 0x3FF))
  end

  defp put_at(matrix, row, col, value) do
    List.update_at(matrix, row, fn r -> List.update_at(r, col, fn _ -> value end) end)
  end
end
