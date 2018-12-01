#!/usr/bin/env elixir

input = File.stream!("day_01_input.txt")
|> Enum.map(&String.trim/1)
|> Enum.map(&String.to_integer/1)

input
|> Enum.sum
|> IO.inspect(label: "Part One")

Stream.cycle(input)
|> Enum.reduce_while({0, MapSet.new}, fn(change, {old_freq, seen}) ->
  freq = old_freq + change
  case MapSet.member?(seen, freq) do
    true -> {:halt, freq}
    _    -> {:cont, {freq, MapSet.put(seen, freq)}}
  end
end)
|> IO.inspect(label: "Part Two")
