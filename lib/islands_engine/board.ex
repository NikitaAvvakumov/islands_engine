defmodule IslandsEngine.Board do
  alias IslandsEngine.{Coordinate, Island}

  def new, do: %{}

  @spec position_island(board :: map, key :: atom, %Island{}) :: map | {:error, :overlapping_island}
  def position_island(board, key, %Island{} = island) do
    case overlaps_existing_island?(board, key, island) do
      true -> {:error, :overlapping_island}
      false -> Map.put(board, key, island)
    end
  end

  @spec overlaps_existing_island?(board :: map, new_key :: atom, %Island{}) :: boolean
  defp overlaps_existing_island?(board, new_key, new_island) do
    Enum.any?(board, fn({key, island}) ->
      key != new_key and Island.overlaps?(island, new_island)
    end)
  end

  @spec all_islands_positioned?(board :: map) :: boolean
  def all_islands_positioned?(board) do
    Island.types()
    |> Enum.all?(&Map.has_key?(board, &1))
  end

  @spec guess(board :: map, %Coordinate{}) :: {:hit | :miss, atom, :win | :no_win, map}
  def guess(board, %Coordinate{} = coordinate) do
    board |> check_all_islands(coordinate) |> guess_response(board)
  end

  @spec check_all_islands(board :: map, %Coordinate{}) :: {atom, %Island{}} | :miss
  defp check_all_islands(board, coordinate) do
    Enum.find_value(board, :miss, fn({key, island}) ->
      case Island.guess(island, coordinate) do
        {:hit, island} -> {key, island}
        :miss -> false
      end
    end)
  end

  @spec guess_response(:miss, board :: map) :: {:miss, :none, :no_win, map}
  defp guess_response(:miss, board), do: {:miss, :none, :no_win, board}

  @spec guess_response({key :: atom, %Island{}}, board :: map) :: {:hit, atom, :win | :no_win, map}
  defp guess_response({key, island}, board) do
    board = %{board | key => island}
    {:hit, forest_check(board, key), win_check(board), board}
  end

  @spec forest_check(board :: map, key :: atom) :: atom
  defp forest_check(board, key) do
    case forested?(board, key) do
      true -> key
      false -> :none
    end
  end

  @spec forested?(board :: map, key :: atom) :: boolean
  defp forested?(board, key) do
    board |> Map.fetch!(key) |> Island.forested?()
  end

  @spec win_check(board :: map) :: :win | :no_win
  defp win_check(board) do
    case all_forested?(board) do
      true -> :win
      false -> :no_win
    end
  end

  @spec all_forested?(board :: map) :: boolean
  defp all_forested?(board) do
    Enum.all?(board, fn({_key, island}) -> Island.forested?(island) end)
  end
end