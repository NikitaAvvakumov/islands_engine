defmodule IslandsEngine.IslandTest do
  use ExUnit.Case
  alias IslandsEngine.{Coordinate, Island}

  doctest IslandsEngine.Island

  describe "new/2" do
    test "with valid type and valid starting position for type" do
      {:ok, upper_left} = Coordinate.new(9, 9)
      expected_coordinates =
        [{9, 9}, {9, 10}, {10, 9}, {10, 10}]
        |> Enum.map(fn({row, col}) -> Coordinate.new(row, col) |> elem(1) end)
        |> MapSet.new()

      assert {:ok, %Island{} = island} = Island.new(:square, upper_left)
      assert MapSet.equal?(island.coordinates, expected_coordinates)
      assert MapSet.equal?(island.hit_coordinates, MapSet.new())
    end

    test "with invalid type" do
      {:ok, upper_left} = Coordinate.new(1, 1)
      assert {:error, :invalid_island_type} = Island.new(:none, upper_left)
    end

    test "with invalid starting position for type" do
      {:ok, upper_left} = Coordinate.new(10, 10)
      assert {:error, :invalid_coordinate} = Island.new(:square, upper_left)
    end
  end

  describe "overlaps/2" do
    test "when non-overlapping" do
      {:ok, first_upper_left} = Coordinate.new(1, 1)
      {:ok, first_island} = Island.new(:square, first_upper_left)
      {:ok, second_upper_left} = Coordinate.new(3, 3)
      {:ok, second_island} = Island.new(:square, second_upper_left)

      refute Island.overlaps?(first_island, second_island)
    end

    test "when overlapping" do
      {:ok, first_upper_left} = Coordinate.new(1, 1)
      {:ok, first_island} = Island.new(:square, first_upper_left)
      {:ok, second_upper_left} = Coordinate.new(2, 2)
      {:ok, second_island} = Island.new(:square, second_upper_left)

      assert Island.overlaps?(first_island, second_island)
    end

    test "when interlocking" do
      # S-shaped island and Atoll can interlock:
      #   1234
      # 1 ..AA
      # 2 .SSA
      # 3 SSAA
      {:ok, s_upper_left} = Coordinate.new(2, 1)
      {:ok, s_island} = Island.new(:s_shape, s_upper_left)
      {:ok, atoll_left} = Coordinate.new(1, 3)
      {:ok, atoll} = Island.new(:atoll, atoll_left)

      refute Island.overlaps?(s_island, atoll)
    end
  end

  describe "guess/2" do
    test "when hit" do
      {:ok, coordinate} = Coordinate.new(2, 2)
      {:ok, island} = Island.new(:square, coordinate)

      assert {:ok, updated_island} = Island.guess(island, coordinate)
      assert MapSet.equal?(updated_island.hit_coordinates, MapSet.new([coordinate]))
    end

    test "when miss" do
      {:ok, coordinate} = Coordinate.new(2, 2)
      {:ok, island} = Island.new(:square, coordinate)
      {:ok, external_coordinate} = Coordinate.new(2, 1)

      assert :miss = Island.guess(island, external_coordinate)
    end
  end

  describe "forested?/1" do
    test "when fully forested" do
      {:ok, upper_left} = Coordinate.new(1, 1)
      {:ok, island} = Island.new(:square, upper_left)
      island = %{island | hit_coordinates: island.coordinates}

      assert Island.forested?(island)
    end

    test "when partially forested" do
      {:ok, upper_left} = Coordinate.new(1, 1)
      {:ok, island} = Island.new(:square, upper_left)
      island = %{island | hit_coordinates: island.coordinates |> MapSet.delete(upper_left)}

      refute Island.forested?(island)
    end
  end
end