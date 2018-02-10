defmodule IslandsEngine.BoardTest do
  use ExUnit.Case
  import IslandsEngine.Board
  alias IslandsEngine.{Coordinate, Island}

  doctest IslandsEngine.Board

  describe "position_island/3" do
    setup do
      {:ok, dot_upper_left} = Coordinate.new(1, 1)
      {:ok, dot} = Island.new(:dot, dot_upper_left)
      {:ok, square_upper_left} = Coordinate.new(1, 2)
      {:ok, square} = Island.new(:square, square_upper_left)

      {:ok, dot: dot, square: square}
    end

    test "first island on an empty board", %{square: square} do
      board = %{}

      assert position_island(board, :square, square) == %{square: square}
    end

    test "non-overlapping island", %{dot: dot, square: square} do
      board = %{dot: dot}

      assert position_island(board, :square, square) == %{dot: dot, square: square}
    end

    test "overlapping island of different type", %{dot: dot} do
      board = %{dot: dot}
      {:ok, overlapping_upper_left} = Coordinate.new(1, 1)
      {:ok, overlapping_square} = Island.new(:square, overlapping_upper_left)

      assert position_island(board, :square, overlapping_square) ==
        {:error, :overlapping_island}
    end

    test "overlapping island of same type", %{square: square} do
      board = %{square: square}
      {:ok, overlapping_upper_left} = Coordinate.new(1, 1)
      {:ok, overlapping_square} = Island.new(:square, overlapping_upper_left)

      assert position_island(board, :square, overlapping_square) == %{square: overlapping_square}
    end
  end

  describe "all_islands_positioned?/1" do
    setup do
      board = Island.types()
        |> Enum.reduce(%{}, fn(type, acc) -> Map.put(acc, type, "here") end)

      {:ok, board: board}
    end

    test "when all islands positioned", %{board: board} do
      assert all_islands_positioned?(board)
    end

    test "when not all islands positioned", %{board: board} do
      random_island = Island.types() |> Enum.random()
      board = Map.delete(board, random_island)

      refute all_islands_positioned?(board)
    end
  end

  describe "guess/2" do
    setup do
      {:ok, coordinate} = Coordinate.new(1, 1)
      {:ok, square} = Island.new(:square, coordinate)

      {:ok, square: square}
    end

    test "miss", %{square: square} do
      board = %{square: square}
      {:ok, guess_coordinate} = Coordinate.new(1, 3)

      assert guess(board, guess_coordinate) == {:miss, :none, :no_win, board}
    end

    test "hit that does not fully forest island", %{square: square} do
      {:ok, guess_coordinate} = Coordinate.new(1, 2)
      hit_square = %{square | hit_coordinates: MapSet.new([guess_coordinate])}
      board = %{square: square}
      board_after_hit = %{square: hit_square}

      assert guess(board, guess_coordinate) == {:hit, :none, :no_win, board_after_hit}
    end

    test "hit that fully forests island but does not win game", %{square: square} do
      {:ok, dot_coordinate} = Coordinate.new(1, 3)
      {:ok, dot} = Island.new(:dot, dot_coordinate)
      hit_dot = %{dot | hit_coordinates: MapSet.new([dot_coordinate])}
      board = %{dot: dot, square: square}
      board_after_hit = %{dot: hit_dot, square: square}

      assert guess(board, dot_coordinate) == {:hit, :dot, :no_win, board_after_hit}
    end

    test "hit that fully forests island and wins game" do
      {:ok, dot_coordinate} = Coordinate.new(1, 3)
      {:ok, dot} = Island.new(:dot, dot_coordinate)
      hit_dot = %{dot | hit_coordinates: MapSet.new([dot_coordinate])}
      board = %{dot: dot}
      board_after_hit = %{dot: hit_dot}

      assert guess(board, dot_coordinate) == {:hit, :dot, :win, board_after_hit}
    end
  end
end