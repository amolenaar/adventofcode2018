#!/usr/bin/env elixir

input = File.stream!("day_02_input.txt")
|> Stream.map(&String.trim/1)


input
|> Stream.map(&String.to_charlist/1)
|> Stream.map(fn c ->
  Enum.group_by(c, fn x -> x end, fn _ -> 1 end)
  |> Stream.map(fn {_k, v} -> Enum.count(v) end)
  |> Enum.reduce({0, 0}, fn
    (2, {_, c3}) -> {1, c3}
    (3, {c2, _}) -> {c2, 1}
    (_, acc) -> acc
  end)
end)
|> Enum.reduce({0, 0}, fn ({a1, a2}, {b1, b2}) -> {a1 + b1, a2 + b2} end)
|> (fn {a, b} -> a * b end).()
|> IO.inspect(label: "Part One")


input
|> Stream.flat_map(fn (c) -> input |> Enum.map(&({c, &1})) end)
|> Stream.map(fn {a, b} -> String.myers_difference(a, b) end)
|> Enum.filter(fn
  # Find the lines where the difference is only one character
  [eq: _, del: <<_>>, ins: <<_>>, eq: _] -> true
  [eq: _, del: <<_>>, ins: <<_>>] -> true
  [del: <<_>>, ins: <<_>>, eq: _] -> true
  _ -> false
end)
|> hd()
|> (fn [eq: s1, del: _, ins: _, eq: s2] -> s1 <> s2 end).()
|> IO.inspect(label: "Part Two")
