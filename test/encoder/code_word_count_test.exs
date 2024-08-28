defmodule QRlixer.CodeWordCountTest do
  use ExUnit.Case
  doctest QRlixer.CodeWordCount

  alias QRlixer.CodeWordCount

  describe "get_codeword_counts/2" do
    test "returns correct codeword counts for all versions and error correction levels" do
      for version <- 1..40,
          error_correction <- [:low, :medium, :quartile, :high] do
        {data_codewords, ec_codewords} =
          CodeWordCount.get_codeword_counts(version, error_correction)

        assert is_integer(data_codewords)
        assert is_integer(ec_codewords)
        assert data_codewords > 0
        assert ec_codewords > 0

        # Additional checks could be added here to verify specific values
        # For example, we could hardcode expected values for some versions
        case {version, error_correction} do
          {1, :low} -> assert {data_codewords, ec_codewords} == {19, 7}
          {1, :medium} -> assert {data_codewords, ec_codewords} == {16, 10}
          {1, :quartile} -> assert {data_codewords, ec_codewords} == {13, 13}
          {1, :high} -> assert {data_codewords, ec_codewords} == {9, 17}
          {40, :low} -> assert {data_codewords, ec_codewords} == {2956, 1276}
          {40, :medium} -> assert {data_codewords, ec_codewords} == {2334, 1898}
          {40, :quartile} -> assert {data_codewords, ec_codewords} == {1666, 2566}
          {40, :high} -> assert {data_codewords, ec_codewords} == {1276, 2956}
          _ -> :ok
        end
      end
    end

    test "raises ArgumentError for invalid versions" do
      for invalid_version <- [0, 41, -1, 1.5] do
        assert_raise ArgumentError, ~r/Invalid QR code version/, fn ->
          CodeWordCount.get_codeword_counts(invalid_version, :low)
        end
      end
    end

    test "raises ArgumentError for invalid error correction levels" do
      for invalid_ec <- [:invalid, "low", :medium_high, nil] do
        assert_raise ArgumentError, ~r/Invalid error correction level/, fn ->
          CodeWordCount.get_codeword_counts(1, invalid_ec)
        end
      end
    end

    test "total codewords increase with version" do
      for error_correction <- [:low, :medium, :quartile, :high] do
        codewords =
          for version <- 1..40 do
            {data, ec} = CodeWordCount.get_codeword_counts(version, error_correction)
            data + ec
          end

        assert codewords == Enum.sort(codewords)
      end
    end

    test "error correction codewords percentage is consistent with level" do
      for version <- 1..40 do
        {low_data, low_ec} = CodeWordCount.get_codeword_counts(version, :low)
        {medium_data, medium_ec} = CodeWordCount.get_codeword_counts(version, :medium)
        {quartile_data, quartile_ec} = CodeWordCount.get_codeword_counts(version, :quartile)
        {high_data, high_ec} = CodeWordCount.get_codeword_counts(version, :high)

        low_ec_percentage = low_ec / (low_data + low_ec)
        medium_ec_percentage = medium_ec / (medium_data + medium_ec)
        quartile_ec_percentage = quartile_ec / (quartile_data + quartile_ec)
        high_ec_percentage = high_ec / (high_data + high_ec)

        assert low_ec_percentage < medium_ec_percentage
        assert medium_ec_percentage < quartile_ec_percentage
        assert quartile_ec_percentage < high_ec_percentage
      end
    end
  end
end
