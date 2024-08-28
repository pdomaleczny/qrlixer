defmodule QRlixer.UtilitiesTest do
  use ExUnit.Case
  doctest QRlixer.Utilities

  alias QRlixer.Utilities

  describe "combination/2" do
    test "returns an empty list when the input list is empty" do
      assert Utilities.combination([], 2) == []
    end

    test "returns a list with an empty list when m is 0" do
      assert Utilities.combination([1, 2, 3], 0) == [[]]
    end

    test "returns correct combinations for a simple list" do
      assert Utilities.combination([1, 2, 3], 2) == [[1, 2], [1, 3], [2, 3]]
    end

    test "returns correct combinations for a larger list" do
      result = Utilities.combination([1, 2, 3, 4], 3)
      expected = [[1, 2, 3], [1, 2, 4], [1, 3, 4], [2, 3, 4]]
      assert Enum.sort(result) == Enum.sort(expected)
    end

    test "returns the input list when m equals the list length" do
      assert Utilities.combination([1, 2, 3], 3) == [[1, 2, 3]]
    end

    test "returns an empty list when m is greater than the list length" do
      assert Utilities.combination([1, 2, 3], 4) == []
    end

    test "works with non-integer elements" do
      result = Utilities.combination([:a, :b, :c], 2)
      expected = [[:a, :b], [:a, :c], [:b, :c]]
      assert Enum.sort(result) == Enum.sort(expected)
    end
  end

  describe "create_empty_matrix/1" do
    test "creates a 1x1 matrix" do
      assert Utilities.create_empty_matrix(1) == [[nil]]
    end

    test "creates a 3x3 matrix" do
      expected = [
        [nil, nil, nil],
        [nil, nil, nil],
        [nil, nil, nil]
      ]

      assert Utilities.create_empty_matrix(3) == expected
    end

    test "creates a 5x5 matrix" do
      result = Utilities.create_empty_matrix(5)
      assert length(result) == 5
      assert Enum.all?(result, fn row -> length(row) == 5 end)
      assert Enum.all?(result, fn row -> Enum.all?(row, &is_nil/1) end)
    end

    test "handles large matrix sizes" do
      size = 100
      result = Utilities.create_empty_matrix(size)
      assert length(result) == size
      assert Enum.all?(result, fn row -> length(row) == size end)
      assert Enum.all?(result, fn row -> Enum.all?(row, &is_nil/1) end)
    end

    test "returns an empty list for size 0" do
      assert Utilities.create_empty_matrix(0) == []
    end
  end
end
