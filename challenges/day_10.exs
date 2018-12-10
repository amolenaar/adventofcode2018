#! /usr/bin/env elixir

defmodule Day10 do

  def parse_pos(s) do
    s
    |> String.split(",")
    |> Enum.map(&(&1 |> String.trim() |> String.to_integer()))
    |> List.to_tuple()
  end

  def size(pos) do
    xs = pos |> Enum.map(&elem(&1, 0))
    ys = pos |> Enum.map(&elem(&1, 1))

    {(xs |> Enum.max()) - (xs |> Enum.min()), (ys |> Enum.max()) - (ys |> Enum.min())}
  end

  def distance(pos) do
    {x, y} = size(pos)
    abs(x) + abs(y)
  end

  def print(pos) do
    pos = MapSet.new(pos)
    xs = pos |> Enum.map(&elem(&1, 0))
    ys = pos |> Enum.map(&elem(&1, 1))

    for y <- (ys |> Enum.min())..(ys |> Enum.max()) do
      for x <- (xs |> Enum.min())..(xs |> Enum.max()) do
        if MapSet.member?(pos, {x, y}) do
          "#"
        else
          "."
        end
        |> IO.write()
      end

      IO.puts("")
    end
  end

  def only_pos(pos_to_v) do
    pos_to_v |> Enum.map(&elem(&1, 0))
  end

  def let_time_pass(pos_to_v, previous_length \\ 1_000_000, second \\ 0) do
    new_pos_to_v =
      for {{px, py}, {vx, vy} = v} <- pos_to_v do
        {{px + vx, py + vy}, v}
      end

    new_length = new_pos_to_v |> only_pos() |> distance()

    if new_length > previous_length do
      {pos_to_v |> only_pos(), second}
    else
      let_time_pass(new_pos_to_v, new_length, second + 1)
    end
  end
end

input =
  File.stream!("day_10_input.txt")
  |> Enum.map(fn s ->
    s
    |> String.splitter(["<", ">"])
    |> Enum.to_list()
    |> (fn [_, pos, _, v | _] ->
          pos = pos |> Day10.parse_pos()
          v = v |> Day10.parse_pos()
          {pos, v}
        end).()
  end)

{pos, second} =
  input
  |> Day10.let_time_pass()

IO.puts("Part One:")
Day10.print(pos)

IO.puts("Part 2: #{second}")
