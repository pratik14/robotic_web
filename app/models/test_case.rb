class TestCase < ActiveRecord::Base

  belongs_to :user
  has_many :events, dependent: :destroy
  accepts_nested_attributes_for :events, reject_if: :all_blank, allow_destroy: true

  has_attached_file :source_file
  validates_attachment_content_type :source_file, content_type: ["text/plain", "text/x-r", "text/x-patch", "text/x-diff"]

  validates_associated :events

  #before_save :attach_file

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
      case event.trigger
      when 'GoTo'
        file.puts("  Open Browser  #{event.url}  phantomjs")
        file.puts("  Set Window Size  1200  800")
        file.puts("  Capture Page Screenshot")
      when 'Load'
        file.puts("  Wait For Condition  return document.readyState == 'complete'")
      when 'Click'
        file.puts("  Wait Until Element Is Visible  #{event.locator}")
        file.puts(add_css(event.locator))
        file.puts("  Wait Until Element Is Enabled  #{event.locator}")
        file.puts("  Capture Page Screenshot")
        file.puts("  Click Element  #{event.locator}")
        file.puts(wait_for_ajax)
      when 'Change'
        file.puts("  Wait Until Element Is Visible  #{event.locator}")
        file.puts("  Wait Until Element Is Enabled  #{event.locator}")
        file.puts("  Input Text  #{event.locator}  #{event.text}")
        file.puts(add_css(event.locator))
        file.puts("  Capture Page Screenshot")
        file.puts(wait_for_ajax)
      when 'Hover'
        file.puts("  Wait Until Element Is Visible  #{event.locator}")
        file.puts("  Wait Until Element Is Enabled  #{event.locator}")
        file.puts("  Mouse Over  #{event.locator}")
      when 'page_contains'
        file.puts("  Page Should Contain  #{event.text}")
      end
    end
    file.close
  end

  def add_css(locator)
    style = '5px solid black'
    "  Execute Javascript 
       ...   var element = document.evaluate( '#{locator}' ,document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null ).singleNodeValue;
       ...   if (element != null) {
       ...     element.style.border = '#{style}';
       ...   }
    "
  end

  def wait_for_ajax
    "  : FOR    ${INDEX}    IN RANGE    1    5000
  \\    ${IsAjaxComplete}    Execute JavaScript    return window.jQuery!=undefined && jQuery.active==0
  \\    Run Keyword If    ${IsAjaxComplete}==True    Exit For Loop"
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
