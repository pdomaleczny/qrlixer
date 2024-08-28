defmodule QRlixer.FinderPatternsTest do
  use ExUnit.Case
  alias QRlixer.FinderPatterns

  test "add_finder_patterns/1 adds correct patterns to matrix" do
    size = 21
    matrix = for _ <- 1..size, do: List.duplicate(0, size)
    result = FinderPatterns.add_finder_patterns(matrix)

    # Check top-left finder pattern
    assert Enum.slice(result, 0..6) |> Enum.map(&Enum.slice(&1, 0..6)) == [
             [1, 1, 1, 1, 1, 1, 1],
             [1, 0, 0, 0, 0, 0, 1],
             [1, 0, 1, 1, 1, 0, 1],
             [1, 0, 1, 1, 1, 0, 1],
             [1, 0, 1, 1, 1, 0, 1],
             [1, 0, 0, 0, 0, 0, 1],
             [1, 1, 1, 1, 1, 1, 1]
           ]

    # Check separators
    assert Enum.at(result, 7) |> Enum.slice(0..7) == [0, 0, 0, 0, 0, 0, 0, 0]
    assert Enum.map(0..7, &(Enum.at(result, &1) |> Enum.at(7))) == [0, 0, 0, 0, 0, 0, 0, 0]
  end
end
