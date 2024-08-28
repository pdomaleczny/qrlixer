defmodule QRlixer.TimingPatternsTest do
  use ExUnit.Case
  alias QRlixer.TimingPatterns

  test "add_timing_patterns/1 adds correct patterns to matrix" do
    size = 21
    matrix = for _ <- 1..size, do: List.duplicate(0, size)
    result = TimingPatterns.add_timing_patterns(matrix)

    # Check horizontal timing pattern
    assert Enum.at(result, 6) |> Enum.slice(8..(size - 8)) == [1, 0, 1, 0, 1, 0]

    # Check vertical timing pattern
    vertical_pattern = for row <- 8..(size - 8), do: Enum.at(result, row) |> Enum.at(6)
    assert vertical_pattern == [1, 0, 1, 0, 1, 0]
  end
end
