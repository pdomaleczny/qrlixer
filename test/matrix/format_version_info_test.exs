defmodule QRlixer.FormatVersionInfoTest do
  use ExUnit.Case
  import Bitwise
  alias QRlixer.FormatVersionInfo
  alias QRlixer.TestHelper

  describe "generate_format_information/2" do
    test "generates correct format information for various error correction levels and mask patterns" do
      assert FormatVersionInfo.generate_format_information(:low, 0) == 30660
      assert FormatVersionInfo.generate_format_information(:medium, 3) == 23371
      assert FormatVersionInfo.generate_format_information(:quartile, 5) == 8579
      assert FormatVersionInfo.generate_format_information(:high, 7) == 2107
    end

    test "generates different format information for different error correction levels and mask patterns" do
      results =
        for ec <- [:low, :medium, :quartile, :high], mask <- 0..7 do
          FormatVersionInfo.generate_format_information(ec, mask)
        end

      assert Enum.uniq(results) == results
    end

    test "returns a 15-bit integer" do
      result = FormatVersionInfo.generate_format_information(:low, 0)
      assert is_integer(result) and result >= 0 and result < 1 <<< 15
    end
  end

  describe "generate_version_information/1" do
    test "produces correct values for various versions" do
      expected_values = %{
        7 => 0b000111110010010100,
        8 => 0b001000010110111100,
        20 => 0b010100101001111100,
        30 => 0b011110011011000100,
        40 => 0b101000100001000011
      }

      for {version, expected} <- expected_values do
        assert FormatVersionInfo.generate_version_information(version) == expected
      end
    end
  end

  describe "add_version_information/3" do
    test "correctly adds version information for versions 7 and 40" do
      for version <- [7, 40] do
        matrix = create_matrix(version)
        size = length(matrix)

        {result, bottom_left_bits} =
          FormatVersionInfo.add_version_information(matrix, version, size)

        assert result != matrix
        assert_version_info_added(result, bottom_left_bits, version)
      end
    end

    test "does not modify matrix for versions below 7" do
      matrix = create_matrix(6)
      size = length(matrix)
      assert FormatVersionInfo.add_version_information(matrix, 6, size) == {matrix, []}
    end
  end

  describe "add_format_information/2" do
    test "adds format information correctly for version 1, low error correction, mask pattern 0" do
      version = 1
      error_correction = :low
      mask_pattern = 0
      format_info = FormatVersionInfo.generate_format_information(error_correction, mask_pattern)

      base_matrix = TestHelper.generate_base_matrix(version)
      result_matrix = FormatVersionInfo.add_format_information(base_matrix, format_info)

      # Check specific positions where format information should be added
      assert_format_info_positions(result_matrix, format_info)
    end

    test "adds format information correctly for version 7, high error correction, mask pattern 5" do
      version = 7
      error_correction = :high
      mask_pattern = 5
      format_info = FormatVersionInfo.generate_format_information(error_correction, mask_pattern)

      base_matrix = TestHelper.generate_base_matrix(version)
      result_matrix = FormatVersionInfo.add_format_information(base_matrix, format_info)

      # Check specific positions where format information should be added
      assert_format_info_positions(result_matrix, format_info)
    end

    test "does not overwrite existing data in the matrix" do
      version = 1
      error_correction = :medium
      mask_pattern = 3
      format_info = FormatVersionInfo.generate_format_information(error_correction, mask_pattern)

      base_matrix = TestHelper.generate_base_matrix(version)

      # Manually set some data in positions where format info should not be written
      base_matrix = put_in(base_matrix, [Access.at(0), Access.at(0)], 1)
      # Changed from (8, 8) to (4, 4)
      base_matrix = put_in(base_matrix, [Access.at(4), Access.at(4)], 1)

      result_matrix = FormatVersionInfo.add_format_information(base_matrix, format_info)

      # Check that our manually set data remains unchanged
      assert get_in(result_matrix, [Access.at(0), Access.at(0)]) == 1
      # Changed from (8, 8) to (4, 4)
      assert get_in(result_matrix, [Access.at(4), Access.at(4)]) == 1

      # Check that format information is still added correctly
      assert_format_info_positions(result_matrix, format_info)
    end
  end

  defp create_matrix(version) do
    size = version * 4 + 17
    List.duplicate(List.duplicate(0, size), size)
  end

  defp assert_version_info_added(matrix, bottom_left_bits, version) do
    size = length(matrix)
    version_info = FormatVersionInfo.generate_version_information(version)
    expected_bits = for i <- 0..17, do: version_info >>> (17 - i) &&& 1

    top_right_bits =
      for y <- 0..5, x <- (size - 11)..(size - 9), do: Enum.at(matrix, y) |> Enum.at(x)

    assert top_right_bits == expected_bits, "Top-right version info bits are incorrect"
    assert bottom_left_bits == expected_bits, "Bottom-left version info bits are incorrect"

    Enum.each(0..17, fn i ->
      bit = Enum.at(expected_bits, i)

      assert Enum.at(matrix, div(i, 3)) |> Enum.at(size - 11 + rem(i, 3)) == bit,
             "Mismatch at top-right (#{div(i, 3)},#{size - 11 + rem(i, 3)}): expected #{bit}"

      assert Enum.at(bottom_left_bits, i) == bit,
             "Mismatch at bottom-left (bit #{i}): expected #{bit}"
    end)
  end

  defp assert_format_info_positions(matrix, format_info) do
    size = length(matrix)

    # Check format info around the top-left finder pattern
    Enum.each(0..14, fn i ->
      expected_bit = format_info >>> (14 - i) &&& 1

      cond do
        i < 6 -> assert get_in(matrix, [Access.at(i), Access.at(8)]) == expected_bit
        i == 6 -> assert get_in(matrix, [Access.at(7), Access.at(8)]) == expected_bit
        i == 7 -> assert get_in(matrix, [Access.at(8), Access.at(8)]) == expected_bit
        i == 8 -> assert get_in(matrix, [Access.at(8), Access.at(7)]) == expected_bit
        true -> assert get_in(matrix, [Access.at(8), Access.at(14 - i)]) == expected_bit
      end
    end)

    # Check format info below the top-right finder pattern and to the left of the bottom-left finder pattern
    Enum.each(0..14, fn i ->
      expected_bit = format_info >>> (14 - i) &&& 1

      cond do
        i < 8 -> assert get_in(matrix, [Access.at(8), Access.at(size - 1 - i)]) == expected_bit
        true -> assert get_in(matrix, [Access.at(size - 15 + i), Access.at(8)]) == expected_bit
      end
    end)
  end
end
