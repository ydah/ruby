# Keep the harness on Prism while exercising the remaining parse.y nodes.

# Rescue and ensure expressions retain parse.y's existing singleton validation.
assert_equal 'true', %q{
  ['begin "s"; rescue; Object.new; end', 'begin "s"; ensure; nil; end'].all? do |receiver|
    RubyVM::InstructionSequence.compile_parsey("def (#{receiver}).f; end")
  end
}

assert_equal '[true, true, true]', %q{
  RubyVM::InstructionSequence.compile_parsey('["literal".freeze.frozen?, (-"literal").frozen?, __FILE__.freeze.frozen?]').eval.inspect
}

assert_equal 'true', %q{
  ['$1 = nil', '$& += "x"', '$1, x = []'].all? do |source|
    begin
      RubyVM::InstructionSequence.compile_parsey(source)
      false
    rescue SyntaxError => error
      error.message.include?("Can't set variable $")
    end
  end
}

assert_equal 'true', %q{
  begin
    RubyVM::InstructionSequence.compile_parsey('def f; yield 1 do; end; end')
    false
  rescue SyntaxError => error
    error.message.include?('block given to yield')
  end
}

assert_equal 'true', %q{
  ['"s"', '1', '1.0', '1r', '1i', '/a/', ':a', '[]', '__FILE__', '__LINE__', '__ENCODING__', '"#{1}"'].all? do |literal|
    begin
      RubyVM::InstructionSequence.compile_parsey("def (#{literal}).f; end")
      false
    rescue SyntaxError => error
      error.message.include?("can't define singleton method for literals")
    end
  end
}
