class Number < Struct.new(:value)
  
  def to_s
    value.to_s
  end
  
  def inspect
    "«#{self}»"
  end

  def reducible?
    false
  end
  
end

class Boolean < Struct.new(:value)
  
  def to_s
    value.to_s
  end
  
  def inspect
    "«#{self}»"
  end

  def reducible?
    false
  end
  
end

class Add < Struct.new(:left, :right)
  
  def to_s
    "#{left} + #{right}"
  end
  
  def inspect
    "«#{self}»"
  end

  def reducible?
    true
  end
  
  def reduce environment
    if left.reducible?
      Add.new(left.reduce(environment), right)
    elsif right.reducible?
      Add.new(left, right.reduce(environment))
    else
      Number.new(left.value + right.value)
    end  
  end

end

class Multiply < Struct.new(:left, :right)
  
  def to_s
    "#{left} * #{right}"
  end
  
  def inspect
    "«#{self}»"
  end

  def reducible?
    true
  end
  
  def reduce environment
    if left.reducible?
      Multiply.new(left.reduce(environment), right)
    elsif right.reducible?
      Multiply.new(left, right.reduce(environment))
    else
      Number.new(left.value * right.value)
    end
  end

end

class LessThan < Struct.new(:left, :right)

  def to_s
    "#{left} < #{right}"
  end
  
  def inspect
    "«#{self}»"
  end

  def reducible?
    true
  end
  
  def reduce environment
    if left.reducible?
      LessThan.new(left.reduce(environment), right)
    elsif right.reducible?
      LessThan.new(left, right.reduce(environment))
    else
      Boolean.new(left.value < right.value)
    end
  end

end

class Variable < Struct.new(:name)

  def to_s
    "#{name}"
  end
  
  def inspect
    "«#{self}»"
  end

  def reducible?
    true
  end
  
  def reduce environment
    environment[name]
  end

end

class DoNothing
  
  def ==(other)
    other.instance_of?(DoNothing)
  end
  
  def to_s
    "do-nothing"
  end
  
  def inspect
    "«#{self}»"
  end

  def reducible?
    false
  end
  
end

class Assign < Struct.new(:name, :expression)

  def to_s
    "#{name} = #{expression}"
  end

  def inspect
    "«#{self}»"
  end

  def reducible?
    true
  end

  def reduce environment
    if expression.reducible?
      Assign.new(name, expression.reduce(environment))
    else
      DoNothing.new
    end
  end

end


class Machine < Struct.new(:expression, :environment)

  def run
    while expression.reducible?
      puts expression
      step
    end
    puts expression
  end

  def step
    self.expression = expression.reduce(environment)
  end

end


require "test/unit"


class NumberTest < Test::Unit::TestCase
  
  def test_new
    n = Number.new 100
    assert_equal 100, n.value
  end

  def test_to_s
    assert_equal "99", Number.new(99).to_s
  end

  def test_inspect
    assert_equal "«10»", Number.new(10).inspect
  end
  
  def test_number
    assert_false Number.new(100).reducible?
  end
  
end

class AddTest < Test::Unit::TestCase

  def test_add_to_s
    assert_equal "7 + 9", Add.new(Number.new(7), Number.new(9)).to_s
  end

  def test_add_inspect
    assert_equal "«33 + 44»", Add.new(Number.new(33), Number.new(44)).inspect
  end

  def test_add
    a = Add.new(Number.new(1), Number.new(2))
    assert_equal 1, a.left.value
    assert_equal 2, a.right.value
  end
    
  def test_add_multiply
    a = Add.new(Multiply.new(Number.new(1), Number.new(2)),
                Multiply.new(Number.new(3), Number.new(4)))
    assert_equal 1, a.left.left.value
    assert_equal 4, a.right.right.value
  end
  
  def test_add_reducible
    assert_true Add.new(Number.new(100), Number.new(1)).reducible?
  end

  def test_add_reduce_no
    add = Add.new(Number.new(1),
                  Number.new(2))
    assert_equal Number.new(3), add.reduce({})
  end

  def test_add_reduce_left
    add = Add.new(Add.new(Number.new(4), Number.new(2)),
                  Number.new(1))
    
    add_1 = add.reduce({})
    assert_equal Add.new(Number.new(6), Number.new(1)), add_1
    
    add_2 = add_1.reduce({})
    assert_equal Number.new(7), add_2
  end
  
  def test_add_reduce_right
    add = Add.new(Number.new(7),
                  Add.new(Number.new(3), Number.new(1)))

    add_1 = add.reduce({})
    assert_equal Add.new(Number.new(7), Number.new(4)), add_1

    add_2 = add_1.reduce({})
    assert_equal Number.new(11), add_2
  end
  
  def test_add_reduce_left_and_right
    add = Add.new(Add.new(Number.new(1), Number.new(2)),
                  Add.new(Number.new(3), Number.new(4)))

    add_1 = add.reduce({})
    assert_equal Add.new(Number.new(3), Add.new(Number.new(3), Number.new(4))), add_1

    add_2 = add_1.reduce({})
    assert_equal Add.new(Number.new(3), Number.new(7)), add_2

    add_3 = add_2.reduce({})
    assert_equal Number.new(10), add_3
  end

  def test_add_mixed_reduce
    add = Add.new(Add.new(Number.new(1), Number.new(2)),
                  Multiply.new(Number.new(3), Number.new(4)))
    
    add_1 = add.reduce({})
    assert_equal Add.new(Number.new(3), Multiply.new(Number.new(3), Number.new(4))), add_1
    
    add_2 = add_1.reduce({})
    assert_equal Add.new(Number.new(3), Number.new(12)), add_2

    add_3 = add_2.reduce({})
    assert_equal Number.new(15), add_3
  end  
