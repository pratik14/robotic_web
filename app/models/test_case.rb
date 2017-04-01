  class TestCase < ActiveRecord::Base

  belongs_to :user
  has_many :events, dependent: :destroy
  accepts_nested_attributes_for :events, reject_if: :all_blank, allow_destroy: true

  has_attached_file :source_file
  validates_attachment_content_type :source_file, content_type: ["text/plain", "text/x-r", "text/x-patch", "text/x-diff"]

  validates_associated :events

  before_save :attach_file

  def screenshot
    return '--'  unless failed?
    failed_event.avatar.url
  end

  def failed_event
    events.where(status: 'FAIL').first
  end

  def passed?
    status == 'PASS'
  end

  def failed?
    status == 'FAIL'
  end

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
      keyword = Keyword.find event.keyword_id
      str = event.keyword.name
      keyword.required_args.each do |arg|
        str = str + "  #{event.send(arg.to_sym)}"
      end
      str= str + "  phantomjs" if keyword.name == 'Open Browser'

      if keyword.name.include?('Click')
        file.puts("  Execute Javascript  document.evaluate('#{event.locator}', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.style.border = '5px solid black'")
        file.puts("  Capture Page Screenshot")
      end

      if keyword.name.include?('Input')
        file.puts("  Execute Javascript  document.evaluate('#{event.locator}', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.style.border = '5px solid black'")
      end

      if keyword.name.include?('Wait') && keyword.name != 'Wait For Condition'
        file.puts("  Execute Javascript  document.evaluate('#{event.locator}', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.style.background = 'yellow'")
      end

      file.puts("  #{str}")

      if !keyword.name.include?('Click')
        file.puts("  Capture Page Screenshot")
      end
    end
    file.close
  end

  def file_name
    "#{name.parameterize.underscore}.txt"
  end
end
