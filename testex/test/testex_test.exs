defmodule TestexTest do
  use ExUnit.Case
  doctest Testex

  test "greets the world" do
    assert Testex.hello() == :world
  end
end
