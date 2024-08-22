defmodule QRlixer do
  @moduledoc """
  QRlixer is a library for generating QR codes in Elixir.
  """

  alias QRlixer.Encoder
  alias QRlixer.Matrix
  alias QRlixer.Renderer

  @doc """
  Generates a QR code from the given input string.

  ## Parameters

    - input: The string to encode in the QR code
    - options: A keyword list of options (optional)
      - :size - The size of the QR code (default: smallest size that fits the data)
      - :error_correction - The error correction level (:low, :medium, :quartile, :high) (default: :medium)

  ## Returns

    A binary representing a PNG image of the QR code
  """
  @spec generate(String.t(), keyword()) :: binary()
  def generate(input, options \\ []) do
    encoded_data = Encoder.encode(input, options)
    matrix = Matrix.generate(encoded_data, options)
    Renderer.render(matrix, options)
  end
end
