defmodule QRlixer.Matrix do
  @moduledoc """
  Orchestrates the generation of QR code matrices for all 40 versions.

  This module serves as the main entry point for QR code generation. It coordinates
  the various steps involved in creating a QR code, including:

  - Creating the initial empty matrix
  - Adding finder patterns
  - Adding alignment patterns
  - Adding timing patterns
  - Adding the dark module
  - Reserving areas for format and version information
  - Placing the encoded data
  - Applying and selecting the best mask

  It uses specialized modules for each of these tasks, bringing together all the
  components necessary to generate a complete QR code matrix.
  """

  alias QRlixer.AlignmentPatterns
  alias QRlixer.Masking
  alias QRlixer.FormatVersionInfo
  alias QRlixer.FinderPatterns
  alias QRlixer.TimingPatterns
  alias QRlixer.DataPlacement
  alias QRlixer.Utilities

  @doc """
  Generates a QR code matrix from the encoded data.

  ## Parameters

    - encoded_data: The encoded data as a bitstring
    - options: A keyword list of options
      - :version - The QR code version (1-40)
      - :error_correction - The error correction level (:low, :medium, :quartile, :high)

  ## Returns

    A 2D list representing the QR code matrix, where 1 is a black module and 0 is a white module
  """
  @spec generate(bitstring(), keyword()) :: [[0 | 1]]
  def generate(encoded_data, options) do
    version = Keyword.get(options, :version, 1)
    error_correction = Keyword.get(options, :error_correction, :medium)

    size = 4 * version + 17
    matrix = Utilities.create_empty_matrix(size)

    matrix
    |> FinderPatterns.add_finder_patterns()
    |> add_alignment_patterns(version)
    |> TimingPatterns.add_timing_patterns()
    |> add_dark_module(version)
    |> add_reserved_areas(version)
    |> DataPlacement.place_data(encoded_data, version)
    |> apply_best_mask(version, error_correction)
  end

  defp add_alignment_patterns(matrix, version) do
    AlignmentPatterns.get_positions(version)
    |> Utilities.combination(2)
    |> Enum.reduce(matrix, fn [row, col], acc ->
      pattern = [
        [1, 1, 1, 1, 1],
        [1, 0, 0, 0, 1],
        [1, 0, 1, 0, 1],
        [1, 0, 0, 0, 1],
        [1, 1, 1, 1, 1]
      ]

      place_pattern(acc, pattern, row - 2, col - 2)
    end)
  end

  defp add_dark_module(matrix, version) do
    put_in(matrix, [Access.at(4 * version + 9), Access.at(8)], 1)
  end

  defp add_reserved_areas(matrix, version) do
    matrix
    |> reserve_format_areas()
    |> maybe_reserve_version_areas(version)
  end

  defp reserve_format_areas(matrix) do
    size = length(matrix)

    format_areas = [
      Enum.map(0..8, &{8, &1}),
      Enum.map(7..0, &{&1, 8}),
      Enum.map(8..14, &{size - 15 + &1, 8}),
      Enum.map(8..14, &{8, size - &1})
    ]

    Enum.reduce(List.flatten(format_areas), matrix, fn {row, col}, acc ->
      if is_nil(get_in(acc, [Access.at(row), Access.at(col)])) do
        put_in(acc, [Access.at(row), Access.at(col)], :reserved)
      else
        acc
      end
    end)
  end

  defp maybe_reserve_version_areas(matrix, version) when version >= 7 do
    size = length(matrix)

    version_areas =
      for row <- (size - 11)..(size - 9),
          col <- 0..5,
          do:
            {row, col} ++
              for(row <- 0..5, col <- (size - 11)..(size - 9), do: {row, col})

    Enum.reduce(version_areas, matrix, fn {row, col}, acc ->
      put_in(acc, [Access.at(row), Access.at(col)], :reserved)
    end)
  end

  defp maybe_reserve_version_areas(matrix, _version), do: matrix

  defp apply_best_mask(matrix, version, error_correction) do
    {masked_matrix, mask_pattern} = Masking.apply_best_mask(matrix, version, error_correction)
    format_info = FormatVersionInfo.generate_format_information(error_correction, mask_pattern)
    version_info = FormatVersionInfo.generate_version_information(version)

    masked_matrix
    |> FormatVersionInfo.add_format_information(format_info)
    |> FormatVersionInfo.add_version_information(version_info, version)
  end

  defp place_pattern(matrix, pattern, row, col) do
    Enum.reduce(Enum.with_index(pattern), matrix, fn {row_data, r}, acc ->
      Enum.reduce(Enum.with_index(row_data), acc, fn {value, c}, inner_acc ->
        put_in(inner_acc, [Access.at(row + r), Access.at(col + c)], value)
      end)
    end)
  end
end
