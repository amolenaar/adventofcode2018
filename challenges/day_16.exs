#!/usr/bin/env elixir


defmodule Opcodes do

  require Bitwise

  def val(regs, index), do: Enum.at(regs, index)
  def update(regs, index, value), do:  Enum.take(regs, index) ++ [value] ++ Enum.drop(regs, index + 1)

  # Addition:

  # addr (add register) stores into register C the result of adding register A and register B.
  def addr([_opcode, a, b, c], regs), do: update(regs, c, val(regs, a) + val(regs, b))

  # addi (add immediate) stores into register C the result of adding register A and value B.
  def addi([_opcode, a, b, c], regs), do: update(regs, c, val(regs, a) + b)

  # Multiplication:

  # mulr (multiply register) stores into register C the result of multiplying register A and register B.
  def mulr([_opcode, a, b, c], regs), do: update(regs, c, val(regs, a) * val(regs, b))
  # muli (multiply immediate) stores into register C the result of multiplying register A and value B.
  def muli([_opcode, a, b, c], regs), do: update(regs, c, val(regs, a) * b)

  # Bitwise AND:

  # banr (bitwise AND register) stores into register C the result of the bitwise AND of register A and register B.
  def banr([_opcode, a, b, c], regs), do: update(regs, c, Bitwise.band(val(regs, a), val(regs, b)))
  # bani (bitwise AND immediate) stores into register C the result of the bitwise AND of register A and value B.
  def bani([_opcode, a, b, c], regs), do: update(regs, c, Bitwise.band(val(regs, a), b))

  # Bitwise OR:

  # borr (bitwise OR register) stores into register C the result of the bitwise OR of register A and register B.
  def borr([_opcode, a, b, c], regs), do: update(regs, c, Bitwise.bor(val(regs, a), val(regs, b)))
  # bori (bitwise OR immediate) stores into register C the result of the bitwise OR of register A and value B.
  def bori([_opcode, a, b, c], regs), do: update(regs, c, Bitwise.bor(val(regs, a), b))

  # Assignment:

  # setr (set register) copies the contents of register A into register C. (Input B is ignored.)
  def setr([_opcode, a, _b, c], regs), do: update(regs, c, val(regs, a))
  # seti (set immediate) stores value A into register C. (Input B is ignored.)
  def seti([_opcode, a, _b, c], regs), do: update(regs, c, a)

  # Greater-than testing:

  # gtir (greater-than immediate/register) sets register C to 1 if value A is greater than register B. Otherwise, register C is set to 0.
  def gtir([_opcode, a, b, c], regs), do: update(regs, c, (if (a > val(regs, b)), do: 1, else: 0))
  # gtri (greater-than register/immediate) sets register C to 1 if register A is greater than value B. Otherwise, register C is set to 0.
  def gtri([_opcode, a, b, c], regs), do: update(regs, c, (if (val(regs, a) > b), do: 1, else: 0))
  # gtrr (greater-than register/register) sets register C to 1 if register A is greater than register B. Otherwise, register C is set to 0.
  def gtrr([_opcode, a, b, c], regs), do: update(regs, c, (if (val(regs, a) > val(regs, b)), do: 1, else: 0))

  # Equality testing:

  # eqir (equal immediate/register) sets register C to 1 if value A is equal to register B. Otherwise, register C is set to 0.
  def eqir([_opcode, a, b, c], regs), do: update(regs, c, (if (a == val(regs, b)), do: 1, else: 0))
  # eqri (equal register/immediate) sets register C to 1 if register A is equal to value B. Otherwise, register C is set to 0.
  def eqri([_opcode, a, b, c], regs), do: update(regs, c, (if (val(regs, a) == b), do: 1, else: 0))
  # eqrr (equal register/register) sets register C to 1 if register A is equal to register B. Otherwise, register C is set to 0.
  def eqrr([_opcode, a, b, c], regs), do: update(regs, c, (if (val(regs, a) == val(regs, b)), do: 1, else: 0))

  def opcodes(), do: [
    :addr,
    :addi,
    :mulr,
    :muli,
    :banr,
    :bani,
    :borr,
    :bori,
    :setr,
    :seti,
    :gtir,
    :gtri,
    :gtrr,
    :eqir,
    :eqri,
    :eqrr
  ]
end

regs_to_ints = fn (str) ->
  str
  |> String.split(["[", ",", "]"])
  |> Enum.reject(&(&1 == ""))
  |> Enum.map(&(&1 |> String.trim() |> String.to_integer()))
end

exec_to_ints = fn (str) ->
  str
  |> String.split(" ")
  |> Enum.reject(&(&1 == ""))
  |> Enum.map(&String.to_integer/1)
end

{_, input} = File.stream!("day_16_input_1.txt")
|> Stream.map(&String.trim/1)
|> Enum.reduce({%{:regs_before => nil, :regs_after => nil, :execution => nil}, []}, fn
    ("", {sample, acc}) -> {sample, acc}
    ("Before: " <> regs, {sample, acc}) -> {%{sample | regs_before: regs_to_ints.(regs)}, acc}
    ("After:  " <> regs, {sample, acc}) -> {%{:regs_before => nil, :regs_after => nil, :execution => nil},
      [%{sample | regs_after: regs_to_ints.(regs)} | acc]}
    (execution, {sample, acc}) -> {%{sample | execution: exec_to_ints.(execution)}, acc}
end)

input
|> Enum.map(fn (sample) ->
  for oper <- Opcodes.opcodes() do
    apply(Opcodes, oper, [sample[:execution], sample[:regs_before]])
  end
  |> Enum.count(fn out -> out == sample[:regs_after] end)
  |> (fn out -> Map.put(sample, :tests, out) end).()
end)
|> Enum.filter(fn sample -> sample[:tests] >= 3 end)
|> Enum.count()
|> IO.inspect(label: "Part One")


opcode_mapping = input
|> Enum.map(fn (sample) ->
  regs_after = sample[:regs_after]
  for oper <- Opcodes.opcodes(),
    regs_after == apply(Opcodes, oper, [sample[:execution], sample[:regs_before]]) do
    oper
  end
  |> (fn out -> Map.put(sample, :opcodes, out) end).()
end)
|> Stream.cycle()
|> Enum.reduce_while(%{}, fn (sample, acc) ->
  unresolved_opcodes = sample[:opcodes] |> Enum.filter(&(acc[&1] == nil))
  if length(unresolved_opcodes) == 1 do
    opcode = unresolved_opcodes |> hd()
    opcode_nr = sample[:execution] |> hd()
    {:cont, Map.put(acc, opcode, opcode_nr)}
  else
    if map_size(acc) == length(Opcodes.opcodes()) do
      {:halt, acc}
    else
      # IO.puts("Found opcocode #{inspect opcode} #{inspect opcode_nr}")
      {:cont, acc}
    end
  end
end)
|> Enum.map(fn {opcode, nr} -> {nr, opcode} end)
# |> Enum.filter(fn sample -> sample[:opcodes] >= 3 end)
# |> Enum.count()
|> Enum.into(%{})

File.stream!("day_16_input_2.txt")
|> Stream.map(fn s -> s |> String.split() |> Enum.map(&String.to_integer/1) end)
|> Enum.reduce([0, 0, 0, 0], fn (instruction, regs) ->
  apply(Opcodes, opcode_mapping[instruction |> hd()], [instruction, regs])
end)
|> hd()
|> IO.inspect(label: "Part Two")
