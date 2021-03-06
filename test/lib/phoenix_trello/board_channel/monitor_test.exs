defmodule PhoenixTrello.BoardChannel.MonitorTest do
  use ExUnit.Case, async: true

  import PhoenixTrello.Factory

  alias PhoenixTrello.BoardChannel.Monitor

  setup_all do
    users = %{
      first_user: create(:user),
      second_user: create(:user),
      third_user: create(:user)
    }

    {:ok, users}
  end

  test "it adds a user calling :user_joined", users do
    {:reply, _, new_state} = Monitor.handle_call({:user_joined, "1-foo", users.first_user}, nil, %{})
    {:reply, _, new_state} = Monitor.handle_call({:user_joined, "1-foo", users.second_user}, nil, new_state)
    {:reply, _, new_state} = Monitor.handle_call({:user_joined, "1-foo", users.third_user}, nil, new_state)

    assert new_state == %{"1-foo" => [users.third_user, users.second_user, users.first_user]}
  end

  test "it removes a user when calling :user_left", users do
    {:reply, _, new_state} = Monitor.handle_call({:user_joined, "1-foo", users.first_user}, nil, %{})
    {:reply, _, new_state} = Monitor.handle_call({:user_joined, "1-foo", users.second_user}, nil, new_state)
    {:reply, _, new_state} = Monitor.handle_call({:user_joined, "1-foo", users.third_user}, nil, new_state)
    assert new_state == %{"1-foo" => [users.third_user, users.second_user, users.first_user]}

    {:reply, _, new_state} = Monitor.handle_call({:user_left, "1-foo", users.third_user.id}, nil, new_state)
    assert new_state == %{"1-foo" => [users.second_user, users.first_user]}

    {:reply, _, new_state} = Monitor.handle_call({:user_left, "1-foo", users.second_user.id}, nil, new_state)
    assert new_state == %{"1-foo" => [users.first_user]}
  end

  test "it returns the list of users in channel when calling :users_in_channel", users do
    {:reply, _, new_state} = Monitor.handle_call({:user_joined, "1-foo", users.first_user}, nil, %{})
    {:reply, _, new_state} = Monitor.handle_call({:user_joined, "1-foo", users.second_user}, nil, new_state)
    {:reply, _, new_state} = Monitor.handle_call({:user_joined, "1-foo", users.third_user}, nil, new_state)

    {:reply, returned_users, _new_state} = Monitor.handle_call({:users_in_channel, "1-foo"}, nil, new_state)

    assert returned_users === [users.third_user, users.second_user, users.first_user]
  end
end
