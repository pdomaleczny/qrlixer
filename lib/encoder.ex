# TODOS::
# Implement actual error correction code calculation using Reed-Solomon algorithm.
# Create lookup tables for exact capacities and error correction levels for each version, rather than using simplified calculations.
# Implement support for mixing modes within a single QR code for optimal data compression.
# Add support for structured append mode for splitting data across multiple QR codes.
# Implement Kanji mode encoding for improved efficiency with Kanji characters.

defmodule QRlixer.Encoder do
  @moduledoc """
  Handles the encoding of input data for QR code generation.
  """

  alias QRlixer.CodeWordCount
  alias QRlixer.CapacityTable

  @numeric_regex ~r/^\d+$/
  @alphanumeric_regex ~r/^[0-9A-Z $%*+\-.\/:]+$/
  @alphanumeric_chars "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:="

  @doc """
  Encodes the input string according to QR code specifications.

  ## Parameters

    - input: The string to encode
    - options: A keyword list of options
      - :version - The QR code version (1-40)
      - :error_correction - The error correction level (:low, :medium, :quartile, :high)

  ## Returns

    A bitstring representing the encoded data

  ## Raises

    - ArgumentError: If the input is empty, or if invalid version or error correction level is provided
  """
  @spec encode(String.t(), keyword()) :: bitstring()
  @spec encode(String.t(), keyword()) :: bitstring()
  def encode(input, options) do
    validate_input!(input)
    version = validate_version!(Keyword.get(options, :version, 1))
    error_correction = validate_error_correction!(Keyword.get(options, :error_correction, :low))

    mode = determine_mode(input)

    validate_capacity!(input, mode, version, error_correction)

    mode_indicator = mode_indicator(mode)

    character_count_indicator = character_count_indicator(input, mode, version)

    encoded_data = encode_data(input, mode)

    data =
      <<mode_indicator::bitstring, character_count_indicator::bitstring, encoded_data::bitstring>>

    padded_data = add_padding(data, version, error_correction)

    final_data = add_error_correction(padded_data, version, error_correction)

    final_data
  end

  defp validate_input!(""), do: raise(ArgumentError, "Empty input")

  defp validate_input!(input) do
    if String.valid?(input) do
      :ok
    else
      raise ArgumentError, "Invalid Unicode input"
    end
  end

  defp determine_mode(input) do
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

  defp validate_version!(version) when version in 1..40, do: version

  defp validate_version!(_),
    do: raise(ArgumentError, "Invalid version (must be between 1 and 40)")

  defp validate_error_correction!(level) when level in [:low, :medium, :quartile, :high],
    do: level

  defp validate_error_correction!(_), do: raise(ArgumentError, "Invalid error correction level")

  defp validate_capacity!(input, mode, version, error_correction) do
    input_length = String.length(input)
    max_capacity = get_max_capacity(mode, version, error_correction)

    if input_length > max_capacity do
      raise ArgumentError,
            "Input exceeds maximum capacity for version #{version} with #{error_correction} error correction. Max capacity: #{max_capacity} characters, Input length: #{input_length} characters"
    end
  end

  defp get_total_capacity(version) do
    # This is a simplified calculation and should be replaced with a more accurate one
    # based on the QR code specification in a production implementation
    (version * 4 + 17) * (version * 4 + 17) * 8
  end

  defp get_max_capacity(mode, version, error_correction) do
    {numeric, alphanumeric, byte} = CapacityTable.get_capacity(version, error_correction)

    case mode do
      :numeric -> numeric
      :alphanumeric -> alphanumeric
      :byte -> byte
    end
  end

  defp determine_mode(input) do
    cond do
      Regex.match?(@numeric_regex, input) -> :numeric
      Regex.match?(@alphanumeric_regex, input) -> :alphanumeric
      true -> :byte
    end
  end

  defp mode_indicator(:numeric), do: <<1::4>>
  defp mode_indicator(:alphanumeric), do: <<2::4>>
  defp mode_indicator(:byte), do: <<4::4>>

  defp character_count_indicator(input, mode, version) do
    count = String.length(input)
    indicator_length = get_indicator_length(mode, version)
    <<count::size(indicator_length)>>
  end

  defp get_indicator_length(:numeric, version) when version >= 1 and version <= 9, do: 10
  defp get_indicator_length(:numeric, version) when version >= 10 and version <= 26, do: 12
  defp get_indicator_length(:numeric, version) when version >= 27 and version <= 40, do: 14
  defp get_indicator_length(:alphanumeric, version) when version >= 1 and version <= 9, do: 9
  defp get_indicator_length(:alphanumeric, version) when version >= 10 and version <= 26, do: 11
  defp get_indicator_length(:alphanumeric, version) when version >= 27 and version <= 40, do: 13
  defp get_indicator_length(:byte, version) when version >= 1 and version <= 9, do: 8
  defp get_indicator_length(:byte, version) when version >= 10 and version <= 40, do: 16

  defp encode_data(input, :numeric) do
    input
    |> String.graphemes()
    |> Stream.chunk_every(3)
    |> Stream.map(&encode_numeric_group/1)
    |> Enum.reduce(<<>>, fn group, acc -> <<acc::bitstring, group::bitstring>> end)
  end

  defp encode_numeric_group(group) do
    number = Enum.join(group) |> String.to_integer()

    case length(group) do
      3 -> <<number::10>>
      2 -> <<number::7>>
      1 -> <<number::4>>
    end
  end

  defp encode_data(input, :alphanumeric) do
    input
    |> String.to_charlist()
    |> Stream.chunk_every(2)
    |> Stream.map(&encode_alphanumeric_group/1)
    |> Enum.reduce(<<>>, fn group, acc -> <<acc::bitstring, group::bitstring>> end)
  end

  defp encode_alphanumeric_group([char1, char2]) do
    val1 = alphanumeric_value(char1)
    val2 = alphanumeric_value(char2)
    <<val1 * 45 + val2::11>>
  end

  defp encode_alphanumeric_group([char]) do
    val = alphanumeric_value(char)
    <<val::6>>
  end

  defp alphanumeric_value(char) do
    case :binary.match(@alphanumeric_chars, <<char>>) do
      {index, 1} -> index
      :nomatch -> raise ArgumentError, "Invalid alphanumeric character: #{<<char>>}"
    end
  end

  defp encode_data(input, :byte) do
    for <<byte <- input>>, into: <<>>, do: <<byte>>
  end

  defp add_padding(data, version, error_correction) do
    data_capacity = get_data_capacity(version, error_correction)
    current_size = bit_size(data)
    padding_needed = max(0, data_capacity - current_size)

    if padding_needed > 0 do
      # Ensure the data is byte-aligned
      aligned_data =
        case rem(current_size, 8) do
          0 -> data
          r -> <<data::bitstring, 0::size(8 - r)>>
        end

      padding_bytes = div(padding_needed, 8)
      padding = generate_padding(padding_bytes)

      result = <<aligned_data::bitstring, padding::bitstring>>
      result
    else
      data
    end
  end

  defp generate_padding(bytes_needed) do
    for i <- 1..bytes_needed, into: <<>> do
      case rem(i, 2) do
        1 -> <<236>>
        0 -> <<17>>
      end
    end
  end

  defp get_data_capacity(version, error_correction) do
    # Convert byte capacity to bits
    get_max_capacity(:byte, version, error_correction) * 8
  end

  defp add_error_correction(data, version, error_correction) do
    {data_codewords, ec_codewords} = CodeWordCount.get_codeword_counts(version, error_correction)
    total_codewords = data_codewords + ec_codewords
    total_bits = total_codewords * 8

    # Pad the data to reach the data capacity
    padded_data =
      if bit_size(data) < data_codewords * 8 do
        padding_needed = data_codewords * 8 - bit_size(data)
        <<data::bitstring, 0::size(padding_needed)>>
      else
        data
      end

    # Add error correction bits (in a real implementation, you would calculate actual EC bits here)
    <<padded_data::bitstring, 0::size(ec_codewords * 8)>>
  end

  defp get_ec_bits(version, error_correction) do
    # This is a simplified version. In a real implementation, you would have a lookup table
    # based on the QR code specification.
    base_bits = version * 8

    case error_correction do
      :low -> floor(base_bits * 0.3)
      :medium -> floor(base_bits * 0.5)
      :quartile -> floor(base_bits * 0.7)
      :high -> base_bits
    end
  end
end
