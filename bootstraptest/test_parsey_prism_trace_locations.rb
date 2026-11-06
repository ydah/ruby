assert_equal '[[:end, 5], [:return, 4]]', %q{
  events = []
  trace = TracePoint.new(:end, :return) do |event|
    events << [event.event, event.lineno] if event.path == 'parsey-trace.rb'
  end
  code = RubyVM::InstructionSequence.compile_parsey(<<~'RUBY', 'parsey-trace.rb')
    class ParseyTraceLocation
      def value
        1
      end
    end
    ParseyTraceLocation.new.value
  RUBY
  trace.enable { code.eval }
  events.inspect
}

assert_equal '1', %q{
  RubyVM::InstructionSequence.compile_parsey(<<~'RUBY').eval
    def parsey_rescue_location
      raise
    rescue
      caller_locations(1, 1)[0]
    end
    parsey_rescue_location.lineno
  RUBY
}
