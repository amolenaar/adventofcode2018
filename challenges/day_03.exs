#! /usr/bin/env elixir

input =
  File.stream!("day_03_input.txt")
  |> Stream.map(fn s ->
    String.splitter(s, [" ", ",", ":", "x", "\n"])
    |> Enum.to_list()
  end)
  |> Stream.map(fn [id, _, x, y, _, w, h | _] ->
    x = String.to_integer(x)
    y = String.to_integer(y)
    w = String.to_integer(w)
    h = String.to_integer(h)
    {x, y, w, h, id}
  end)
  |> Enum.flat_map(fn {x, y, w, h, id} ->
    for a <- Range.new(x, x + w - 1),
        b <- Range.new(y, y + h - 1) do
      {{a, b}, id}
    end
  end)

input
|> Enum.reduce(%{}, fn {coord, _id}, acc ->
  Map.put(acc, coord, Map.get(acc, coord, 0) + 1)
end)
|> Enum.filter(fn {_coord, n} -> n != 1 end)
|> Enum.count()
|> IO.inspect(label: "Part One")

ids =
  input
  |> Enum.map(fn {coord, id} -> id end)

overlapping_ids =
  input
  |> Enum.reduce(%{}, fn {coord, id}, acc ->
    Map.put(acc, coord, [id | Map.get(acc, coord, [])])
  end)
  |> Enum.flat_map(fn
    {_coord, [_]} -> []
    {_coord, ids} -> ids
  end)

MapSet.difference(MapSet.new(ids), MapSet.new(overlapping_ids))
|> Enum.to_list()
|> IO.inspect(label: "Part Two")
