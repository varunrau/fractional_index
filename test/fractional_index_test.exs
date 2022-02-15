defmodule FractionalIndexTest do
  use ExUnit.Case
  doctest FractionalIndex

  describe "midpoint" do
    test "wrong order" do
      assert {:error, {:wrong_order, _msg}} = FractionalIndex.midpoint("b", "a")
    end

    test "trailing zero" do
      assert {:error, {:trailing_zero, _msg}} = FractionalIndex.midpoint("a0", "b0")
    end

    test "find common prefix" do
      assert 3 = FractionalIndex.find_common_prefix_size("abc", "abcdef")
    end

    test "simple" do
      assert {:ok, "V"} = FractionalIndex.midpoint("", nil)
      assert {:ok, "l"} = FractionalIndex.midpoint("V", nil)
      assert {:ok, "t"} = FractionalIndex.midpoint("l", nil)
      assert {:ok, "b"} = FractionalIndex.midpoint("a", "c")
      assert {:ok, "001000V"} = FractionalIndex.midpoint("001", "001001")
    end
  end

  test "increment integer" do
    assert "a1" = FractionalIndex.increment_integer("a0")
    assert "b00" = FractionalIndex.increment_integer("az")
    assert "Zz" = FractionalIndex.increment_integer("Zy")
    assert nil == FractionalIndex.increment_integer("zzzzzzzzzzzzzzzzzzzzzzzzzzz")
  end

  test "decrement integer" do
    assert "a0" = FractionalIndex.decrement_integer("a1")
    assert "az" = FractionalIndex.decrement_integer("b00")
    assert "dABzz" = FractionalIndex.decrement_integer("dAC00")
    assert nil == FractionalIndex.decrement_integer("A00000000000000000000000000")
    assert "Xyzz" = FractionalIndex.decrement_integer("Xz00")
    assert "Zz" = FractionalIndex.decrement_integer("a0")
  end

  test "generate key between" do
    assert {:ok, "a1"} = FractionalIndex.generate_key_between("a0", nil)
    assert {:ok, "a0G"} = FractionalIndex.generate_key_between("a0", "a0V")
    assert {:ok, "a0"} = FractionalIndex.generate_key_between(nil, nil)
    assert {:ok, "ZzV"} = FractionalIndex.generate_key_between("Zz", "a0")
    assert {:ok, "a0"} = FractionalIndex.generate_key_between("Zz", "a01")
    assert {:ok, "Zz"} = FractionalIndex.generate_key_between(nil, "a0")
  end

  test ":invalid_order_key_head does not raise a MatchError" do
    assert {:error, :invalid_order_key} == FractionalIndex.generate_key_between("0", "1")
  end
end
