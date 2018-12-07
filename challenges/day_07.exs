#!/usr/bin/env elixir

defmodule Day7 do
  def construct_previous_step(step, steps) do
    before = steps
    |> Enum.filter(fn ({b, a}) -> a == step end)
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.sort(&(&1 >= &2))
    |> Enum.map(&(construct_previous_step(&1, steps)))
    [step, before]
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

first_steps = input
|> Enum.map(&Tuple.to_list/1)
|> Enum.zip
|> Enum.map(&Tuple.to_list/1)
|> (fn ([before_steps, after_steps]) ->
  Enum.reject(before_steps, fn (step) -> Enum.find(after_steps, fn (s) -> s == step end) end)
end).()
|> Enum.sort
|> Enum.uniq
|> IO.inspect(label: "First steps")

last_steps = input
|> Enum.map(&Tuple.to_list/1)
|> Enum.zip
|> Enum.map(&Tuple.to_list/1)
|> (fn ([before_steps, after_steps]) ->
  Enum.reject(after_steps, fn (step) -> Enum.find(before_steps, fn (s) -> s == step end) end)
end).()
|> Enum.sort
|> Enum.uniq

last_steps
|> Enum.map(&(Day7.construct_previous_step(&1, input)))
|> List.flatten()
|> Enum.reverse
|> Enum.uniq
|> Enum.join("")
|> IO.inspect(label: "Part One")
