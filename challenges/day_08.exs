#! /usr/bin/env elixir

defmodule Day8 do
  def parse([]) do
    {}
  end

  def parse([n_child_nodes, n_metadata_entries | rest]) do
    {children, rest} = parse_children(n_child_nodes, rest, [])
    {metadata, rest} = Enum.split(rest, n_metadata_entries)
    {{children, metadata}, rest}
  end

  def parse_children(0, rest, acc) do
    {acc |> Enum.reverse(), rest}
  end

  def parse_children(n, rest, acc) do
    {node, rest} = parse(rest)
    parse_children(n - 1, rest, [node | acc])
  end

  def only_metadata({children, metadata}) do
    child_metadata = for c <- children, do: only_metadata(c)
    [metadata] ++ child_metadata
  end

  def only_metadata([{children, metadata} | rest]) do
    child_metadata = for c <- children, do: only_metadata(c)
    other_metadata = for c <- rest, do: only_metadata(c)
    metadata ++ child_metadata ++ other_metadata
  end

  # If a node has no child nodes, its value is the sum of its metadata entries.
  def count_metadata({[], metadata}) do
    metadata
  end

  # However, if a node does have child nodes, the metadata entries become indexes which refer to those child nodes.
  def count_metadata({children, metadata}) do
    for i <- metadata do
      case Enum.at(children, i - 1, :none) do
        :none -> 0
        child -> count_metadata(child)
      end
    end
  end
end

input =
  File.read!("day_08_input.txt")
  |> String.splitter([" "])
  |> Enum.map(&String.to_integer/1)
  |> Enum.to_list()

{children, []} =
  input
  |> Day8.parse()

children
|> Day8.only_metadata()
|> List.flatten()
|> Enum.sum()
|> IO.inspect(label: "Part One")

children
|> Day8.count_metadata()
|> List.flatten()
|> Enum.sum()
|> IO.inspect(label: "Part Two")
