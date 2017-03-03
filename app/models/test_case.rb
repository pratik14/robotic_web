class TestCase < ActiveRecord::Base

  has_many :events, dependent: :destroy
  accepts_nested_attributes_for :events, reject_if: :all_blank, allow_destroy: true

  after_create :verify

  def verify
    robot_file
    ExecuteTestCaseWorker.perform_async(id)
  end

  def robot_file
    default_file_path = "#{Rails.root}/default.robot"
    file = File.open(file_name, 'w+')
    file.puts('*** Settings ***')
    file.puts('Library           Selenium2Library    timeout=10')
    file.puts('Suite Teardown    Close All Browsers')
    file.puts('')
    file.puts('*** Variables ***')
    file.puts('${BROWSER}    phantomjs')
    file.puts('')
    file.puts('*** Test Cases ***')
    file.puts("#{name}")
    events.collect do |event|
      case event.keyword
      when 'record'
        file.puts("    Open Browser  #{event.value}  ${BROWSER}")
        file.puts("    Set Window Size  900  900")
      when 'click'
        file.puts("    Click Element  #{event.locator}")
      when 'change'
        file.puts("    Input Text  #{event.locator}  #{event.value}")
      when 'load'
        file.puts("    Wait For Condition  return document.readyState == 'complete'")
      when 'assertion'
        file.puts("    Element Text Should Be  #{event.locator}   #{event.value}")
      end
    end
    file.close
  end

  def file_name
    "#{name.parameterize.underscore}.robot"
  end
end
