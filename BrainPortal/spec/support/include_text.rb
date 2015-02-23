module RSpec::Rails
  module Matchers
    RSpec::Matchers.define :include_text do |expected_text|
      match do |response_or_text|
        @actual_text = response_or_text.respond_to?(:body) ? response_or_text.body : response_or_text
        @actual_text = @actual_text.to_s
        if expected_text.is_a?(Regexp)
          @actual_text =~ expected_text
        else
          @actual_text.include?(expected_text.to_s)
        end
      end

      failure_message do
        "expected '#{@actual_text}' to contain '#{expected_text}'"
      end

      failure_message_when_negated do
        "expected #{@actual_text} to not contain '#{expected_text}'"
      end
    end
  end
end


