defmodule IslandsEngine.CoordinateTest do
  use ExUnit.Case
  doctest IslandsEngine.Coordinate
  alias IslandsEngine.Coordinate

  describe "new/2" do
    test "with valid coordinates" do
      assert Coordinate.new(1, 1) == {:ok, %Coordinate{col: 1, row: 1}}
    end

    test "with a coordinate below valid range" do
      assert Coordinate.new(0, 1) == {:error, :invalid_coordinate}
    end

    test "with a coordinate above valid range" do
      assert Coordinate.new(1, 11) == {:error, :invalid_coordinate}
    end
  end
end