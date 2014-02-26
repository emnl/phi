class Interpreter

  def initialize(ast)
    scope = Scope.new
    exp_list = ast

    eval_exp_list(exp_list, scope)
  end

  def eval_exp(exp, scope)

    if exp[:int]
      return eval_exp_int(exp, scope)
    end

    if exp[:float]
      return eval_exp_float(exp, scope)
    end

    if exp[:bool]
      return eval_exp_bool(exp, scope)
    end

    if exp[:str]
      return eval_exp_str(exp, scope)
    end

    if exp[:id]
      return eval_exp_id(exp, scope)
    end

    if exp[:prio]
      return eval_exp(exp[:prio], scope)
    end

    if exp[:neg]
      return !eval_exp(exp[:neg], scope)
    end

    if exp[:if]
      return eval_exp_if(exp, scope)
    end

    if exp[:while]
      return eval_exp_while(exp, scope)
    end

    if exp[:ass]
      return eval_exp_ass(exp, scope)
    end

    if exp[:binary_operation]
      left = eval_exp(exp[:left], scope)
      app = apply_operations(left, exp[:binary_operation], scope)
      return app
    end

    if exp[:funcall]
      return eval_exp_funccall(exp, scope)
    end

    if exp[:paramlist]
      return eval_exp_funcdef(exp, scope)
    end
  end

  def eval_exp_int(exp, scope)
    return exp[:int].to_i
  end

  def eval_exp_float(exp, scope)
    return exp[:float].to_f
  end

  def eval_exp_bool(exp, scope)
    return exp[:bool] == "true"
  end

  def eval_exp_str(exp, scope)
    return exp[:str].to_s
  end

  def eval_exp_id(exp, scope)
    id = exp[:id].to_s
    raise RuntimeError.new("Variable \"#{id}\" not found.") unless scope.has_var?(id)
    return scope.get_var(id)
  end

  def eval_exp_if(exp, scope)
    cond = eval_exp(exp[:condition], scope)
    if cond
      res = eval_exp_list(exp[:ifexplist], scope)
    elsif exp[:else]
      res = eval_exp_list(exp[:elseexplist], scope)
    end
    return res
  end

  def eval_exp_while(exp, scope)
    cond = eval_exp(exp[:condition], scope)
    while cond
      res = eval_exp_list(exp[:explist], scope)
      cond = eval_exp(exp[:condition], scope)
    end
    return res
  end

  def eval_exp_ass(exp, scope)
    id = exp[:left][:id].to_s
    if exp[:right].has_key?(:paramlist)
      val = exp[:right]
    else
      val = eval_exp(exp[:right], scope)
    end
    scope.set_var(id, val)
    return val
  end

  def eval_exp_funccall(exp, scope)
    id = exp[:funcall][:id].to_s
    if id == "say"
      ret = eval_exp(exp[:arglist], scope)
      puts(ret)
      return ret
    end

    f = scope.get_var(id)
    raise RuntimeError.new("Function \"#{id}\" not found.") unless f && f.has_key?(:paramlist)

    exp[:arglist] = [exp[:arglist]] if exp[:arglist].is_a?(Hash)
    f[:paramlist] = [f[:paramlist]] if f[:paramlist].is_a?(Hash)
    exp[:arglist] = [] unless exp[:arglist]
    f[:paramlist] = [] unless f[:paramlist]

    vars = []
    exp[:arglist].each_index do |i|
      vars[i] = eval_exp(exp[:arglist][i], scope)
    end

    new_scope = Scope.new

    # Add params to scope
    f[:paramlist].each_index do |i|
      idx = f[:paramlist][i][:id].to_s
      new_scope.set_var(idx, vars[i])
    end

    # Add self to scope
    new_scope.set_var(id, scope.get_var(id))

    # Evaluate body
    res = eval_exp_list(f[:explist], new_scope)

    return res
  end

  def eval_exp_funcdef(exp, scope)
    return exp
  end

  def eval_exp_list(explist, scope)
    return nil unless explist.is_a? Array
    res = nil
    explist.each do |exp|
      res = eval_exp(exp, scope)
    end
    return res
  end

  def apply_operations(value, operations, scope)
    operations.each do |op|
      case op[:op]
      when "*"
        value = value * eval_exp(op[:right], scope)
      when "/"
        value = value / eval_exp(op[:right], scope)
      when "+"
        value = value + eval_exp(op[:right], scope)
      when "-"
        value = value - eval_exp(op[:right], scope)
      when "is"
        value = value == eval_exp(op[:right], scope)
      when "isnt"
        value = value != eval_exp(op[:right], scope)
      when "<="
        value = value <= eval_exp(op[:right], scope)
      when ">="
        value = value >= eval_exp(op[:right], scope)
      when ">"
        value = value > eval_exp(op[:right], scope)
      when "<"
        value = value < eval_exp(op[:right], scope)
      when "or"
        value = value || eval_exp(op[:right], scope)
      when "and"
        value = value && eval_exp(op[:right], scope)
      end
    end
    return value
  end
end

class Scope
  def initialize
    @vars = {}
  end

  def get_var(id)
    return @vars[id]
  end

  def has_var?(id)
    return @vars.has_key?(id)
  end

  def set_var(id, val)
    @vars[id] = val
  end
end

class RuntimeError < StandardError
end
