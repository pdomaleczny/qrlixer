defmodule QRlixer.InputValidator do
  @numeric_regex ~r/^\d+$/
  @alphanumeric_regex ~r/^[0-9A-Z $%*+\-.\/:]+$/

  def validate_input!(""), do: raise(ArgumentError, "Empty input")

  def validate_input!(input) do
    if String.valid?(input), do: :ok, else: raise(ArgumentError, "Invalid Unicode input")
  end

  def validate_version!(version) when version in 1..40, do: version
  def validate_version!(_), do: raise(ArgumentError, "Invalid version (must be between 1 and 40)")

  def validate_error_correction!(level) when level in [:low, :medium, :quartile, :high], do: level
  def validate_error_correction!(_), do: raise(ArgumentError, "Invalid error correction level")

  def validate_capacity!(input, mode, version, error_correction) do
    input_length = String.length(input)

    max_capacity =
      QRlixer.CapacityTable.get_capacity(version, error_correction)
      |> get_mode_capacity(mode)

    if input_length > max_capacity do
      raise ArgumentError,
            "Input exceeds maximum capacity for version #{version} with #{error_correction} error correction. Max capacity: #{max_capacity} characters, Input length: #{input_length} characters"
    end
  end

  def determine_mode(input) do
    cond do
      Regex.match?(@numeric_regex, input) -> :numeric
      Regex.match?(@alphanumeric_regex, input) -> :alphanumeric
      ascii_only?(input) -> :byte
      true -> raise ArgumentError, "Unsupported input: contains non-ASCII characters"
    end
  end

  defp ascii_only?(string) do
    string
    |> String.to_charlist()
    |> Enum.all?(fn char -> char in 0..127 end)
  end

  defp get_mode_capacity({numeric, alphanumeric, byte}, mode) do
    case mode do
      :numeric -> numeric
      :alphanumeric -> alphanumeric
      :byte -> byte
    end
  end
end
