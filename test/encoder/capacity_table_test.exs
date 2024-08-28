defmodule QRlixer.CapacityTableComprehensiveTest do
  use ExUnit.Case
  alias QRlixer.CapacityTable

  describe "get_capacity/2" do
    test "returns correct capacity for all versions and error correction levels" do
      for version <- 1..40,
          error_correction <- [:low, :medium, :quartile, :high] do
        capacity = CapacityTable.get_capacity(version, error_correction)
        assert is_tuple(capacity)
        assert tuple_size(capacity) == 3
        assert Enum.all?(Tuple.to_list(capacity), &is_integer/1)

        # Additional checks can be added here if needed
        # For example, we could check that capacities are within expected ranges
      end
    end

    test "capacity increases with version for all error correction levels" do
      for error_correction <- [:low, :medium, :quartile, :high] do
        capacities = for v <- 1..40, do: CapacityTable.get_capacity(v, error_correction)

        Enum.reduce(capacities, fn capacity, prev_capacity ->
          assert elem(capacity, 0) > elem(prev_capacity, 0)
          assert elem(capacity, 1) > elem(prev_capacity, 1)
          assert elem(capacity, 2) > elem(prev_capacity, 2)
          capacity
        end)
      end
    end

    test "capacity decreases with higher error correction for all versions" do
      for version <- 1..40 do
        low = CapacityTable.get_capacity(version, :low)
        medium = CapacityTable.get_capacity(version, :medium)
        quartile = CapacityTable.get_capacity(version, :quartile)
        high = CapacityTable.get_capacity(version, :high)

        assert elem(low, 0) > elem(medium, 0)
        assert elem(medium, 0) > elem(quartile, 0)
        assert elem(quartile, 0) > elem(high, 0)

        assert elem(low, 1) > elem(medium, 1)
        assert elem(medium, 1) > elem(quartile, 1)
        assert elem(quartile, 1) > elem(high, 1)

        assert elem(low, 2) > elem(medium, 2)
        assert elem(medium, 2) > elem(quartile, 2)
        assert elem(quartile, 2) > elem(high, 2)
      end
    end

    test "raises ArgumentError for invalid versions" do
      for version <- [0, 41, -1, 1.5] do
        assert_raise ArgumentError, fn ->
          CapacityTable.get_capacity(version, :low)
        end
      end
    end

    test "raises ArgumentError for invalid error correction levels" do
      invalid_levels = [:invalid, :very_high, "low", nil]

      for level <- invalid_levels do
        assert_raise ArgumentError, fn ->
          CapacityTable.get_capacity(1, level)
        end
      end
    end
  end

  # Additional test to verify specific capacities for a few versions
  test "verifies specific capacities for select versions" do
    assert CapacityTable.get_capacity(1, :low) == {41, 25, 17}
    assert CapacityTable.get_capacity(10, :medium) == {513, 311, 213}
    assert CapacityTable.get_capacity(20, :quartile) == {1159, 702, 482}
    assert CapacityTable.get_capacity(30, :high) == {1782, 1080, 742}
    assert CapacityTable.get_capacity(40, :low) == {7089, 4296, 2953}
  end
end
