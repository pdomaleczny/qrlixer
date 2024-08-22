defmodule QRlixer.InputValidatorTest do
  use ExUnit.Case
  alias QRlixer.InputValidator

  describe "validate_input!/1" do
    test "accepts valid input" do
      assert InputValidator.validate_input!("Hello World") == :ok
    end

    test "raises error for empty input" do
      assert_raise ArgumentError, "Empty input", fn ->
        InputValidator.validate_input!("")
      end
    end

    test "raises error for invalid Unicode" do
      assert_raise ArgumentError, "Invalid Unicode input", fn ->
        InputValidator.validate_input!(<<255>>)
      end
    end
  end

  describe "validate_version!/1" do
    test "accepts valid versions" do
      Enum.each(1..40, fn version ->
        assert InputValidator.validate_version!(version) == version
      end)
    end

    test "raises error for invalid versions" do
      assert_raise ArgumentError, "Invalid version (must be between 1 and 40)", fn ->
        InputValidator.validate_version!(0)
      end

      assert_raise ArgumentError, "Invalid version (must be between 1 and 40)", fn ->
        InputValidator.validate_version!(41)
      end
    end
  end

  describe "validate_error_correction!/1" do
    test "accepts valid error correction levels" do
      Enum.each([:low, :medium, :quartile, :high], fn level ->
        assert InputValidator.validate_error_correction!(level) == level
      end)
    end

    test "raises error for invalid error correction levels" do
      assert_raise ArgumentError, "Invalid error correction level", fn ->
        InputValidator.validate_error_correction!(:invalid)
      end
    end
  end

  describe "determine_mode/1" do
    test "determines numeric mode" do
      assert InputValidator.determine_mode("12345") == :numeric
    end

    test "determines alphanumeric mode" do
      assert InputValidator.determine_mode("HELLO123") == :alphanumeric
    end

    test "determines byte mode" do
      assert InputValidator.determine_mode("Hello, World!") == :byte
    end

    test "raises error for unsupported input" do
      assert_raise ArgumentError, "Unsupported input: contains non-ASCII characters", fn ->
        InputValidator.determine_mode("こんにちは")
      end
    end
  end

  describe "validate_capacity!/4" do
    test "accepts input within capacity" do
      assert InputValidator.validate_capacity!("1234", :numeric, 1, :low) == :ok
    end

    test "raises error for input exceeding capacity" do
      assert_raise ArgumentError, ~r/Input exceeds maximum capacity/, fn ->
        InputValidator.validate_capacity!(String.duplicate("A", 100), :alphanumeric, 1, :low)
      end
    end
  end
end
