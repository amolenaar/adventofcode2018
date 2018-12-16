#!/usr/bin/env elixir

defmodule Day12 do

  @test_set_initial_state '#..#.#..##......###...###'
  @test_set_spread  %{'...##' => ?#,
                      '..#..' => ?#,
                      '.#...' => ?#,
                      '.#.#.' => ?#,
                      '.#.##' => ?#,
                      '.##..' => ?#,
                      '.####' => ?#,
                      '#.#.#' => ?#,
                      '#.###' => ?#,
                      '##.#.' => ?#,
                      '##.##' => ?#,
                      '###..' => ?#,
                      '###.#' => ?#,
                      '####.' => ?#}

  @puzzle_initial_state '#.##.##.##.##.......###..####..#....#...#.##...##.#.####...#..##..###...##.#..#.##.#.#.#.#..####..#'
  @puzzle_spread  %{'..###' => ?.,
                    '##..#' => ?#,
                    '#..##' => ?.,
                    '.#..#' => ?.,
                    '#.##.' => ?.,
                    '#....' => ?.,
                    '##...' => ?#,
                    '#...#' => ?.,
                    '###.#' => ?#,
                    '##.##' => ?.,
                    '....#' => ?.,
                    '..##.' => ?#,
                    '..#..' => ?.,
                    '##.#.' => ?.,
                    '.##.#' => ?#,
                    '#..#.' => ?#,
                    '.##..' => ?#,
                    '###..' => ?#,
                    '.###.' => ?#,
                    '#####' => ?#,
                    '####.' => ?.,
                    '.#.#.' => ?.,
                    '...#.' => ?#,
                    '#.###' => ?.,
                    '.#...' => ?#,
                    '.####' => ?.,
                    '#.#.#' => ?#,
                    '...##' => ?.,
                    '.....' => ?.,
                    '.#.##' => ?#,
                    '..#.#' => ?#,
                    '#.#..' => ?#}

  def test_run() do
      run({0, @test_set_initial_state}, @test_set_spread, 20, [])
  end

  def puzzle_run(generations) do
    run({0, @puzzle_initial_state}, @puzzle_spread, generations, [])
  end

  def run(_state, _spread, 0, acc) do
    state = hd(acc) |> IO.inspect
    |> summize()
  end

  def run(state, spread, i, acc) do
    new_state = generation(state, spread)
    # (summize(new_state) - summize(state)) |> IO.inspect

    run(new_state, spread, i - 1, [new_state | acc])
  end

  def generation({start_pos, state}, spread) do
    # Expand to accomodate for new state
    case update([?., ?., ?., ?. | state], spread, []) do
      [?., ?., ?. | rest] -> {start_pos + 1, rest}
      [?., ?. | rest]     -> {start_pos, rest}
      [?. | rest]         -> {start_pos - 1, rest}
      rest                -> {start_pos - 2, rest}
    end
  end

  def update([s1, s2, s3, s4, s5 | _rest]=gen, spread, next_gen) do
    update(tl(gen), spread,
      [Map.get(spread, [s1, s2, s3, s4, s5], ?.) | next_gen])
  end

  def update([s1, s2, s3, s4]=gen, spread, next_gen) do
    update(tl(gen), spread,
      [Map.get(spread, [s1, s2, s3, s4, ?. ], ?.) | next_gen])
  end

  def update([s1, s2, s3]=gen, spread, next_gen) do
    update(tl(gen), spread,
      [Map.get(spread, [s1, s2, s3, ?., ?. ], ?.) | next_gen])
  end

  def update([s1, s2]=gen, spread, next_gen) do
    update(tl(gen), spread,
      [Map.get(spread, [s1, s2, ?., ?., ?. ], ?.) | next_gen])
  end

  def update([s1]=gen, spread, next_gen) do
    update(tl(gen), spread,
      [Map.get(spread, [s1, ?., ?., ?., ?. ], ?.) | next_gen])
  end

  def update([], _spread, next_gen) do
    next_gen
    |> Enum.drop_while(fn p -> p == ?. end)
    |> Enum.reverse()
  end

  def summize({start_pos, spread}) do
    Enum.with_index(spread)
    |> Enum.map(fn
      {?#, i} -> i + start_pos
      {?., _} -> 0
    end)
    |> Enum.sum
  end
end


Day12.test_run()
|> IO.inspect(label: "Test data")

Day12.puzzle_run(20)
|> IO.inspect(label: "Part One")

puzzle_magic_number = 69 # this is what shows up after a couple hundred iterations
Day12.puzzle_run(200) + (50_000_000_000 - 200) * puzzle_magic_number
|> IO.inspect(label: "Part Two")
