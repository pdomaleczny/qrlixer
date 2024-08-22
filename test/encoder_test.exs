defmodule QRlixer.EncoderTest do
  use ExUnit.Case
  alias QRlixer.Encoder

  describe "encode/2" do
    test "encodes numeric input correctly" do
      input = "1234567890"
      options = [version: 1, error_correction: :low]
      result = Encoder.encode(input, options)

      assert is_bitstring(result)
      assert <<0b0001::4, _rest::bitstring>> = result
    end

    test "encodes alphanumeric input correctly" do
      input = "HELLO WORLD"
      options = [version: 1, error_correction: :low]
      result = Encoder.encode(input, options)

      assert is_bitstring(result)
      assert <<0b0010::4, _rest::bitstring>> = result
    end

    test "encodes byte input correctly" do
      input = "Hello, World!"
      options = [version: 1, error_correction: :low]
      result = Encoder.encode(input, options)

      assert is_bitstring(result)
      assert <<0b0100::4, _rest::bitstring>> = result
    end

    test "adds error correction bits" do
      input = "1234"
      options = [version: 1, error_correction: :low]
      result = Encoder.encode(input, options)

      assert bit_size(result) > byte_size(input) * 8
    end

    test "raises error for unsupported input" do
      # Japanese text, which should use Kanji mode (not implemented in this basic version)
      input = "こんにちは"
      options = [version: 1, error_correction: :low]

      assert_raise ArgumentError, ~r/Unsupported input/, fn ->
        Encoder.encode(input, options)
      end
    end

    # # New edge case tests

    test "handles empty string input" do
      input = ""
      options = [version: 1, error_correction: :low]

      assert_raise ArgumentError, ~r/Empty input/, fn ->
        Encoder.encode(input, options)
      end
    end

    test "handles very long numeric input" do
      # Maximum capacity for numeric mode in version 40-L
      input = String.duplicate("9", 7089)
      options = [version: 40, error_correction: :low]
      result = Encoder.encode(input, options)

      assert is_bitstring(result)
      assert <<0b0001::4, _rest::bitstring>> = result
    end

    test "handles very long alphanumeric input" do
      # Maximum capacity for alphanumeric mode in version 40-L
      input = String.duplicate("A", 4296)
      options = [version: 40, error_correction: :low]
      result = Encoder.encode(input, options)

      assert is_bitstring(result)
      assert <<0b0010::4, _rest::bitstring>> = result
    end

    test "handles very long byte input" do
      # Maximum capacity for byte mode in version 40-L
      input = String.duplicate("a", 2953)
      options = [version: 40, error_correction: :low]
      result = Encoder.encode(input, options)

      assert is_bitstring(result)
      assert <<0b0100::4, _rest::bitstring>> = result
    end

    test "handles mixed alphanumeric and numeric input" do
      input = "HELLO123WORLD456"
      options = [version: 1, error_correction: :low]
      result = Encoder.encode(input, options)

      assert is_bitstring(result)
      # Should choose alphanumeric mode
      assert <<0b0010::4, _rest::bitstring>> = result
    end

    test "handles input with special characters" do
      input = "HELLO $%*+-./: WORLD"
      options = [version: 1, error_correction: :low]
      result = Encoder.encode(input, options)

      assert is_bitstring(result)
      # Should still be alphanumeric mode
      assert <<0b0010::4, _rest::bitstring>> = result
    end

    test "switches to byte mode for lowercase letters" do
      input = "Hello World"
      options = [version: 1, error_correction: :low]
      result = Encoder.encode(input, options)

      assert is_bitstring(result)
      # Should switch to byte mode
      assert <<0b0100::4, _rest::bitstring>> = result
    end

    test "handles different error correction levels" do
      input = "1234"
      options_low = [version: 1, error_correction: :low]
      options_medium = [version: 1, error_correction: :medium]
      options_quartile = [version: 1, error_correction: :quartile]
      options_high = [version: 1, error_correction: :high]

      result_low = Encoder.encode(input, options_low)
      result_medium = Encoder.encode(input, options_medium)
      result_quartile = Encoder.encode(input, options_quartile)
      result_high = Encoder.encode(input, options_high)

      assert bit_size(result_low) == 208, "Expected size for version 1-L is 208 bits"
      assert bit_size(result_medium) == 208, "Expected size for version 1-M is 208 bits"
      assert bit_size(result_quartile) == 208, "Expected size for version 1-Q is 208 bits"
      assert bit_size(result_high) == 208, "Expected size for version 1-H is 208 bits"

      # Check that all results have the correct mode indicator for numeric mode
      assert <<0b0001::4, _rest::bitstring>> = result_low
      assert <<0b0001::4, _rest::bitstring>> = result_medium
      assert <<0b0001::4, _rest::bitstring>> = result_quartile
      assert <<0b0001::4, _rest::bitstring>> = result_high

      # Check that the data portion sizes are correct
      assert bit_size(result_low) == (19 + 7) * 8, "Low EC should have 19 data + 7 EC codewords"

      assert bit_size(result_medium) == (16 + 10) * 8,
             "Medium EC should have 16 data + 10 EC codewords"

      assert bit_size(result_quartile) == (13 + 13) * 8,
             "Quartile EC should have 13 data + 13 EC codewords"

      assert bit_size(result_high) == (9 + 17) * 8, "High EC should have 9 data + 17 EC codewords"
    end

    test "handles different versions" do
      # 25 alphanumeric characters (fits in version 1-L)
      input_v1 = String.duplicate("A", 25)
      # 47 alphanumeric characters (fits in version 2-L, but not 1-L)
      input_v2 = String.duplicate("A", 47)
      options_v1 = [version: 1, error_correction: :low]
      options_v2 = [version: 2, error_correction: :low]

      result_v1 = Encoder.encode(input_v1, options_v1)

      result_v2 = Encoder.encode(input_v2, options_v2)

      assert is_bitstring(result_v1)
      assert is_bitstring(result_v2)
      assert bit_size(result_v1) < bit_size(result_v2)
    end

    test "raises error for input exceeding version capacity" do
      # 48 alphanumeric characters (exceeds version 1-L capacity)
      input = String.duplicate("A", 48)
      options = [version: 1, error_correction: :low]

      assert_raise ArgumentError, ~r/Input exceeds maximum capacity/, fn ->
        Encoder.encode(input, options)
      end
    end

    test "raises error for invalid version" do
      input = "HELLO WORLD"
      options = [version: 0, error_correction: :low]

      assert_raise ArgumentError, ~r/Invalid version/, fn ->
        Encoder.encode(input, options)
      end
    end

    test "raises error for invalid error correction level" do
      input = "HELLO WORLD"
      options = [version: 1, error_correction: :invalid]

      assert_raise ArgumentError, ~r/Invalid error correction level/, fn ->
        Encoder.encode(input, options)
      end
    end
  end
end
