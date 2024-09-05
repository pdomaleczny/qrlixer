defmodule QRlixer.Matrix.AlignmentPatternTest do
  use ExUnit.Case
  alias QRlixer.Matrix.AlignmentPattern

  describe "add/2" do
    test "does not add alignment patterns for version 1" do
      matrix = create_empty_matrix(21)
      result = AlignmentPattern.add(matrix, 1)
      assert result == matrix
    end

    test "adds alignment patterns for version 2" do
      matrix = create_empty_matrix(25)
      result = AlignmentPattern.add(matrix, 2)
      assert_alignment_pattern(result, 18, 18)
    end

    test "adds alignment patterns for version 7" do
      matrix = create_empty_matrix(45)
      result = AlignmentPattern.add(matrix, 7)

      for x <- [6, 22, 38], y <- [6, 22, 38] do
        unless (x == 6 and y == 6) or (x == 38 and y == 6) or (x == 6 and y == 38) do
          assert_alignment_pattern(result, x, y)
        end
      end
    end

    test "adds alignment patterns for version 40" do
      matrix = create_empty_matrix(177)
      result = AlignmentPattern.add(matrix, 40)
      positions = [6, 30, 58, 86, 114, 142, 170]

      for x <- positions, y <- positions do
        unless (x == 6 and y == 6) or (x == 170 and y == 6) or (x == 6 and y == 170) do
          assert_alignment_pattern(result, x, y)
        end
      end
    end
  end

  defp create_empty_matrix(size) do
    for _ <- 1..size, do: List.duplicate(nil, size)
  end

  defp assert_alignment_pattern(matrix, center_x, center_y) do
    pattern = [
      [1, 1, 1, 1, 1],
      [1, 0, 0, 0, 1],
      [1, 0, 1, 0, 1],
      [1, 0, 0, 0, 1],
      [1, 1, 1, 1, 1]
    ]

    Enum.each(-2..2, fn y_offset ->
      Enum.each(-2..2, fn x_offset ->
        assert Enum.at(Enum.at(matrix, center_y + y_offset), center_x + x_offset) ==
                 Enum.at(Enum.at(pattern, y_offset + 2), x_offset + 2),
               "Mismatch at position (#{center_x + x_offset}, #{center_y + y_offset})"
      end)
    end)
  end
end
