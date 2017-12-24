defmodule IslandsEngine.Island do
  alias IslandsEngine.{Coordinate, Island}

  @enforce_keys [:coordinates, :hit_coordinates]

  defstruct [:coordinates, :hit_coordinates]

  def new(type, %Coordinate{} = upper_left) do
    with {:ok, offsets} <- offsets(type),
         %MapSet{} = coordinates <- add_coordinates(offsets, upper_left)
    do
      {:ok, __struct__(coordinates: coordinates, hit_coordinates: MapSet.new())}
    else
      error -> error
    end
  end

  def overlaps?(existing_island, new_island) do
    not MapSet.disjoint?(existing_island.coordinates, new_island.coordinates)
  end

  def guess(%Island{} = island, %Coordinate{} = coordinate) do
    case MapSet.member?(island.coordinates, coordinate) do
      true ->
        {:ok, update_in(island.hit_coordinates, &MapSet.put(&1, coordinate))}
      false -> :miss
    end
  end

  def forested?(%Island{} = island) do
    MapSet.equal?(island.coordinates, island.hit_coordinates)
  end

  def types(), do: ~w(:atoll, :dot, :l_shape, :s_shape, :square)a

  defp offsets(:atoll), do: {:ok, [{0, 0}, {0, 1}, {1, 1}, {2, 0}, {2, 1}]}
  defp offsets(:dot), do: {:ok, [{0, 0}]}
  defp offsets(:l_shape), do: {:ok, [{0, 0}, {1, 0}, {2, 0}, {2, 1}]}
  defp offsets(:s_shape), do: {:ok, [{0, 1}, {0, 2}, {1, 0}, {1, 1}]}
  defp offsets(:square), do: {:ok, [{0, 0}, {0, 1}, {1, 0}, {1, 1}]}
  defp offsets(_), do: {:error, :invalid_island_type}

  defp add_coordinates(offsets, upper_left) do
    offsets |> Enum.reduce_while(MapSet.new(), fn(offset, acc) ->
      add_coordinate(acc, upper_left, offset)
    end)
  end

  defp add_coordinate(coordinates, %Coordinate{col: col, row: row}, {col_offset, row_offset}) do
    case Coordinate.new(row + row_offset, col + col_offset) do
      {:ok, coordinate} ->
        {:cont, coordinates |> MapSet.put(coordinate)}
      {:error, :invalid_coordinate} ->
        {:halt, {:error, :invalid_coordinate}}
    end
  end
end