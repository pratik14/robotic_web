class TestCase < ActiveRecord::Base

  belongs_to :user
  has_many :events, dependent: :destroy
  accepts_nested_attributes_for :events, reject_if: :all_blank, allow_destroy: true

  has_attached_file :source_file
  validates_attachment_content_type :source_file, content_type: ["text/plain", "text/x-r", "text/x-patch", "text/x-diff"]

  validates_associated :events

  before_save :attach_file

  def screenshot
    begin
      failed_event.avatar.url
    rescue 
      return '--'
    end
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
    self.source_file =  File.open(file_path)
  end

  def create_source_file
    file = File.open(file_path, 'w+')
    file.puts('*** Settings ***')
    file.puts('Library           Selenium2Library    timeout=10')
    file.puts('Suite Teardown    Close All Browsers')
    file.puts('')
    file.puts('*** Variables ***')
    file.puts('${BROWSER}    phantomjs')
    file.puts('')
    file.puts('*** Test Cases ***')
    file.puts("#{name}")
    file.puts("  Set Screenshot Directory  #{Rails.root}/tmp/robot_file/#{id}")
    events.collect do |event|
      keyword = Keyword.find event.keyword_id
      str = event.keyword.name
      keyword.required_args.each do |arg|
        str = str + "  #{event.send(arg.to_sym)}"
      end
      str= str + "  phantomjs" if keyword.name == 'Open Browser'

      if keyword.name.include?('Click')
        file.puts(add_css(event.locator))
        file.puts("  Capture Page Screenshot")
      end


      if keyword.name.include?('Wait') && keyword.name != 'Wait For Condition' && !keyword.name.include?('Wait Until Element Is Visible')
        file.puts(add_css(event.locator))
      end

      file.puts("  #{str}")
      if keyword.name.include?('Wait Until Element Is Visible')
        file.puts(add_css(event.locator))
      end

      if keyword.name.include?('Input')
        file.puts(add_css(event.locator))
      end

      if !keyword.name.include?('Click')
        file.puts("  Capture Page Screenshot")
      end
    end
    file.close
  end

  def add_css(locator)
    style = '5px solid black'
    keyword = 'Execute Javascript'
    "  #{keyword}  document.evaluate('#{locator}', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.style.border = '#{style}'"
  end

  def file_path
    dir_path = "#{Rails.root}/tmp/robot_file/#{id}/"
    Dir.mkdir(dir_path) unless File.exists?(dir_path)
    dir_path + file_name
  end

  def file_name
    "#{name.parameterize.underscore}.txt"
  end
end
