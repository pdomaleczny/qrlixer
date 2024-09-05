defmodule QRlixer.Matrix.FinderPatternTest do
  use ExUnit.Case
  alias QRlixer.Matrix.FinderPattern

  describe "add/2" do
    test "adds finder patterns to version 1 QR code (21x21)" do
      matrix = create_empty_matrix(21)
      result = FinderPattern.add(matrix, 1)

      assert_finder_pattern(result, 0, 0)    # Top-left
      assert_finder_pattern(result, 14, 0)   # Top-right
      assert_finder_pattern(result, 0, 14)   # Bottom-left
      assert_separators(result, 21)
    end

    test "adds finder patterns to version 40 QR code (177x177)" do
      matrix = create_empty_matrix(177)
      result = FinderPattern.add(matrix, 40)

      assert_finder_pattern(result, 0, 0)    # Top-left
      assert_finder_pattern(result, 170, 0)  # Top-right
      assert_finder_pattern(result, 0, 170)  # Bottom-left
      assert_separators(result, 177)
    end
  end

  defp create_empty_matrix(size) do
    for _ <- 1..size, do: List.duplicate(nil, size)
  end

  defp assert_finder_pattern(matrix, row, col) do
    pattern = [
      [1, 1, 1, 1, 1, 1, 1],
      [1, 0, 0, 0, 0, 0, 1],
      [1, 0, 1, 1, 1, 0, 1],
      [1, 0, 1, 1, 1, 0, 1],
      [1, 0, 1, 1, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 1],
      [1, 1, 1, 1, 1, 1, 1]
    ]

    Enum.each(0..6, fn r ->
      Enum.each(0..6, fn c ->
        assert Enum.at(Enum.at(matrix, row + r), col + c) == Enum.at(Enum.at(pattern, r), c),
               "Mismatch at position (#{row + r}, #{col + c})"
      end)
    end)
  end

  defp assert_separators(matrix, size) do
    # Check horizontal separators
    assert Enum.all?(Enum.at(matrix, 7) |> Enum.slice(0..7), &(&1 == 0))
    assert Enum.all?(Enum.at(matrix, 7) |> Enum.slice((size-8)..(size-1)), &(&1 == 0))
    assert Enum.all?(Enum.at(matrix, size-8) |> Enum.slice(0..7), &(&1 == 0))

    # Check vertical separators
    assert Enum.all?(0..7, fn i -> Enum.at(matrix, i) |> Enum.at(7) == 0 end)
    assert Enum.all?((size-8)..(size-1), fn i -> Enum.at(matrix, i) |> Enum.at(7) == 0 end)
    assert Enum.all?(0..7, fn i -> Enum.at(matrix, i) |> Enum.at(size-8) == 0 end)
  end
end
