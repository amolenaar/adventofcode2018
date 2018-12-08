#! /usr/bin/env elixir

defmodule Day7Part1 do
  def order(available, step_prereq), do: order(available, step_prereq, [])

  def order([first | available], all, done) do
    done = [first | done]
    done_set = MapSet.new(done)

    newly_available =
      all
      |> Enum.filter(fn {_step, prereq} ->
        MapSet.subset?(MapSet.new(prereq), MapSet.new(done))
      end)
      |> Enum.map(&elem(&1, 0))
      |> Enum.reject(&MapSet.member?(done_set, &1))

    available =
      (available ++ newly_available)
      |> Enum.sort()
      |> Enum.uniq()

    order(available, all, done)
  end

  def order([], _, done) do
    done
    |> Enum.reverse()
  end
end

defmodule Day7Part2 do
  @workers 5
  @time 60
  @free_worker {0, :free}

  def next_task([{step, prereq} | rest], done, in_progress) do
    if !MapSet.member?(done, step) and MapSet.subset?(prereq, done) and
         !MapSet.member?(in_progress, step) do
      {(step |> String.to_charlist() |> hd()) - ?A + @time, step}
    else
      next_task(rest, done, in_progress)
    end
  end

  def next_task([], _done, _in_progress) do
    :no_work
  end

  def assign_new_work([worker | rest], step_prereq, done, new_workers) do
    case worker do
      @free_worker ->
        in_progress = (rest ++ new_workers) |> Enum.map(&elem(&1, 1)) |> MapSet.new()

        case next_task(step_prereq, done, in_progress) do
          :no_work -> assign_new_work(rest, step_prereq, done, [@free_worker | new_workers])
          worker -> assign_new_work(rest, step_prereq, done, [worker | new_workers])
        end

      worker ->
        assign_new_work(rest, step_prereq, done, [worker | new_workers])
    end
  end

  def assign_new_work([], _step_prereq, _done, new_workers) do
    new_workers |> Enum.reverse()
  end

  def update_workers([worker | rest], step_prereq, done, new_workers) do
    case worker do
      {time, step} when time > 0 ->
        update_workers(rest, step_prereq, done, [{time - 1, step} | new_workers])

      @free_worker ->
        update_workers(rest, step_prereq, done, [@free_worker | new_workers])

      {0, step} ->
        done = MapSet.put(done, step)
        update_workers(rest, step_prereq, done, [@free_worker | new_workers])
    end
  end

  def update_workers([], _step_prereq, done, new_workers) do
    {new_workers |> Enum.reverse(), done}
  end

  def no_one_working(workers), do: workers |> Enum.reject(&(&1 == @free_worker)) == []

  def work(step_prereq) do
    workers = for _ <- 1..@workers, do: @free_worker
    work(step_prereq, workers, 0, MapSet.new([]))
  end

  def work(step_prereq, workers, second, done) do
    {workers, done} = update_workers(workers, step_prereq, done, [])
    workers = assign_new_work(workers, step_prereq, done, [])
    # workers |> IO.inspect(charlists: :as_lists, label: "#{second+1}: ")
    if no_one_working(workers) do
      second
    else
      work(step_prereq, workers, second + 1, done)
    end
  end
end

input =
  File.stream!("day_07_input.txt")
  |> Stream.map(fn s ->
    String.splitter(s, [" "])
    |> Enum.to_list()
    |> (fn [
             "Step",
             before_step,
             "must",
             "be",
             "finished",
             "before",
             "step",
             after_step | _can_begin
           ] ->
          {before_step, after_step}
        end).()
  end)
  |> Enum.to_list()

step_prereq =
  input
  |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))
  |> Enum.map(fn {step, prereq} -> {step, MapSet.new(prereq)} end)
  |> Enum.sort()

first_steps =
  input
  |> Enum.map(&Tuple.to_list/1)
  |> Enum.zip()
  |> Enum.map(&Tuple.to_list/1)
  |> (fn [before_steps, after_steps] ->
        Enum.reject(before_steps, fn step -> Enum.find(after_steps, fn s -> s == step end) end)
      end).()
  |> Enum.sort()
  |> Enum.uniq()

Day7Part1.order(first_steps, step_prereq)
|> Enum.join("")
|> IO.inspect(label: "Part One")

((first_steps |> Enum.map(fn e -> {e, MapSet.new()} end)) ++ step_prereq)
|> Enum.sort()
|> Day7Part2.work()
|> IO.inspect(label: "Part Two")
