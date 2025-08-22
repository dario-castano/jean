defmodule JeanTest do
  use ExUnit.Case
  doctest Jean

  test "greets the world" do
    assert Jean.hello() == :world
  end
end
