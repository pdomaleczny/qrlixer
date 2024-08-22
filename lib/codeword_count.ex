defmodule QRlixer.CodeWordCount do
  @moduledoc """
  Provides specifications for QR codes, including codeword counts for all versions and error correction levels.
  """

  @doc """
  Returns a tuple containing the number of data codewords and error correction codewords
  for the given QR code version and error correction level.

  ## Parameters

    - version: Integer from 1 to 40
    - error_correction: Atom, one of [:low, :medium, :quartile, :high]

  ## Returns

    A tuple {data_codewords, ec_codewords}

  ## Raises

    ArgumentError if an invalid version or error correction level is provided
  """
  @spec get_codeword_counts(integer, atom) :: {integer, integer}
  def get_codeword_counts(version, error_correction)

  # Version 1
  def get_codeword_counts(1, :low), do: {19, 7}
  def get_codeword_counts(1, :medium), do: {16, 10}
  def get_codeword_counts(1, :quartile), do: {13, 13}
  def get_codeword_counts(1, :high), do: {9, 17}

  # Version 2
  def get_codeword_counts(2, :low), do: {34, 10}
  def get_codeword_counts(2, :medium), do: {28, 16}
  def get_codeword_counts(2, :quartile), do: {22, 22}
  def get_codeword_counts(2, :high), do: {16, 28}

  # Version 3
  def get_codeword_counts(3, :low), do: {55, 15}
  def get_codeword_counts(3, :medium), do: {44, 26}
  def get_codeword_counts(3, :quartile), do: {34, 36}
  def get_codeword_counts(3, :high), do: {26, 44}

  # Version 4
  def get_codeword_counts(4, :low), do: {80, 20}
  def get_codeword_counts(4, :medium), do: {64, 36}
  def get_codeword_counts(4, :quartile), do: {48, 52}
  def get_codeword_counts(4, :high), do: {36, 64}

  # Version 5
  def get_codeword_counts(5, :low), do: {108, 26}
  def get_codeword_counts(5, :medium), do: {86, 48}
  def get_codeword_counts(5, :quartile), do: {62, 72}
  def get_codeword_counts(5, :high), do: {46, 88}

  # Version 6
  def get_codeword_counts(6, :low), do: {136, 18}
  def get_codeword_counts(6, :medium), do: {108, 64}
  def get_codeword_counts(6, :quartile), do: {76, 88}
  def get_codeword_counts(6, :high), do: {60, 112}

  # Version 7
  def get_codeword_counts(7, :low), do: {156, 20}
  def get_codeword_counts(7, :medium), do: {124, 72}
  def get_codeword_counts(7, :quartile), do: {88, 110}
  def get_codeword_counts(7, :high), do: {66, 130}

  # Version 8
  def get_codeword_counts(8, :low), do: {194, 24}
  def get_codeword_counts(8, :medium), do: {154, 88}
  def get_codeword_counts(8, :quartile), do: {110, 132}
  def get_codeword_counts(8, :high), do: {86, 156}

  # Version 9
  def get_codeword_counts(9, :low), do: {232, 30}
  def get_codeword_counts(9, :medium), do: {182, 110}
  def get_codeword_counts(9, :quartile), do: {132, 160}
  def get_codeword_counts(9, :high), do: {100, 192}

  # Version 10
  def get_codeword_counts(10, :low), do: {274, 18}
  def get_codeword_counts(10, :medium), do: {216, 130}
  def get_codeword_counts(10, :quartile), do: {154, 192}
  def get_codeword_counts(10, :high), do: {122, 224}

  # Version 11
  def get_codeword_counts(11, :low), do: {324, 20}
  def get_codeword_counts(11, :medium), do: {254, 150}
  def get_codeword_counts(11, :quartile), do: {180, 224}
  def get_codeword_counts(11, :high), do: {140, 264}

  # Version 12
  def get_codeword_counts(12, :low), do: {370, 24}
  def get_codeword_counts(12, :medium), do: {290, 176}
  def get_codeword_counts(12, :quartile), do: {206, 260}
  def get_codeword_counts(12, :high), do: {158, 308}

  # Version 13
  def get_codeword_counts(13, :low), do: {428, 26}
  def get_codeword_counts(13, :medium), do: {334, 198}
  def get_codeword_counts(13, :quartile), do: {244, 288}
  def get_codeword_counts(13, :high), do: {180, 352}

  # Version 14
  def get_codeword_counts(14, :low), do: {461, 30}
  def get_codeword_counts(14, :medium), do: {365, 216}
  def get_codeword_counts(14, :quartile), do: {261, 320}
  def get_codeword_counts(14, :high), do: {197, 384}

  # Version 15
  def get_codeword_counts(15, :low), do: {523, 22}
  def get_codeword_counts(15, :medium), do: {415, 240}
  def get_codeword_counts(15, :quartile), do: {295, 360}
  def get_codeword_counts(15, :high), do: {223, 432}

  # Version 16
  def get_codeword_counts(16, :low), do: {589, 24}
  def get_codeword_counts(16, :medium), do: {453, 280}
  def get_codeword_counts(16, :quartile), do: {325, 408}
  def get_codeword_counts(16, :high), do: {253, 480}

  # Version 17
  def get_codeword_counts(17, :low), do: {647, 28}
  def get_codeword_counts(17, :medium), do: {507, 308}
  def get_codeword_counts(17, :quartile), do: {367, 448}
  def get_codeword_counts(17, :high), do: {283, 532}

  # Version 18
  def get_codeword_counts(18, :low), do: {721, 30}
  def get_codeword_counts(18, :medium), do: {563, 338}
  def get_codeword_counts(18, :quartile), do: {397, 504}
  def get_codeword_counts(18, :high), do: {313, 588}

  # Version 19
  def get_codeword_counts(19, :low), do: {795, 28}
  def get_codeword_counts(19, :medium), do: {627, 364}
  def get_codeword_counts(19, :quartile), do: {445, 546}
  def get_codeword_counts(19, :high), do: {341, 650}

  # Version 20
  def get_codeword_counts(20, :low), do: {861, 28}
  def get_codeword_counts(20, :medium), do: {669, 416}
  def get_codeword_counts(20, :quartile), do: {485, 600}
  def get_codeword_counts(20, :high), do: {385, 700}

  # Version 21
  def get_codeword_counts(21, :low), do: {932, 28}
  def get_codeword_counts(21, :medium), do: {714, 442}
  def get_codeword_counts(21, :quartile), do: {512, 644}
  def get_codeword_counts(21, :high), do: {406, 750}

  # Version 22
  def get_codeword_counts(22, :low), do: {1006, 28}
  def get_codeword_counts(22, :medium), do: {782, 476}
  def get_codeword_counts(22, :quartile), do: {568, 690}
  def get_codeword_counts(22, :high), do: {442, 816}

  # Version 23
  def get_codeword_counts(23, :low), do: {1094, 30}
  def get_codeword_counts(23, :medium), do: {860, 504}
  def get_codeword_counts(23, :quartile), do: {614, 750}
  def get_codeword_counts(23, :high), do: {464, 900}

  # Version 24
  def get_codeword_counts(24, :low), do: {1174, 30}
  def get_codeword_counts(24, :medium), do: {914, 560}
  def get_codeword_counts(24, :quartile), do: {664, 810}
  def get_codeword_counts(24, :high), do: {514, 960}

  # Version 25
  def get_codeword_counts(25, :low), do: {1276, 26}
  def get_codeword_counts(25, :medium), do: {1000, 588}
  def get_codeword_counts(25, :quartile), do: {718, 870}
  def get_codeword_counts(25, :high), do: {538, 1050}

  # Version 26
  def get_codeword_counts(26, :low), do: {1370, 28}
  def get_codeword_counts(26, :medium), do: {1062, 644}
  def get_codeword_counts(26, :quartile), do: {754, 952}
  def get_codeword_counts(26, :high), do: {596, 1110}

  # Version 27
  def get_codeword_counts(27, :low), do: {1468, 30}
  def get_codeword_counts(27, :medium), do: {1128, 700}
  def get_codeword_counts(27, :quartile), do: {808, 1020}
  def get_codeword_counts(27, :high), do: {628, 1200}

  # Version 28
  def get_codeword_counts(28, :low), do: {1531, 30}
  def get_codeword_counts(28, :medium), do: {1193, 728}
  def get_codeword_counts(28, :quartile), do: {871, 1050}
  def get_codeword_counts(28, :high), do: {661, 1260}

  # Version 29
  def get_codeword_counts(29, :low), do: {1631, 30}
  def get_codeword_counts(29, :medium), do: {1267, 784}
  def get_codeword_counts(29, :quartile), do: {911, 1140}
  def get_codeword_counts(29, :high), do: {701, 1350}

  # Version 30
  def get_codeword_counts(30, :low), do: {1735, 30}
  def get_codeword_counts(30, :medium), do: {1373, 812}
  def get_codeword_counts(30, :quartile), do: {985, 1200}
  def get_codeword_counts(30, :high), do: {745, 1440}

  # Version 31
  def get_codeword_counts(31, :low), do: {1843, 30}
  def get_codeword_counts(31, :medium), do: {1455, 868}
  def get_codeword_counts(31, :quartile), do: {1033, 1290}
  def get_codeword_counts(31, :high), do: {793, 1530}

  # Version 32
  def get_codeword_counts(32, :low), do: {1955, 30}
  def get_codeword_counts(32, :medium), do: {1541, 924}
  def get_codeword_counts(32, :quartile), do: {1115, 1350}
  def get_codeword_counts(32, :high), do: {845, 1620}

  # Version 33
  def get_codeword_counts(33, :low), do: {2071, 30}
  def get_codeword_counts(33, :medium), do: {1631, 980}
  def get_codeword_counts(33, :quartile), do: {1171, 1440}
  def get_codeword_counts(33, :high), do: {901, 1710}

  # Version 34
  def get_codeword_counts(34, :low), do: {2191, 30}
  def get_codeword_counts(34, :medium), do: {1725, 1036}
  def get_codeword_counts(34, :quartile), do: {1231, 1530}
  def get_codeword_counts(34, :high), do: {961, 1800}

  # Version 35
  def get_codeword_counts(35, :low), do: {2306, 30}
  def get_codeword_counts(35, :medium), do: {1812, 1064}
  def get_codeword_counts(35, :quartile), do: {1286, 1590}
  def get_codeword_counts(35, :high), do: {986, 1890}

  # Version 36
  def get_codeword_counts(36, :low), do: {2434, 30}
  def get_codeword_counts(36, :medium), do: {1914, 1156}
  def get_codeword_counts(36, :quartile), do: {1354, 1680}
  def get_codeword_counts(36, :high), do: {1054, 1980}

  # Version 37
  def get_codeword_counts(37, :low), do: {2566, 30}
  def get_codeword_counts(37, :medium), do: {1992, 1224}
  def get_codeword_counts(37, :quartile), do: {1426, 1770}
  def get_codeword_counts(37, :high), do: {1096, 2100}

  # Version 38
  def get_codeword_counts(38, :low), do: {2702, 30}
  def get_codeword_counts(38, :medium), do: {2102, 1286}
  def get_codeword_counts(38, :quartile), do: {1502, 1860}
  def get_codeword_counts(38, :high), do: {1142, 2220}

  # Version 39
  def get_codeword_counts(39, :low), do: {2812, 30}
  def get_codeword_counts(39, :medium), do: {2216, 1354}
  def get_codeword_counts(39, :quartile), do: {1582, 1950}
  def get_codeword_counts(39, :high), do: {1222, 2310}

  # Version 40
  def get_codeword_counts(40, :low), do: {2956, 1276}
  def get_codeword_counts(40, :medium), do: {2334, 1898}
  def get_codeword_counts(40, :quartile), do: {1666, 2566}
  def get_codeword_counts(40, :high), do: {1276, 2956}

  # Error handling for invalid inputs
  def get_codeword_counts(version, _error_correction) when version < 1 or version > 40 do
    raise ArgumentError, "Invalid QR code version: #{version}. Version must be between 1 and 40."
  end

  def get_codeword_counts(_version, error_correction)
      when error_correction not in [:low, :medium, :quartile, :high] do
    raise ArgumentError,
          "Invalid error correction level: #{error_correction}. Must be one of :low, :medium, :quartile, or :high."
  end
end
