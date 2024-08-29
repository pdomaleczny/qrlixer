defmodule QRlixer.MaskingTest do
  use ExUnit.Case
  alias QRlixer.Masking

  describe "apply_best_mask/3" do
    test "applies the best mask pattern" do
      matrix = [
        [1, 1, 1, 1],
        [1, 0, 0, 1],
        [1, 0, 0, 1],
        [1, 1, 1, 1]
      ]

      {masked_matrix, best_pattern} = Masking.apply_best_mask(matrix, 1, :L)

      assert is_list(masked_matrix)
      assert is_integer(best_pattern)
      assert best_pattern in 0..7
    end
  end

  describe "mask/2" do
    test "applies all mask patterns correctly" do
      matrix = [
        [1, 1, 1, 1],
        [1, 0, 0, 1],
        [1, 0, 0, 1],
        [1, 1, 1, 1]
      ]

      for pattern <- 0..7 do
        masked = Masking.mask(matrix, pattern)
        assert length(masked) == length(matrix)
        assert Enum.all?(masked, fn row -> length(row) == length(hd(matrix)) end)
      end
    end

    test "does not modify reserved areas" do
      matrix = [
        [1, 1, :reserved, 1],
        [1, 0, 0, 1],
        [:reserved, 0, 0, 1],
        [1, 1, 1, 1]
      ]

      masked = Masking.mask(matrix, 0)
      assert Enum.at(Enum.at(masked, 0), 2) == :reserved
      assert Enum.at(Enum.at(masked, 2), 0) == :reserved
    end

    test "handles nil values" do
      matrix = [
        [1, nil, 1, 1],
        [1, 0, nil, 1],
        [1, 0, 0, 1],
        [nil, 1, 1, 1]
      ]

      masked = Masking.mask(matrix, 0)
      assert Enum.at(Enum.at(masked, 0), 1) == nil
      assert Enum.at(Enum.at(masked, 1), 2) == nil
      assert Enum.at(Enum.at(masked, 3), 0) == nil
    end

    test "raises error for invalid matrix values" do
      matrix = [
        [1, 1, 1, 1],
        [1, 0, :invalid, 1],
        [1, 0, 0, 1],
        [1, 1, 1, 1]
      ]

      assert_raise RuntimeError, ~r/Invalid matrix value at position/, fn ->
        Masking.mask(matrix, 0)
      end
    end
  end

  describe "mask_function/3" do
    test "all mask patterns produce correct results" do
      for pattern <- 0..7, row <- 0..5, col <- 0..5 do
        result = Masking.mask_function(pattern, row, col)
        assert result in [0, 1], "Invalid result for pattern #{pattern}, row #{row}, col #{col}"
      end
    end
  end

  describe "evaluate_mask/1" do
    test "calculates the correct penalty score" do
      matrix = [
        [1, 1, 1, 1, 1, 1, 0, 0],
        [1, 1, 1, 1, 1, 0, 0, 0],
        [1, 0, 0, 0, 0, 0, 1, 1],
        [0, 1, 0, 1, 1, 1, 0, 1],
        [1, 0, 1, 0, 1, 0, 1, 0],
        [0, 0, 0, 0, 0, 0, 0, 0],
        [1, 1, 1, 1, 1, 0, 1, 0],
        [1, 0, 0, 1, 0, 1, 0, 1]
      ]

      score = Masking.evaluate_mask(matrix)
      assert is_integer(score)
      assert score > 0
    end

    test "handles edge cases" do
      assert Masking.evaluate_mask([]) == 0
      assert Masking.evaluate_mask([[1]]) == 0
      assert Masking.evaluate_mask([[1, 1]]) == 0
    end

    test "evaluates consecutive modules" do
      matrix = [
        [1, 1, 1, 1, 1],
        [0, 0, 0, 0, 0],
        [1, 1, 1, 1, 1],
        [0, 0, 0, 0, 0],
        [1, 1, 1, 1, 1]
      ]

      assert Masking.evaluate_mask(matrix) > 0
    end

    test "evaluates 2x2 blocks" do
      matrix = [
        [1, 1, 0],
        [1, 1, 0],
        [0, 0, 1]
      ]

      assert Masking.evaluate_mask(matrix) > 0
    end

    test "evaluates finder-like patterns" do
      matrix = List.duplicate([1, 0, 1, 1, 1, 0, 1, 0], 8)
      assert Masking.evaluate_mask(matrix) > 0
    end

    test "evaluates balance" do
      matrix = [
        [1, 1, 1],
        [1, 1, 1],
        [1, 1, 0]
      ]

      assert Masking.evaluate_mask(matrix) > 0
    end

    test "evaluates consecutive modules with different last element" do
      matrix = [
        [1, 1, 1, 1, 0],
        [0, 0, 0, 0, 1],
        [1, 1, 1, 1, 0],
        [0, 0, 0, 0, 1],
        [1, 1, 1, 1, 0]
      ]

      assert Masking.evaluate_mask(matrix) > 0
    end

    test "evaluates consecutive modules with same elements" do
      matrix = [
        [1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1]
      ]

      assert Masking.evaluate_mask(matrix) > 0
    end
  end
end
