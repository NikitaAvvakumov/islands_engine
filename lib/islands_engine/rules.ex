defmodule IslandsEngine.Rules do
  alias __MODULE__

  defstruct state: :initialized,
            player1: :islands_not_set,
            player2: :islands_not_set

  def new(), do: %Rules{}

  def check(%Rules{state: :initialized} = rules, :add_player) do
    {:ok, %Rules{rules | state: :players_set}}  
  end

  def check(%Rules{state: :players_set} = rules, {:position_islands, player}) do
    case Map.fetch!(rules, player) do
      :islands_set -> :error
      :islands_not_set -> {:ok, rules}
    end
  end

  def check(%Rules{state: :players_set} = rules, {:set_islands, player}) do
    rules = Map.put(rules, player, :islands_set)

    case both_players_islands_set?(rules) do
      true -> {:ok, %Rules{rules | state: :player1_turn}}
      false -> {:ok, rules}
    end
  end

  def check(%Rules{state: :player1_turn} = rules, {:guess_coordinate, :player1}) do
    {:ok, %Rules{rules | state: :player2_turn}}
  end

  def check(%Rules{state: :player2_turn} = rules, {:guess_coordinate, :player2}) do
    {:ok, %Rules{rules | state: :player1_turn}}
  end

  def check(%Rules{state: state} = rules, {:win_check, win_or_not}) when state in [:player1_turn, :player2_turn] do
    case win_or_not do
      :win -> {:ok, %Rules{rules | state: :game_over}}
      :no_win -> {:ok, rules}
    end
  end

  def check(_state, _action), do: :error

  defp both_players_islands_set?(%Rules{player1: p1_state, player2: p2_state}) do
    p1_state == :islands_set and p2_state == :islands_set
  end
end