#!/usr/bin/env elixir

defmodule Day7 do

  def prerequisite(steps, prereqs), do: prerequisite(steps, prereqs, [])

  def prerequisite(steps, [{before_step, after_step} | rest], done ) do
    index_before_step = Enum.find_index(steps, fn (e) -> e == before_step end)
    index_after_step = Enum.find_index(steps, fn (e) -> e == after_step end)
    if index_before_step > index_after_step do
      not_after = done
      |> Enum.filter(fn ({b, _a}) -> b == after_step end)
      |> Enum.map(&(elem(&1, 1)))
      |> MapSet.new
      new_steps = steps
      |> insert_alphabetically(index_before_step + 1, after_step, not_after)
      |> List.replace_at(index_after_step, "")
      prerequisite(new_steps, rest, [{before_step, after_step} | done])
    else
      prerequisite(steps, rest, [{before_step, after_step} | done])
    end
  end

  def prerequisite(steps, [], _) do
    steps
  end

  def insert_alphabetically(steps, index, step, not_after) do
    s = Enum.at(steps, index)
    cond do
      s == nil ->
        steps ++ [step]
      MapSet.member?(not_after, s) ->
        List.insert_at(steps, index, step)
      s < step ->
        insert_alphabetically(steps, index + 1, step, not_after)
      true ->
        List.insert_at(steps, index, step)
    end
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

all_steps =
  input
  |> Enum.map(&Tuple.to_list/1)
  |> List.flatten
  |> Enum.uniq
  |> Enum.sort
  |> IO.inspect(label: "All steps")

Day7.prerequisite(all_steps, input)
|> Day7.prerequisite(input)
|> Enum.join("")
|> IO.inspect(label: "Part One")


# first_steps
# |> Enum.map(&Day7.construct_next_step(&1, input))
# |> List.flatten
# |> Enum.uniq
# |> Enum.reverse
# |> Enum.join("")
# |> IO.inspect(label: "Part One")

#  -->A--->F--
# /    \      \
# C      -->D----->E
# \           /
#  ---->B-----
# CABDFE
