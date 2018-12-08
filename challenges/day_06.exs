#! /usr/bin/env elixir

input =
  File.stream!("day_06_input.txt")
  |> Stream.map(fn s ->
    String.splitter(s, [" ", ",", "\n"])
    |> Enum.to_list()
    |> (fn [x, _, y | _] ->
          x = String.to_integer(x)
          y = String.to_integer(y)
          [x, y]
        end).()
  end)
  |> Enum.to_list()

[x_min, y_min] =
  input
  |> Enum.zip()
  |> Enum.map(&Tuple.to_list/1)
  |> Enum.map(&Enum.min/1)

[x_max, y_max] =
  input
  |> Enum.zip()
  |> Enum.map(&Tuple.to_list/1)
  |> Enum.map(&Enum.max/1)

point_and_closest_coordinate =
  for x <- x_min..x_max,
      y <- y_min..y_max,
      [cx, cy] <- input do
    [{x, y}, abs(x - cx) + abs(y - cy), {cx, cy}]
  end
  |> Enum.group_by(&hd/1, &tl/1)
  |> Enum.map(fn {pos, dist_coord} ->
    {pos, dist_coord |> Enum.sort()}
  end)
  # filter equally far
  |> Enum.filter(fn
    {_pos, [[d, _], [d, _] | _]} -> false
    _ -> true
  end)
  |> Enum.map(fn {p, dist_coord} ->
    coord =
      dist_coord
      |> hd()
      |> Enum.at(1)

    {p, coord}
  end)

infinite_coordinates =
  point_and_closest_coordinate
  |> Enum.filter(fn {{x, y}, _coord} ->
    x == x_min or x == x_max or y == y_min or y == y_max
  end)
  |> MapSet.new(fn {_xy, coord} -> coord end)

point_and_closest_coordinate
|> Enum.group_by(fn {_, coord} -> coord end)
|> Enum.reject(fn {coord, _} -> MapSet.member?(infinite_coordinates, coord) end)
|> Enum.map(fn {_coord, points} ->
  points |> Enum.count()
end)
|> Enum.max()
|> IO.inspect(label: "Part One")

for x <- x_min..x_max,
    y <- y_min..y_max,
    [cx, cy] <- input do
  {{x, y}, abs(x - cx) + abs(y - cy)}
end
|> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
|> Enum.filter(fn {_xy, dists} -> Enum.sum(dists) < 10_000 end)
|> Enum.count()
|> IO.inspect(label: "Part Two")
