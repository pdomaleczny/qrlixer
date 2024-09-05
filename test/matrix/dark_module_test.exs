defmodule QRlixer.Matrix.DarkModuleTest do
  use ExUnit.Case
  alias QRlixer.Matrix.DarkModule

  describe "add/2" do
    test "does not add dark module for version 1" do
      matrix = create_empty_matrix(21)
      result = DarkModule.add(matrix, 1)
      assert result == matrix
    end

    test "adds dark module for version 2" do
      matrix = create_empty_matrix(25)
      result = DarkModule.add(matrix, 2)
      assert_dark_module(result, 2)
    end

    test "adds dark module for version 20" do
      matrix = create_empty_matrix(97)
      result = DarkModule.add(matrix, 20)
      assert_dark_module(result, 20)
    end

    test "adds dark module for version 40" do
      matrix = create_empty_matrix(177)
      result = DarkModule.add(matrix, 40)
      assert_dark_module(result, 40)
    end
  end

  defp create_empty_matrix(size) do
    for _ <- 1..size, do: List.duplicate(nil, size)
  end

  defp assert_dark_module(matrix, version) do
    row = 4 * version + 9
    col = 8
    assert Enum.at(Enum.at(matrix, row), col) == 1
  end
end
