defmodule IslandsEngine.RulesTest do
  use ExUnit.Case
  alias IslandsEngine.Rules

  doctest Rules

  describe "check/2" do
    test "adding player when :initialized" do
      rules = %Rules{state: :initialized}
      action = :add_player

      assert {:ok, %{state: :players_set}} = Rules.check(rules, action)
    end

    test "position islands when :players_set & player's islands not set" do
      rules = %Rules{state: :players_set, player1: :islands_not_set}
      action = {:position_islands, :player1}

      assert {:ok, %{state: :players_set}} = Rules.check(rules, action)
    end

    test "position islands when :players_set & player's islands are set" do
      rules = %Rules{state: :players_set, player1: :islands_set}
      action = {:position_islands, :player1}

      assert Rules.check(rules, action) == :error
    end

    test "set islands when :players_set and other player's islands not set" do
      rules = %Rules{state: :players_set, player1: :islands_not_set, player2: :islands_not_set}
      action = {:set_islands, :player1}

      assert {:ok, %{state: :players_set, player1: :islands_set}} = Rules.check(rules, action)
    end

    test "set islands when :players_set and other player's islands are set" do
      rules = %Rules{state: :players_set, player1: :islands_not_set, player2: :islands_set}
      action = {:set_islands, :player1}

      assert {:ok, %{state: :player1_turn, player1: :islands_set}} = Rules.check(rules, action)
    end

    test "player 1 guess when player 1 turn" do
      rules = %Rules{state: :player1_turn}
      action = {:guess_coordinate, :player1}

      assert {:ok, %{state: :player2_turn}} = Rules.check(rules, action)
    end

    test "player 2 guess when player 2 turn" do
      rules = %Rules{state: :player2_turn}
      action = {:guess_coordinate, :player2}

      assert {:ok, %{state: :player1_turn}} = Rules.check(rules, action)
    end

    test "guess when not player's turn" do
      rules = %Rules{state: :player1_turn}
      action = {:guess_coordinate, :player2}

      assert Rules.check(rules, action) == :error
    end

    test "win check when player turn and win" do
      rules = %Rules{state: :player2_turn}
      action = {:win_check, :win}

      assert {:ok, %{state: :game_over}} = Rules.check(rules, action)
    end

    test "win check when player turn and no_win" do
      rules = %Rules{state: :player2_turn}
      action = {:win_check, :no_win}

      assert {:ok, %{state: :player2_turn}} = Rules.check(rules, action)
    end

    test "unknown action" do
      rules = %Rules{state: :initialized}

      assert Rules.check(rules, :say_what) == :error
    end
  end
end