end


class MultiplyTest < Test::Unit::TestCase
  
  def test_multiply
    a = Multiply.new(Number.new(1), Number.new(2))
    assert_equal 1, a.left.value
    assert_equal 2, a.right.value
  end
  
  def test_multiply_to_s
    assert_equal "5 * 2", Multiply.new(Number.new(5), Number.new(2)).to_s
  end

  def test_multiply_inspect
    assert_equal "«12 * 7»", Multiply.new(Number.new(12), Number.new(7)).inspect
  end
  
  def test_multiply_reducible
    assert_true Multiply.new(Number.new(5), Number.new(6)).reducible?
  end

  def test_multiply_reduce_no
    multiply = Multiply.new(Number.new(1), Number.new(2))
    
    assert_equal Number.new(2), multiply.reduce({})
  end

  def test_multiply_reduce_left
    multiply = Multiply.new(Multiply.new(Number.new(4), Number.new(2)),
                            Number.new(1))

    multiply_1 = multiply.reduce({})
    assert_equal Multiply.new(Number.new(8), Number.new(1)), multiply_1

    multiply_2 = multiply_1.reduce({})
    assert_equal Number.new(8), multiply_2
  end
  
  def test_multiply_reduce_right
    multiply = Multiply.new(Number.new(7),
                            Multiply.new(Number.new(3), Number.new(1)))

    multiply_1 = multiply.reduce({})
    assert_equal Multiply.new(Number.new(7), Number.new(3)), multiply_1

    multiply_2 = multiply_1.reduce({})
    assert_equal Number.new(21), multiply_2
  end

  def test_multiply_reduce_left_and_right
    multiply = Multiply.new(Multiply.new(Number.new(1), Number.new(2)),
                            Multiply.new(Number.new(3), Number.new(4)))

    multiply_1 = multiply.reduce({})
    assert_equal Multiply.new(Number.new(2), Multiply.new(Number.new(3), Number.new(4))), multiply_1

    multiply_2 = multiply_1.reduce({})
    assert_equal Multiply.new(Number.new(2), Number.new(12)), multiply_2

    multiply_3 = multiply_2.reduce({})
    assert_equal Number.new(24), multiply_3
  end

  def test_multiply_mixed_reduce
    multiply = Multiply.new(Add.new(Number.new(1), Number.new(2)),
                            Multiply.new(Number.new(3), Number.new(4)))

    multiply_1 = multiply.reduce({})
    assert_equal Multiply.new(Number.new(3),
                              Multiply.new(Number.new(3), Number.new(4))), multiply_1

    multiply_2 = multiply_1.reduce({})
    assert_equal Multiply.new(Number.new(3), Number.new(12)), multiply_2
    
    multiply_3 = multiply_2.reduce({})
    assert_equal Number.new(36), multiply_3
  end
  
end

class MachineTest < Test::Unit::TestCase

  def test_add
    machine = Machine.new(Add.new(Number.new(1),
                                  Add.new(Number.new(2),
                                          Add.new(Number.new(3),
                                                  Number.new(4)))),
                          {})

    out = capture_output { machine.run }[0]
    expected = <<-eos
1 + 2 + 3 + 4
1 + 2 + 7
1 + 9
10
eos
    assert_equal expected, out
    assert_equal Number.new(10), machine.expression
  end

  def test_less_than
    machine = Machine.new(LessThan.new(Add.new(Number.new(1), Number.new(2)),
                                       Add.new(Number.new(3), Number.new(4))),
                          {})

    out = capture_output { machine.run }[0]
    expected = <<-eos
1 + 2 < 3 + 4
3 < 3 + 4
3 < 7
true
eos
    assert_equal expected, out
    assert_equal Boolean.new(true), machine.expression
  end

  def test_variable
    machine = Machine.new(Variable.new(:x),
                          {x: Number.new(100)})

    out = capture_output { machine.run }[0]
    expected = <<-eos
x
100
eos
    assert_equal expected, out
    assert_equal Number.new(100), machine.expression
  end

  def test_add_variables
    machine = Machine.new(Add.new(Variable.new(:x), Variable.new(:y)),
                          {x: Number.new(100), y: Number.new(200)})

    out = capture_output { machine.run }[0]
    expected = <<-eos
x + y
100 + y
100 + 200
300
eos
    assert_equal expected, out
    assert_equal Number.new(300), machine.expression
  end

  def test_assign
    machine = Machine.new(Assign.new(:x, Add.new(Variable.new(:y), Number.new(10))),
                          {y: Number.new(1)})

    out = capture_output { machine.run }[0]
    expected = <<-eos
