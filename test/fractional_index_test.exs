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
    assert {:ok, "Zy"} == FractionalIndex.generate_key_between(nil, "Zz")
    assert {:ok, "a1"} == FractionalIndex.generate_key_between("a0", nil)
    assert {:ok, "a2"} == FractionalIndex.generate_key_between("a1", nil)
    assert {:ok, "a0V"} == FractionalIndex.generate_key_between("a0", "a1")
    assert {:ok, "a1V"} == FractionalIndex.generate_key_between("a1", "a2")
    assert {:ok, "a0l"} == FractionalIndex.generate_key_between("a0V", "a1")
    assert {:ok, "a0"} == FractionalIndex.generate_key_between("Zz", "a1")
    assert {:ok, "Xzzz"} == FractionalIndex.generate_key_between(nil, "Y00")
    assert {:ok, "c000"} == FractionalIndex.generate_key_between("bzz", nil)
    assert {:ok, "a0G"} == FractionalIndex.generate_key_between("a0", "a0V")
    assert {:ok, "a08"} == FractionalIndex.generate_key_between("a0", "a0G")
    assert {:ok, "b127"} == FractionalIndex.generate_key_between("b125", "b129")
    assert {:ok, "a1"} == FractionalIndex.generate_key_between("a0", "a1V")
    assert {:ok, "a0"} == FractionalIndex.generate_key_between("Zz", "a01")
    assert {:ok, "a0"} == FractionalIndex.generate_key_between(nil, "a0V")
    assert {:ok, "b99"} == FractionalIndex.generate_key_between(nil, "b999")
    assert {:ok, "Z0"} == FractionalIndex.generate_key_between("Yzz", "Z0G")

    assert {:ok, "A000000000000000000000000000V"} ==
             FractionalIndex.generate_key_between(nil, "A000000000000000000000000001")

    assert {:ok, "zzzzzzzzzzzzzzzzzzzzzzzzzzz"} ==
             FractionalIndex.generate_key_between("zzzzzzzzzzzzzzzzzzzzzzzzzzy", nil)

    assert {:ok, "zzzzzzzzzzzzzzzzzzzzzzzzzzzV"} ==
             FractionalIndex.generate_key_between("zzzzzzzzzzzzzzzzzzzzzzzzzzz", nil)
  end

  test ":invalid_order_key_head does not raise a MatchError" do
    assert {:error, :invalid_order_key} == FractionalIndex.generate_key_between("0", "1")
  end

  test "generate_key_between() checks arguments" do
    assert {:error, :invalid_order_key} ==
             FractionalIndex.generate_key_between(nil, "A00000000000000000000000000")

    assert {:error, :invalid_order_key} == FractionalIndex.generate_key_between("a00", nil)
    assert {:error, :invalid_order_key} == FractionalIndex.generate_key_between("a00", "a1")
    assert {:error, :wrong_order} == FractionalIndex.generate_key_between("a1", "a0")
  end
end
