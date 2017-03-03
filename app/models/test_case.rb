class TestCase < ActiveRecord::Base

  has_many :events, dependent: :destroy
  accepts_nested_attributes_for :events, reject_if: :all_blank, allow_destroy: true

  has_attached_file :source_file
  validates_attachment_content_type :source_file, content_type: ["text/plain"]

  before_save :attach_file
  after_save :verify

  def verify
    create_source_file
    ExecuteTestCaseWorker.perform_async(id)
  end

  def attach_file
    create_source_file
    self.source_file =  File.open("#{Rails.root}/#{file_name}", 'rb')
  end

  def create_source_file
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
      when 'set_window_size'
        file.puts("    Set Window Size  1200  1200")
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
    "#{name.parameterize.underscore}.txt"
  end
end
