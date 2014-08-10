defmodule Exmongo.ObjectId do
  def objectid_to_string(field) do
    Dict.update(field, :_id, nil, fn({bin}) -> binary_to_hex_list(bin) end)
  end
    
  defp binary_to_hex_list(str) do
    :binary.bin_to_list(str)
    |> list_to_hex
  end
  
  defp list_to_hex([]) do
    []
  end

  defp list_to_hex([head|tail]) do
    to_hex_str(head) ++ list_to_hex(tail)
  end

  defp to_hex_str(n) when n < 256 do
    [to_hex(div(n, 16)), to_hex(rem(n, 16))]
  end

  defp to_hex(i) when i < 10 do
    0 + i + 48
  end

  defp to_hex(i) when i >= 10 and i < 16 do
    ?a + (i - 10)
  end
end