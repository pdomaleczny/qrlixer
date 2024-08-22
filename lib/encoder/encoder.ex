defmodule QRlixer.Encoder do
  @moduledoc """
  Handles the encoding of input data for QR code generation.
  """

  alias QRlixer.InputValidator
  alias QRlixer.Padder
  alias QRlixer.ErrorCorrector

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
  def encode(input, options) do
    InputValidator.validate_input!(input)
    version = InputValidator.validate_version!(Keyword.get(options, :version, 1))

    error_correction =
      InputValidator.validate_error_correction!(Keyword.get(options, :error_correction, :low))

    mode = InputValidator.determine_mode(input)
    InputValidator.validate_capacity!(input, mode, version, error_correction)

    data = encode_data(input, mode, version)
    padded_data = Padder.add_padding(data, version, error_correction)
    ErrorCorrector.add_error_correction(padded_data, version, error_correction)
  end

  defp encode_data(input, mode, version) do
    mode_indicator = mode_indicator(mode)
    character_count_indicator = character_count_indicator(input, mode, version)
    encoded_data = do_encode_data(input, mode)

    <<mode_indicator::bitstring, character_count_indicator::bitstring, encoded_data::bitstring>>
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

  defp do_encode_data(input, :numeric) do
    input
    |> String.graphemes()
    |> Stream.chunk_every(3)
    |> Stream.map(&encode_numeric_group/1)
    |> Enum.reduce(<<>>, fn group, acc -> <<acc::bitstring, group::bitstring>> end)
  end

  defp do_encode_data(input, :alphanumeric) do
    input
    |> String.to_charlist()
    |> Stream.chunk_every(2)
    |> Stream.map(&encode_alphanumeric_group/1)
    |> Enum.reduce(<<>>, fn group, acc -> <<acc::bitstring, group::bitstring>> end)
  end

  defp do_encode_data(input, :byte) do
    for <<byte <- input>>, into: <<>>, do: <<byte>>
  end

  defp encode_numeric_group(group) do
    number = Enum.join(group) |> String.to_integer()

    case length(group) do
      3 -> <<number::10>>
      2 -> <<number::7>>
      1 -> <<number::4>>
    end
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
end
