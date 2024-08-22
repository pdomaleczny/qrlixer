defmodule QRlixer.ErrorCorrectorTest do
  use ExUnit.Case
  alias QRlixer.ErrorCorrector

  describe "add_error_correction/3" do
    test "adds correct number of error correction codewords" do
      input = <<1, 2, 3>>
      corrected = ErrorCorrector.add_error_correction(input, 1, :low)
      # 26 bytes (208 bits) for Version 1
      assert bit_size(corrected) == 208
    end

    test "pads data to correct length before adding EC codewords" do
      input = <<1>>
      corrected = ErrorCorrector.add_error_correction(input, 1, :low)
      # 26 bytes (208 bits) for Version 1
      assert bit_size(corrected) == 208
    end

    test "produces same size output for different error correction levels in Version 1" do
      input = <<1, 2, 3>>
      corrected_low = ErrorCorrector.add_error_correction(input, 1, :low)
      corrected_medium = ErrorCorrector.add_error_correction(input, 1, :medium)
      corrected_quartile = ErrorCorrector.add_error_correction(input, 1, :quartile)
      corrected_high = ErrorCorrector.add_error_correction(input, 1, :high)

      assert bit_size(corrected_low) == 208
      assert bit_size(corrected_medium) == 208
      assert bit_size(corrected_quartile) == 208
      assert bit_size(corrected_high) == 208
    end

    test "produces different size output for different versions" do
      input = <<1, 2, 3>>
      corrected_v1 = ErrorCorrector.add_error_correction(input, 1, :low)
      corrected_v2 = ErrorCorrector.add_error_correction(input, 2, :low)

      assert bit_size(corrected_v1) < bit_size(corrected_v2)
    end
  end
end
