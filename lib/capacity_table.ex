defmodule QRlixer.CapacityTable do
  @moduledoc """
  Provides capacity information for all QR code versions (1-40) and error correction levels.
  """

  @doc """
  Returns the capacity for a given version and error correction level.
  The returned tuple contains (numeric, alphanumeric, byte) capacities.

  ## Parameters

    - version: Integer from 1 to 40
    - error_correction: Atom, one of [:low, :medium, :quartile, :high]

  ## Returns

    A tuple {numeric_capacity, alphanumeric_capacity, byte_capacity}

  ## Raises

    ArgumentError if an invalid version or error correction level is provided
  """
  @spec get_capacity(integer, atom) :: {integer, integer, integer}
  def get_capacity(version, error_correction)

  def get_capacity(1, :low), do: {41, 25, 17}
  def get_capacity(1, :medium), do: {34, 20, 14}
  def get_capacity(1, :quartile), do: {27, 16, 11}
  def get_capacity(1, :high), do: {17, 10, 7}

  def get_capacity(2, :low), do: {77, 47, 32}
  def get_capacity(2, :medium), do: {63, 38, 26}
  def get_capacity(2, :quartile), do: {48, 29, 20}
  def get_capacity(2, :high), do: {34, 20, 14}

  def get_capacity(3, :low), do: {127, 77, 53}
  def get_capacity(3, :medium), do: {101, 61, 42}
  def get_capacity(3, :quartile), do: {77, 47, 32}
  def get_capacity(3, :high), do: {58, 35, 24}

  def get_capacity(4, :low), do: {187, 114, 78}
  def get_capacity(4, :medium), do: {149, 90, 62}
  def get_capacity(4, :quartile), do: {111, 67, 46}
  def get_capacity(4, :high), do: {82, 50, 34}

  def get_capacity(5, :low), do: {255, 154, 106}
  def get_capacity(5, :medium), do: {202, 122, 84}
  def get_capacity(5, :quartile), do: {144, 87, 60}
  def get_capacity(5, :high), do: {106, 64, 44}

  def get_capacity(6, :low), do: {322, 195, 134}
  def get_capacity(6, :medium), do: {255, 154, 106}
  def get_capacity(6, :quartile), do: {178, 108, 74}
  def get_capacity(6, :high), do: {139, 84, 58}

  def get_capacity(7, :low), do: {370, 224, 154}
  def get_capacity(7, :medium), do: {293, 178, 122}
  def get_capacity(7, :quartile), do: {207, 125, 86}
  def get_capacity(7, :high), do: {154, 93, 64}

  def get_capacity(8, :low), do: {461, 279, 192}
  def get_capacity(8, :medium), do: {365, 221, 152}
  def get_capacity(8, :quartile), do: {259, 157, 108}
  def get_capacity(8, :high), do: {202, 122, 84}

  def get_capacity(9, :low), do: {552, 335, 230}
  def get_capacity(9, :medium), do: {432, 262, 180}
  def get_capacity(9, :quartile), do: {312, 189, 130}
  def get_capacity(9, :high), do: {235, 143, 98}

  def get_capacity(10, :low), do: {652, 395, 271}
  def get_capacity(10, :medium), do: {513, 311, 213}
  def get_capacity(10, :quartile), do: {364, 221, 151}
  def get_capacity(10, :high), do: {288, 174, 119}

  def get_capacity(11, :low), do: {772, 468, 321}
  def get_capacity(11, :medium), do: {604, 366, 251}
  def get_capacity(11, :quartile), do: {427, 259, 177}
  def get_capacity(11, :high), do: {331, 200, 137}

  def get_capacity(12, :low), do: {883, 535, 367}
  def get_capacity(12, :medium), do: {691, 419, 287}
  def get_capacity(12, :quartile), do: {489, 296, 203}
  def get_capacity(12, :high), do: {374, 227, 155}

  def get_capacity(13, :low), do: {1022, 619, 425}
  def get_capacity(13, :medium), do: {796, 483, 331}
  def get_capacity(13, :quartile), do: {580, 352, 241}
  def get_capacity(13, :high), do: {427, 259, 177}

  def get_capacity(14, :low), do: {1101, 667, 458}
  def get_capacity(14, :medium), do: {871, 528, 362}
  def get_capacity(14, :quartile), do: {621, 376, 258}
  def get_capacity(14, :high), do: {468, 283, 194}

  def get_capacity(15, :low), do: {1250, 758, 520}
  def get_capacity(15, :medium), do: {991, 600, 412}
  def get_capacity(15, :quartile), do: {703, 426, 292}
  def get_capacity(15, :high), do: {530, 321, 220}

  def get_capacity(16, :low), do: {1408, 854, 586}
  def get_capacity(16, :medium), do: {1082, 656, 450}
  def get_capacity(16, :quartile), do: {775, 470, 322}
  def get_capacity(16, :high), do: {602, 365, 250}

  def get_capacity(17, :low), do: {1548, 938, 644}
  def get_capacity(17, :medium), do: {1212, 734, 504}
  def get_capacity(17, :quartile), do: {876, 531, 364}
  def get_capacity(17, :high), do: {674, 408, 280}

  def get_capacity(18, :low), do: {1725, 1046, 718}
  def get_capacity(18, :medium), do: {1346, 816, 560}
  def get_capacity(18, :quartile), do: {948, 574, 394}
  def get_capacity(18, :high), do: {746, 452, 310}

  def get_capacity(19, :low), do: {1903, 1153, 792}
  def get_capacity(19, :medium), do: {1500, 909, 624}
  def get_capacity(19, :quartile), do: {1063, 644, 442}
  def get_capacity(19, :high), do: {813, 493, 338}

  def get_capacity(20, :low), do: {2061, 1249, 858}
  def get_capacity(20, :medium), do: {1600, 970, 666}
  def get_capacity(20, :quartile), do: {1159, 702, 482}
  def get_capacity(20, :high), do: {919, 557, 382}

  def get_capacity(21, :low), do: {2232, 1352, 929}
  def get_capacity(21, :medium), do: {1708, 1035, 711}
  def get_capacity(21, :quartile), do: {1224, 742, 509}
  def get_capacity(21, :high), do: {969, 587, 403}

  def get_capacity(22, :low), do: {2409, 1460, 1003}
  def get_capacity(22, :medium), do: {1872, 1134, 779}
  def get_capacity(22, :quartile), do: {1358, 823, 565}
  def get_capacity(22, :high), do: {1056, 640, 439}

  def get_capacity(23, :low), do: {2620, 1588, 1091}
  def get_capacity(23, :medium), do: {2059, 1248, 857}
  def get_capacity(23, :quartile), do: {1468, 890, 611}
  def get_capacity(23, :high), do: {1108, 672, 461}

  def get_capacity(24, :low), do: {2812, 1704, 1171}
  def get_capacity(24, :medium), do: {2188, 1326, 911}
  def get_capacity(24, :quartile), do: {1588, 963, 661}
  def get_capacity(24, :high), do: {1228, 744, 511}

  def get_capacity(25, :low), do: {3057, 1853, 1273}
  def get_capacity(25, :medium), do: {2395, 1451, 997}
  def get_capacity(25, :quartile), do: {1718, 1041, 715}
  def get_capacity(25, :high), do: {1286, 779, 535}

  def get_capacity(26, :low), do: {3283, 1990, 1367}
  def get_capacity(26, :medium), do: {2544, 1542, 1059}
  def get_capacity(26, :quartile), do: {1804, 1094, 751}
  def get_capacity(26, :high), do: {1425, 864, 593}

  def get_capacity(27, :low), do: {3517, 2132, 1465}
  def get_capacity(27, :medium), do: {2701, 1637, 1125}
  def get_capacity(27, :quartile), do: {1933, 1172, 805}
  def get_capacity(27, :high), do: {1501, 910, 625}

  def get_capacity(28, :low), do: {3669, 2223, 1528}
  def get_capacity(28, :medium), do: {2857, 1732, 1190}
  def get_capacity(28, :quartile), do: {2085, 1263, 868}
  def get_capacity(28, :high), do: {1581, 958, 658}

  def get_capacity(29, :low), do: {3909, 2369, 1628}
  def get_capacity(29, :medium), do: {3035, 1839, 1264}
  def get_capacity(29, :quartile), do: {2181, 1322, 908}
  def get_capacity(29, :high), do: {1677, 1016, 698}

  def get_capacity(30, :low), do: {4158, 2520, 1732}
  def get_capacity(30, :medium), do: {3289, 1994, 1370}
  def get_capacity(30, :quartile), do: {2358, 1429, 982}
  def get_capacity(30, :high), do: {1782, 1080, 742}

  def get_capacity(31, :low), do: {4417, 2677, 1840}
  def get_capacity(31, :medium), do: {3486, 2113, 1452}
  def get_capacity(31, :quartile), do: {2473, 1499, 1030}
  def get_capacity(31, :high), do: {1897, 1150, 790}

  def get_capacity(32, :low), do: {4686, 2840, 1952}
  def get_capacity(32, :medium), do: {3693, 2238, 1538}
  def get_capacity(32, :quartile), do: {2670, 1618, 1112}
  def get_capacity(32, :high), do: {2022, 1226, 842}

  def get_capacity(33, :low), do: {4965, 3009, 2068}
  def get_capacity(33, :medium), do: {3909, 2369, 1628}
  def get_capacity(33, :quartile), do: {2805, 1700, 1168}
  def get_capacity(33, :high), do: {2157, 1307, 898}

  def get_capacity(34, :low), do: {5253, 3183, 2188}
  def get_capacity(34, :medium), do: {4134, 2506, 1722}
  def get_capacity(34, :quartile), do: {2949, 1787, 1228}
  def get_capacity(34, :high), do: {2301, 1394, 958}

  def get_capacity(35, :low), do: {5529, 3351, 2303}
  def get_capacity(35, :medium), do: {4343, 2632, 1809}
  def get_capacity(35, :quartile), do: {3081, 1867, 1283}
  def get_capacity(35, :high), do: {2361, 1431, 983}

  def get_capacity(36, :low), do: {5836, 3537, 2431}
  def get_capacity(36, :medium), do: {4588, 2780, 1911}
  def get_capacity(36, :quartile), do: {3244, 1966, 1351}
  def get_capacity(36, :high), do: {2524, 1530, 1051}

  def get_capacity(37, :low), do: {6153, 3729, 2563}
  def get_capacity(37, :medium), do: {4775, 2894, 1989}
  def get_capacity(37, :quartile), do: {3417, 2071, 1423}
  def get_capacity(37, :high), do: {2625, 1591, 1093}

  def get_capacity(38, :low), do: {6479, 3927, 2699}
  def get_capacity(38, :medium), do: {5039, 3054, 2099}
  def get_capacity(38, :quartile), do: {3599, 2181, 1499}
  def get_capacity(38, :high), do: {2735, 1658, 1139}

  def get_capacity(39, :low), do: {6743, 4087, 2809}
  def get_capacity(39, :medium), do: {5313, 3220, 2213}
  def get_capacity(39, :quartile), do: {3791, 2298, 1579}
  def get_capacity(39, :high), do: {2927, 1774, 1219}

  def get_capacity(40, :low), do: {7089, 4296, 2953}
  def get_capacity(40, :medium), do: {5596, 3391, 2331}
  def get_capacity(40, :quartile), do: {3993, 2420, 1663}
  def get_capacity(40, :high), do: {3057, 1852, 1273}

  def get_capacity(version, _error_correction) when version < 1 or version > 40 do
    raise ArgumentError, "Invalid QR code version: #{version}. Version must be between 1 and 40."
  end

  def get_capacity(_version, error_correction)
      when error_correction not in [:low, :medium, :quartile, :high] do
    raise ArgumentError,
          "Invalid error correction level: #{error_correction}. Must be one of :low, :medium, :quartile, or :high."
  end
end
