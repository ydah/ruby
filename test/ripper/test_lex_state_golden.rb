# frozen_string_literal: true

begin
  require 'digest/sha2'
  require 'ripper'
  require 'test/unit'
  module TestRipper; end
rescue LoadError
end

class TestRipper::LexStateGolden < Test::Unit::TestCase
  SOURCE = <<~'RUBY'
    class Sample
      def self.call(value, label: :default, **options)
        mapped = value&.map { |item| item + options[:offset] }
        message = <<~TEXT
          #{label}: #{mapped&.join(",")}
        TEXT
        [mapped, message]
      end
    end

    Sample.call 1, label: "one"
  RUBY

  EXPECTED_TOKEN_COUNT = 102
  EXPECTED_SHA256 = '51a803034d19a34aaf10df923763baa86dfc294c25e0ca6e2b9ee6af2db6036b'

  def test_token_state_snapshot
    tokens = Ripper.lex(SOURCE)
    snapshot = tokens.map do |(line, column), event, token, state|
      [line, column, event, token, state.to_i].inspect
    end.join("\n")

    assert_equal EXPECTED_TOKEN_COUNT, tokens.size
    assert_equal EXPECTED_SHA256, Digest::SHA256.hexdigest(snapshot)
  end
end
