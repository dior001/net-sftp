# frozen_string_literal: true

require "common"

class ErrorsTest < Net::SFTP::TestCase
  ExampleResponse = Struct.new(:code, :message)

  def test_message_includes_text_and_description_when_message_present
    response = ExampleResponse.new(4, "Failure")
    exception = Net::SFTP::StatusException.new(response, "while doing something")

    assert_equal 4, exception.code
    assert_equal "Failure", exception.description
    assert_equal "while doing something", exception.text
    assert_equal response, exception.response
    assert_equal 'Net::SFTP::StatusException while doing something (4, "Failure")', exception.message
  end

  def test_message_falls_back_to_status_code_description_when_response_message_is_blank
    response = ExampleResponse.new(4, "")
    exception = Net::SFTP::StatusException.new(response)

    assert_equal "failure", exception.description
    assert_nil exception.text
    assert_equal 'Net::SFTP::StatusException (4, "failure")', exception.message
  end

  def test_message_falls_back_to_status_code_description_when_response_message_is_nil
    response = ExampleResponse.new(4, nil)
    exception = Net::SFTP::StatusException.new(response)

    assert_equal "failure", exception.description
  end
end
