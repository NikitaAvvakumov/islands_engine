defmodule IslandsEngine.GuessesTest do
  use ExUnit.Case
  alias IslandsEngine.{Coordinate, Guesses}

  doctest IslandsEngine.Guesses

  describe "add/3" do
    test "adding a hit" do
      guesses = Guesses.new()
      {:ok, coordinate} = Coordinate.new(1, 1)

      updated = Guesses.add(guesses, :hit, coordinate)

      assert MapSet.equal?(updated.hits, MapSet.new([coordinate]))
      assert MapSet.equal?(updated.misses, MapSet.new())
    end

    test "adding a miss" do
      guesses = Guesses.new()
      {:ok, coordinate} = Coordinate.new(1, 1)

      updated = Guesses.add(guesses, :miss, coordinate)

      assert MapSet.equal?(updated.misses, MapSet.new([coordinate]))
      assert MapSet.equal?(updated.hits, MapSet.new())
    end

    test "adding a duplicate" do
      guesses = Guesses.new()
      {:ok, coordinate} = Coordinate.new(1, 1)

      updated_once = Guesses.add(guesses, :miss, coordinate)
      updated_twice = Guesses.add(updated_once, :miss, coordinate)

      assert MapSet.equal?(updated_twice.misses, MapSet.new([coordinate]))
      assert MapSet.equal?(updated_twice.hits, MapSet.new())
    end
  end
end