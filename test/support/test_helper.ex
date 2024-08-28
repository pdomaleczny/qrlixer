defmodule QRlixer.TestHelper do
  alias QRlixer.AlignmentPatterns
  alias QRlixer.FinderPatterns
  alias QRlixer.TimingPatterns
  alias QRlixer.FormatVersionInfo
  alias QRlixer.Utilities
  alias QRlixer.DataPlacement

  def generate_expected_matrix(version, encoded_data) do
    base_matrix = generate_base_matrix(version)
    DataPlacement.place_data(base_matrix, encoded_data, version)
  end

  def generate_base_matrix(version) do
    size = 4 * version + 17
    matrix = Utilities.create_empty_matrix(size)

    matrix
    |> FinderPatterns.add_finder_patterns()
    |> add_alignment_patterns(version)
    |> TimingPatterns.add_timing_patterns()
    |> add_dark_module(version)
    |> add_reserved_areas(version)
  end

  defp add_alignment_patterns(matrix, version) do
    positions = AlignmentPatterns.get_positions(version)
    size = length(matrix)

    Enum.reduce(positions, matrix, fn row, acc ->
      Enum.reduce(positions, acc, fn col, inner_acc ->
        if !conflict_with_finder_pattern?(row, col, size) do
          place_alignment_pattern(inner_acc, row, col)
        else
          inner_acc
        end
      end)
    end)
  end

  defp conflict_with_finder_pattern?(row, col, size) do
    (row < 8 and col < 8) or
      (row < 8 and col > size - 9) or
      (row > size - 9 and col < 8)
  end

  defp place_alignment_pattern(matrix, center_row, center_col) do
    pattern = [
      [1, 1, 1, 1, 1],
      [1, 0, 0, 0, 1],
      [1, 0, 1, 0, 1],
      [1, 0, 0, 0, 1],
      [1, 1, 1, 1, 1]
    ]

    Enum.reduce(-2..2, matrix, fn row_offset, acc ->
      Enum.reduce(-2..2, acc, fn col_offset, inner_acc ->
        row = center_row + row_offset
        col = center_col + col_offset
        value = Enum.at(Enum.at(pattern, row_offset + 2), col_offset + 2)
        List.update_at(inner_acc, row, fn r -> List.replace_at(r, col, value) end)
      end)
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
      Enum.map(7..0//-1, &{&1, 8}),
      Enum.map(8..14, &{size - 15 + &1, 8}),
      Enum.map(8..14, &{8, size - &1})
    ]

    Enum.reduce(List.flatten(format_areas), matrix, fn {row, col}, acc ->
      if is_nil(Enum.at(Enum.at(acc, row), col)) do
        List.update_at(acc, row, fn r -> List.update_at(r, col, fn _ -> :reserved end) end)
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
          do: {row, col}

    version_areas =
      version_areas ++ for row <- 0..5, col <- (size - 11)..(size - 9), do: {row, col}

    Enum.reduce(version_areas, matrix, fn {row, col}, acc ->
      put_in(acc, [Access.at(row), Access.at(col)], :reserved)
    end)
  end

  defp maybe_reserve_version_areas(matrix, _version), do: matrix

  def apply_mask(matrix, mask_pattern) do
    QRlixer.Masking.mask(matrix, mask_pattern)
  end

  # Removed the add_format_information/2 function as it was causing a warning

  def add_version_information(matrix, version, size) do
    FormatVersionInfo.add_version_information(matrix, version, size)
  end

  # Removed the debug_matrix/2 function as it was causing a warning
end
