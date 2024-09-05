defmodule QRlixer.Matrix.TimingPatternTest do
  use ExUnit.Case
  alias QRlixer.Matrix.TimingPattern

  describe "add/1" do
    test "adds timing patterns for version 1 (21x21)" do
      matrix = create_empty_matrix(21)
      result = TimingPattern.add(matrix)
      assert_timing_patterns(result, 21)
    end

    test "adds timing patterns for version 20 (97x97)" do
      matrix = create_empty_matrix(97)
      result = TimingPattern.add(matrix)
      assert_timing_patterns(result, 97)
    end

    test "adds timing patterns for version 40 (177x177)" do
      matrix = create_empty_matrix(177)
      result = TimingPattern.add(matrix)
      assert_timing_patterns(result, 177)
    end
  end

  defp create_empty_matrix(size) do
    for _ <- 1..size, do: List.duplicate(nil, size)
  end

  defp assert_timing_patterns(matrix, size) do
    # Check horizontal timing pattern
    horizontal_pattern = Enum.at(matrix, 6)
    assert Enum.all?(8..(size - 9), fn i -> Enum.at(horizontal_pattern, i) == rem(i, 2) end)

    # Check vertical timing pattern
    assert Enum.all?(8..(size - 9), fn i ->
             Enum.at(Enum.at(matrix, i), 6) == rem(i, 2)
           end)

    # Check that timing patterns don't overwrite finder pattern areas
    assert Enum.all?(0..7, fn i -> Enum.at(horizontal_pattern, i) == nil end)
    assert Enum.all?((size - 8)..(size - 1), fn i -> Enum.at(horizontal_pattern, i) == nil end)
    assert Enum.all?(0..7, fn i -> Enum.at(Enum.at(matrix, i), 6) == nil end)
    assert Enum.all?((size - 8)..(size - 1), fn i -> Enum.at(Enum.at(matrix, i), 6) == nil end)
  end
end
