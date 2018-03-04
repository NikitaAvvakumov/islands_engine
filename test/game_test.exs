defmodule IslandsEngine.GameTest do
  use ExUnit.Case
  import IslandsEngine.Game

  doctest IslandsEngine.Game

  test "start_link/1" do
    {:ok, game} = start_link("Frank")

    assert %{player1: %{name: "Frank"}, player2: %{name: nil}} =
      :sys.get_state(game)
  end

  describe "add_player/2" do
    setup do
      {:ok, game} = start_link("Frank")

      {:ok, game: game}
    end

    test "when rules permit adding player", %{game: game} do
      :sys.replace_state(game, fn(state) -> put_in(state.rules.state, :initialized) end)

      assert add_player(game, "Theo") == :ok
      assert %{player2: %{name: "Theo"}} = :sys.get_state(game)
    end

    test "when rules deny adding player", %{game: game} do
      assert add_player(game, "Theo") == :ok
      
      assert add_player(game, "Rufus") == :error
    end
  end

  describe "position_island/5" do
    setup do
      {:ok, game} = start_link("Frank")

      {:ok, game: game}
    end

    test "happy path", %{game: game} do
      add_player(game, "Theo")

      assert position_island(game, :player1, :square, 1, 1) == :ok

      assert %{player1: %{board: %{square: _}}} = :sys.get_state(game)
    end

    test "when players are not set", %{game: game} do
      assert :error = position_island(game, :player1, :square, 1, 1)
    end

    test "when islands have been positioned", %{game: game} do
      :sys.replace_state(game, fn(state) -> put_in(state.rules.state, :player1_turn) end)

      assert :error = position_island(game, :player1, :square, 1, 1)
    end

    test "when island type is invalid", %{game: game} do
      add_player(game, "Theo")

      assert {:error, :invalid_island_type} =
        position_island(game, :player1, :whatever, 1, 1)
    end

    test "when coordinate is invalid", %{game: game} do
      add_player(game, "Theo")

      assert {:error, :invalid_coordinate} =
        position_island(game, :player1, :square, 10, 10)
    end
  end

  describe "set_islands/2" do
    setup do
      {:ok, game} = start_link("Frank")
      add_player(game, "Theo")
      :ok = position_island(game, :player1, :atoll, 1, 1)
      :ok = position_island(game, :player1, :dot, 1, 4)
      :ok = position_island(game, :player1, :l_shape, 1, 5)
      :ok = position_island(game, :player1, :s_shape, 5, 1)

      {:ok, game: game}
    end

    test "when not all islands positioned", %{game: game} do
      assert set_islands(game, :player1) == {:error, :not_all_islands_positioned}
    end

    test "when all islands positioned", %{game: game} do
      :ok = position_island(game, :player1, :square, 5, 5)

      assert {:ok, _board} = set_islands(game, :player1)

      assert %{rules: %{player1: :islands_set, state: :players_set}} =
        :sys.get_state(game)
    end
  end

  describe "guess_coordinate/4" do
    setup do
      {:ok, game} = start_link("Frank")
      add_player(game, "Theo")

      position_island(game, :player1, :dot, 1, 1)
      position_island(game, :player2, :dot, 1, 1)

      :sys.replace_state(game, fn(state) -> put_in(state.rules.state, :player1_turn) end)

      {:ok, game: game}
    end

    test "when it's not player's turn to guess", %{game: game} do
      assert guess_coordinate(game, :player2, 1, 1) == :error
    end

    test "when guess coordinate is invalid", %{game: game} do
      assert guess_coordinate(game, :player1, 11, 11) == {:error, :invalid_coordinate}
    end

    test "when guess coordinate is a miss", %{game: game} do
      assert guess_coordinate(game, :player1, 2, 1) == {:miss, :none, :no_win}
    end

    test "when guess coordinate is a hit", %{game: game} do
      assert guess_coordinate(game, :player1, 1, 1) == {:hit, :dot, :win}
    end
  end
end