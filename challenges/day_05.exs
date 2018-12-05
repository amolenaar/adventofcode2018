#!/usr/bin/env elixir

defmodule Day5 do
  def react(chain),
    do: react(chain, {false, []})

  def react([a, b | rest], {_again, acc}) when a - b == 32 or b - a == 32,
    do: react(rest, {true, acc})
  def react([a | rest], {again, acc}),
    do: react(rest, {again, [a | acc]})
  def react([], {true, acc}),
    do: react(acc)
  def react([], {false, acc}),
    do: acc

end

input = File.read!("day_05_input.txt")
|> String.to_charlist()

# How many units remain after fully reacting the polymer you scanned?
input
|> Day5.react
|> Enum.count
|> IO.inspect(label: "Part One")

# What is the length of the shortest polymer you can produce by removing
# all units of exactly one type and fully reacting the result?
for unit <- ?A..?Z do
  input
  |> Enum.reject(&(&1 == unit or &1 == unit + 32))
  |> Day5.react
  |> Enum.count
end
|> Enum.min
|> IO.inspect(label: "Part Two")

