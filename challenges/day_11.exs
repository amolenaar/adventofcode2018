#!/usr/bin/env elixir

defmodule Day11 do

  def power_level({x, y}, grid_serial) do
    rack_id = x + 10
    power_level = rack_id * y
    power_level = power_level + grid_serial
    power_level = power_level * rack_id
    power_level = power_level |> Integer.floor_div(100) |> Integer.mod(10)
    power_level - 5
  end

  def power_grid(grid_serial) do
    for x <- 1..300,
        y <- 1..300 do
      {{x, y}, power_level({x, y}, grid_serial)}
    end
    |> Map.new
  end

  def total_power(grid, {x, y}, size) do
    for ix <- 0..(size - 1),
        iy <- 0..(size - 1) do
      Map.get(grid, {x + ix, y + iy})
    end
    |> Enum.sum()
  end

  def largest_total_power(grid, size \\ 3) do
    for x <- 1..(300 - size),
        y <- 1..(300 - size) do
      {{x, y}, total_power(grid, {x, y}, size), size}
    end
    |> Enum.max_by(fn {_, p, _} -> p end)
  end

  def largest_total_power_for_any_size(grid) do
    for size <- 1..298 do
      largest_total_power(grid, size)
    end
    |> Enum.max_by(fn {_, p, _} -> p end)
  end
end

4 = Day11.power_level({3, 5}, 8)
-5 = Day11.power_level({122, 79}, 57)
0 = Day11.power_level({217, 196}, 39)
4 = Day11.power_level({101, 153}, 71)

{{33, 45}, 29, 3} = Day11.power_grid(18) |> Day11.largest_total_power()
{{21, 61}, 30, 3} = Day11.power_grid(42) |> Day11.largest_total_power()

grid = Day11.power_grid(5235)

grid
|> Day11.largest_total_power()
|> IO.inspect(label: "Part One")

grid
|> Day11.largest_total_power_for_any_size()
|> IO.inspect(label: "Part Two")
