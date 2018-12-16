#!/usr/bin/env elixir

defmodule Day13 do

  def carts(input) do
    input
    |> Enum.reduce([], fn
      ({pos, ?>}, acc) -> [{pos, :right, :turn_left} | acc]
      ({pos, ?<}, acc) -> [{pos, :left, :turn_left} | acc]
      ({pos, ?^}, acc) -> [{pos, :up, :turn_left} | acc]
      ({pos, ?v}, acc) -> [{pos, :down, :turn_left} | acc]
      (_, acc) -> acc
    end)
  end

  def move_cart_forward({{cx, cy}, :right=dir, next_turn}), do: {{cx + 1, cy}, dir, next_turn}
  def move_cart_forward({{cx, cy}, :left=dir, next_turn}), do: {{cx - 1, cy}, dir, next_turn}
  def move_cart_forward({{cx, cy}, :up=dir, next_turn}), do: {{cx, cy - 1}, dir, next_turn}
  def move_cart_forward({{cx, cy}, :down=dir, next_turn}), do: {{cx, cy + 1}, dir, next_turn}

  # @spec turn_cart(cart(), grid()) :: cart()
  def turn_cart({pos, _dir, _next_turn}=cart, grid),
    do: turn_cart_at(cart, grid[pos])

  def turn_cart_at({pos, :left, next_turn}, ?\\), do: {pos, :up, next_turn}
  def turn_cart_at({pos, :right, next_turn}, ?\\), do: {pos, :down, next_turn}
  def turn_cart_at({pos, :up, next_turn}, ?\\),    do: {pos, :left, next_turn}
  def turn_cart_at({pos, :down, next_turn}, ?\\), do: {pos, :right, next_turn}

  def turn_cart_at({pos, :left, next_turn}, ?/), do: {pos, :down, next_turn}
  def turn_cart_at({pos, :right, next_turn}, ?/), do: {pos, :up, next_turn}
  def turn_cart_at({pos, :up, next_turn}, ?/), do: {pos, :right, next_turn}
  def turn_cart_at({pos, :down, next_turn}, ?/), do: {pos, :left, next_turn}

  def turn_cart_at({pos, :left, :turn_left}, ?+), do: {pos, :down, :straight}
  def turn_cart_at({pos, :left, :straight}, ?+), do: {pos, :left, :turn_right}
  def turn_cart_at({pos, :left, :turn_right}, ?+), do: {pos, :up, :turn_left}
  def turn_cart_at({pos, :right, :turn_left}, ?+), do: {pos, :up, :straight}
  def turn_cart_at({pos, :right, :straight}, ?+), do: {pos, :right, :turn_right}
  def turn_cart_at({pos, :right, :turn_right}, ?+), do: {pos, :down, :turn_left}
  def turn_cart_at({pos, :up, :turn_left}, ?+), do: {pos, :left, :straight}
  def turn_cart_at({pos, :up, :straight}, ?+), do: {pos, :up, :turn_right}
  def turn_cart_at({pos, :up, :turn_right}, ?+), do: {pos, :right, :turn_left}
  def turn_cart_at({pos, :down, :turn_left}, ?+), do: {pos, :right, :straight}
  def turn_cart_at({pos, :down, :straight}, ?+), do: {pos, :down, :turn_right}
  def turn_cart_at({pos, :down, :turn_right}, ?+), do: {pos, :left, :turn_left}

  def turn_cart_at(cart, ?\s), do: raise "Invalid position for cart #{inspect cart}"
  def turn_cart_at(cart, _), do: cart

  def first_dup([elem, elem | _]), do: {:dup, elem}
  def first_dup([_ | elems]), do: first_dup(elems)
  def first_dup([]), do: :ok

  def check_for_crash(carts) do
    case carts
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.sort()
    |> first_dup() do
      :ok -> {:ok, carts}
      {:dup, pos} -> {:crash, pos}
    end
  end

  def part_one(carts, grid) do
    case carts
    |> Enum.map(&move_cart_forward/1)
    |> Enum.map(&(turn_cart(&1, grid)))
    |> check_for_crash() do
      {:ok, carts} -> part_one(carts, grid)
      {:crash, pos} -> pos
    end
  end


  def remove_pos(carts, pos), do: carts |> Enum.reject(fn {p, _, _} -> p == pos end)

  def move_carts(carts, moved_carts \\ [])
  def move_carts([cart | carts], moved_carts) do
    cart = move_cart_forward(cart)
    case check_for_crash([cart | carts] ++ moved_carts) do
      {:ok, _} -> move_carts(carts, [cart | moved_carts])
      {:crash, pos} -> move_carts(carts |> remove_pos(pos),
                                  moved_carts |> remove_pos(pos))
    end
  end
  def move_carts([], moved_carts), do: moved_carts

  def part_two(carts, grid) do
    case carts
    |> move_carts()
    |> Enum.map(&(turn_cart(&1, grid))) do
      [{pos, _, _}=cart] -> move_cart_forward(cart)
      carts -> part_two(carts, grid)
    end
  end

end


input = File.stream!("day_13_input.txt")
|> Enum.with_index()
|> Enum.flat_map(fn {line, y} ->
  line
  |> String.to_charlist()
  |> Stream.with_index()
  |> Enum.map(fn {c, x} ->
    {{x, y}, c}
  end)
end)
|> Enum.into(Map.new())

carts = input
|> Day13.carts()
|> IO.inspect(label: "carts")

Day13.part_one(carts, input)
|> IO.inspect(label: "Part One")

Day13.part_two(carts, input)
|> IO.inspect(label: "Part Two")
