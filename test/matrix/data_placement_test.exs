defmodule QRlixer.DataPlacementTest do
  use ExUnit.Case
  alias QRlixer.DataPlacement
  alias QRlixer.TestHelper
  require Logger

  describe "place_data/3" do
    test "places data correctly in a small matrix (version 1)" do
      version = 1
      encoded_data = <<0b1010101010::10>>
      expected_matrix = TestHelper.generate_expected_matrix(version, encoded_data)
      initial_matrix = TestHelper.generate_base_matrix(version)

      result = DataPlacement.place_data(initial_matrix, encoded_data, version)

      assert_matrices_equal(result, expected_matrix)
    end

    test "places data correctly in a medium matrix (version 2)" do
      version = 2
      encoded_data = <<0b101010101010101010101010101010101010::36>>
      expected_matrix = TestHelper.generate_expected_matrix(version, encoded_data)
      initial_matrix = TestHelper.generate_base_matrix(version)

      result = DataPlacement.place_data(initial_matrix, encoded_data, version)

      assert_matrices_equal(result, expected_matrix)
    end

    test "skips over reserved cells" do
      version = 1
      encoded_data = <<0b1010101010::10>>
      initial_matrix = TestHelper.generate_base_matrix(version)

      result = DataPlacement.place_data(initial_matrix, encoded_data, version)

      # Check that reserved cells are not overwritten
      Enum.each(0..(length(initial_matrix) - 1), fn row ->
        Enum.each(0..(length(Enum.at(initial_matrix, 0)) - 1), fn col ->
          initial_value = Enum.at(Enum.at(initial_matrix, row), col)
          result_value = Enum.at(Enum.at(result, row), col)

          if initial_value == :reserved do
            assert result_value == :reserved,
                   "Reserved cell at (#{row}, #{col}) was overwritten"
          end
        end)
      end)
    end

    test "handles empty encoded data" do
      version = 1
      encoded_data = <<>>
      initial_matrix = TestHelper.generate_base_matrix(version)

      result = DataPlacement.place_data(initial_matrix, encoded_data, version)

      assert_matrices_equal(result, initial_matrix)
    end

    test "places all data when there's exactly enough space" do
      version = 1
      # Generate data that will fill the entire available space
      encoded_data = <<0b1010101010101010101010101::25>>
      expected_matrix = TestHelper.generate_expected_matrix(version, encoded_data)
      initial_matrix = TestHelper.generate_base_matrix(version)

      result = DataPlacement.place_data(initial_matrix, encoded_data, version)

      assert_matrices_equal(result, expected_matrix)
    end
  end

  describe "edge cases and error handling" do
    test "raises error for invalid version" do
      matrix = [[nil]]
      encoded_data = <<0b1::1>>

      assert_raise FunctionClauseError, fn ->
        DataPlacement.place_data(matrix, encoded_data, 0)
      end

      assert_raise FunctionClauseError, fn ->
        DataPlacement.place_data(matrix, encoded_data, 41)
      end
    end
  end

  defp assert_matrices_equal(actual, expected) do
    assert length(actual) == length(expected), "Matrix sizes don't match"

    Enum.zip(actual, expected)
    |> Enum.with_index()
    |> Enum.each(fn {{actual_row, expected_row}, row_index} ->
      assert length(actual_row) == length(expected_row),
             "Row sizes don't match for row #{row_index}"

      Enum.zip(actual_row, expected_row)
      |> Enum.with_index()
      |> Enum.each(fn {{actual_cell, expected_cell}, col_index} ->
        assert actual_cell == expected_cell,
               "Mismatch at position (#{row_index}, #{col_index}): expected #{inspect(expected_cell)}, got #{inspect(actual_cell)}"
      end)
    end)
  end
end
