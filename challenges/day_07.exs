#!/usr/bin/env elixir

defmodule Day7 do

  def order(available, before_after), do: order(available, before_after, [])

  def order([first | available], all, done) do
    dependent = available ++ Map.get(all, first, [])

    # filter input still in dependent items, those need to come later
    depset = MapSet.new(dependent)

    order(
      dependent |> Enum.sort |> Enum.uniq,
      all,
      [first | done |> Enum.reject(&(MapSet.member?(depset, &1)))]
    )
  end

  def order([], _, done) do
    done
    |> Enum.reverse
  end
end

input = File.stream!("day_07_input.txt")
  |> Stream.map(fn (s) ->
    String.splitter(s, [" "])
    |> Enum.to_list
    |> (fn (["Step", before_step, "must", "be", "finished", "before", "step", after_step | _can_begin]) ->
      {before_step, after_step}
    end).()
  end)
  |> Enum.to_list

before_after =
  input
  |> Enum.group_by(&(elem(&1, 0)), &(elem(&1, 1)))

first_steps = input
|> Enum.map(&Tuple.to_list/1)
|> Enum.zip
|> Enum.map(&Tuple.to_list/1)
|> (fn ([before_steps, after_steps]) ->
  Enum.reject(before_steps, fn (step) -> Enum.find(after_steps, fn (s) -> s == step end) end)
end).()
|> Enum.sort
|> Enum.uniq

Day7.order(first_steps, before_after)
|> Enum.join("")
|> IO.inspect(label: "Part One")
