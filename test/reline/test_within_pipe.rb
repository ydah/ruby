require_relative 'helper'

class Reline::WithinPipeTest < Reline::TestCase
  def setup
    Reline.send(:test_mode)
    @encoding = Reline.core.encoding
    @input_reader, @writer = IO.pipe(@encoding)
    Reline.input = @input_reader
    @reader, @output_writer = IO.pipe(@encoding)
    @output = Reline.output = @output_writer
    @config = Reline.core.config
    @config.keyseq_timeout *= 600 if defined?(RubyVM::RJIT) && RubyVM::RJIT.enabled? # for --jit-wait CI
    @line_editor = Reline.core.line_editor
  end

  def teardown
    Reline.input = STDIN
    Reline.output = STDOUT
    Reline.point = 0
    Reline.delete_text
    @input_reader.close
    @writer.close
    @reader.close
    @output_writer.close
    @config.reset
    Reline.test_reset
  end

  def test_simple_input
    @writer.write("abc\n")
    assert_equal 'abc', Reline.readmultiline(&proc{ true })
  end

  def test_unknown_macro
    @config.add_default_key_binding('abc'.bytes, :unknown_macro)
    @writer.write("abcd\n")
    assert_equal 'd', Reline.readmultiline(&proc{ true })
  end

  def test_macro_commands_for_moving
    @config.add_default_key_binding("\C-x\C-a".bytes, :beginning_of_line)
    @config.add_default_key_binding("\C-x\C-e".bytes, :end_of_line)
    @config.add_default_key_binding("\C-x\C-f".bytes, :forward_char)
    @config.add_default_key_binding("\C-x\C-b".bytes, :backward_char)
    @config.add_default_key_binding("\C-x\ef".bytes, :forward_word)
    @config.add_default_key_binding("\C-x\eb".bytes, :backward_word)
    @writer.write(" def\C-x\C-aabc\C-x\C-e ghi\C-x\C-a\C-x\C-f\C-x\C-f_\C-x\C-b\C-x\C-b_\C-x\C-f\C-x\C-f\C-x\C-f\C-x\ef_\C-x\eb\n")
    assert_equal 'a_b_c def_ ghi', Reline.readmultiline(&proc{ true })
  end

  def test_macro_commands_for_editing
    @config.add_default_key_binding("\C-x\C-d".bytes, :delete_char)
    @config.add_default_key_binding("\C-x\C-h".bytes, :backward_delete_char)
    @config.add_default_key_binding("\C-x\C-v".bytes, :quoted_insert)
    #@config.add_default_key_binding("\C-xa".bytes, :self_insert)
    @config.add_default_key_binding("\C-x\C-t".bytes, :transpose_chars)
    @config.add_default_key_binding("\C-x\et".bytes, :transpose_words)
    @config.add_default_key_binding("\C-x\eu".bytes, :upcase_word)
    @config.add_default_key_binding("\C-x\el".bytes, :downcase_word)
    @config.add_default_key_binding("\C-x\ec".bytes, :capitalize_word)
    @writer.write("abcde\C-b\C-b\C-b\C-x\C-d\C-x\C-h\C-x\C-v\C-a\C-f\C-f EF\C-x\C-t gh\C-x\et\C-b\C-b\C-b\C-b\C-b\C-b\C-b\C-b\C-x\eu\C-x\el\C-x\ec\n")
    assert_equal "a\C-aDE gh Fe", Reline.readmultiline(&proc{ true })
  end

  def test_delete_text_in_multiline
    @writer.write("abc\ndef\nxyz\n")
    result = Reline.readmultiline(&proc{ |str|
      if str.include?('xyz')
        Reline.delete_text
        true
      else
        false
      end
    })
    assert_equal "abc\ndef", result
  end
end