x = y + 10
x = 1 + 10
x = 11
do-nothing
eos
    assert_equal expected, out
    assert_equal DoNothing.new, machine.expression
  end

end


class BooleanTest < Test::Unit::TestCase
 
  def test_new_true
    assert_equal true, Boolean.new(true).value
  end
  
  def test_new_false
    assert_equal false, Boolean.new(false).value
  end

  def test_to_s
    assert_equal "true", Boolean.new(true).to_s
    assert_equal "false", Boolean.new(false).to_s
  end

  def test_inspect
    assert_equal "«true»", Boolean.new(true).inspect
    assert_equal "«false»", Boolean.new(false).inspect    
  end
  
  def test_number
    assert_false Boolean.new(true).reducible?
    assert_false Boolean.new(false).reducible?
  end
  
end


class LessThanTest < Test::Unit::TestCase

  def test_less_than_new
    lt = LessThan.new(Number.new(7), Number.new(9))
    assert_equal Number.new(7), lt.left
    assert_equal Number.new(9), lt.right
  end

  def test_to_s
    assert_equal "2 < 4", LessThan.new(Number.new(2), Number.new(4)).to_s
    assert_equal "3 < 1", LessThan.new(Number.new(3), Number.new(1)).to_s
  end

  def test_inspect
    assert_equal "«2 < 4»", LessThan.new(Number.new(2), Number.new(4)).inspect
    assert_equal "«3 < 1»", LessThan.new(Number.new(3), Number.new(1)).inspect
  end

  def test_reducible
    lt = LessThan.new(Add.new(Number.new(1), Number.new(1)),
                      Add.new(Number.new(2), Number.new(2)))
    
    assert_true lt.reducible?
  end

  def test_reduce_true
    lt = LessThan.new(Add.new(Number.new(1), Number.new(1)),
                      Add.new(Number.new(2), Number.new(2)))

    lt_1 = lt.reduce({})
    assert_equal LessThan.new(Number.new(2),
                             Add.new(Number.new(2), Number.new(2))), lt_1

    lt_2 = lt_1.reduce({})
    assert_equal LessThan.new(Number.new(2), Number.new(4)), lt_2

    lt_3 = lt_2.reduce({})
    assert_equal Boolean.new(true), lt_3
  end

  def test_reduce_false
    assert_equal Boolean.new(false), LessThan.new(Number.new(5), Number.new(1)).reduce({})
  end

end

class VariableTest < Test::Unit::TestCase
  def test_new
    v = Variable.new :x
    assert_equal :x, v.name
  end

  def test_to_s
    assert_equal "yy", Variable.new(:yy).to_s
  end

  def test_inspect
    assert_equal "«zzz»", Variable.new(:zzz).inspect
  end
  
  def test_reducible
    assert_true Variable.new(:xyz).reducible?
  end
  
  def test_reduce
    assert_equal Number.new(100), Variable.new(:y).reduce({y: Number.new(100)})
    assert_equal Number.new(200), Variable.new(:y).reduce({y: Number.new(200)})
    assert_equal Boolean.new(true), Variable.new(:z).reduce({z: Boolean.new(true)})
  end

end


class DoNothingTest < Test::Unit::TestCase
  def test_new
    dn = DoNothing.new
    assert_equal DoNothing.new, dn
  end

  def test_to_s
    assert_equal "do-nothing", DoNothing.new.to_s
  end

  def test_inspect
    assert_equal "«do-nothing»", DoNothing.new.inspect
  end
  
  def test_reducible
    assert_false DoNothing.new.reducible?
  end

end

class AssignTest < Test::Unit::TestCase
  
  def test_new
    assign = Assign.new(:x, Number.new(100))
    assert_equal :x, assign.name
    assert_equal Number.new(100), assign.expression
  end

  def test_simle_to_s
    assert_equal "y = 200", Assign.new(:y, Number.new(200)).to_s
  end
  
  def test_Add_to_s
    assert_equal "e = 9 + 3", Assign.new(:e, Add.new(Number.new(9), Number.new(3))).to_s
  end

  def test_inspect
    assert_equal "«f = 1 + 1»", Assign.new(:f, Add.new(Number.new(1), Number.new(1))).inspect
  end
  
  def test_reducible
    assert_true Assign.new(:a, Number.new(1)).reducible?
  end

  def test_reducible_complex
    assert_true Assign.new(:b, LessThan.new(Number.new(2), Number.new(1))).reducible?
  end

  def test_reduce_simple
    assert_equal DoNothing.new, Assign.new(:b, Number.new(123)).reduce({})
  end

  def test_reduce_complex
    assign = Assign.new(:c, Add.new(Number.new(123), Number.new(321)))
    
    assign_1 = assign.reduce({})
    assert_equal Assign.new(:c, Number.new(444)), assign_1

    assign_2 = assign_1.reduce({})
    assert_equal DoNothing.new, assign_2
  end

end


_q = "«»"
