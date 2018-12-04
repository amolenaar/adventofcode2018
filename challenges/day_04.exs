#!/usr/bin/env elixir

defmodule Day4 do
  def calculate_answer(id, sleep_per_minute) do
    sleep_per_minute
    |> Map.get(id)
    |> Enum.max_by(fn {_minute, n} -> n end)
    |> (fn {minute, _n} ->
      minute * (id |> String.trim_leading("#") |> String.to_integer())
    end).()
  end

  def determine_guard_id(sleep_per_minute, fun) do
    {_, id} = sleep_per_minute
    |> Enum.map(fn {id, time_map} ->
      {Map.values(time_map)
      |> fun.(), id}
    end)
    |> Enum.sort()
    |> Enum.reverse()
    |> hd()
    id
  end
end

# Build a map %{id => %{minute => times_asleep, ..}}
# The parser ensures that all sleep/wake actions happen
# in the first hour, thanks to pattern matching :)
{_, _, input} = File.stream!("day_04_input.txt")
|> Enum.to_list()
|> Enum.sort()
|> Enum.map(fn (s) ->
  String.splitter(s, [" ", "[", ":", "]", "#", "\n"])
  |> Enum.to_list()
  |> (fn
    ([_, _date, _hour, _minute, _, "Guard", _, id, "begins", "shift" | _]) ->
      {:shift, id}
    ([_, _date, "00", minute, _, "falls", "asleep" | _]) ->
      {:asleep, String.to_integer(minute)}
    ([_, _date, "00", minute, _, "wakes", "up" | _]) ->
      { :awake, String.to_integer(minute)}
  end).()
end)
|> Enum.reduce({nil, nil, %{}}, fn
  ({:shift, id}, {_id, nil, map}) ->
    {id, nil, Map.put_new(map, id, %{0 => 0})}
  ({:asleep, sleep_time}, {id, nil, map}) ->
    {id, sleep_time, map}
  ({:awake, awake_time}, {id, sleep_time, map}) ->
    time_map = map[id]
    new_time_map = Range.new(sleep_time, awake_time - 1)
    |> Enum.reduce(time_map, fn (time, map) -> Map.update(map, time, 0, fn a -> a + 1 end) end)
    {id, nil, Map.put(map, id, new_time_map)}
end)


Day4.determine_guard_id(input, &Enum.sum/1)
|> Day4.calculate_answer(input)
|> IO.inspect(label: "Part One")


Day4.determine_guard_id(input, &Enum.max/1)
|> Day4.calculate_answer(input)
|> IO.inspect(label: "Part Two")
