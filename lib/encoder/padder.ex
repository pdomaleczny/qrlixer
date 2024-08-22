alias QRlixer.CapacityTable

defmodule QRlixer.Padder do
  def add_padding(data, version, error_correction) do
    data_capacity = get_data_capacity(version, error_correction)
    current_size = bit_size(data)
    padding_needed = max(0, data_capacity - current_size)

    if padding_needed > 0 do
      aligned_data = byte_align(data)
      padding_bytes = div(padding_needed, 8)
      padding = generate_padding(padding_bytes)
      <<aligned_data::bitstring, padding::bitstring>>
    else
      data
    end
  end

  defp byte_align(data) do
    case rem(bit_size(data), 8) do
      0 -> data
      r -> <<data::bitstring, 0::size(8 - r)>>
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
    QRlixer.CapacityTable.get_capacity(version, error_correction)
    |> elem(2)
    |> Kernel.*(8)
  end
end
