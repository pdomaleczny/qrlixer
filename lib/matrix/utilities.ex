defmodule QRlixer.Utilities do
  @moduledoc """
  Provides utility functions used across various modules in the QRlixer library.

  This module contains helper functions that are not specific to any particular
  aspect of QR code generation but are used in multiple places throughout the library.
  It includes functions for mathematical operations, matrix creation, and other
  general-purpose utilities.
  """

  def combination([], _), do: []
  def combination(_, 0), do: [[]]

  def combination([h | t], m) do
    for(l <- combination(t, m - 1), do: [h | l]) ++ combination(t, m)
  end

  def create_empty_matrix(size) do
    for _ <- 1..size, do: for(_ <- 1..size, do: nil)
  end
end
