module TestCases
  module RobotFile
    extend ActiveSupport::Concern

    def generate
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
      self.events.each do |event|
        statement = self.send(event.trigger.underscore, event)
        file.puts( statement )
      end
      file.close
    end

    def go_to(event)
      str = "\tOpen Browser  #{event.url}  phantomjs\n"
      str.concat("\tSet Window Size  1400  1000\n")
      str.concat("\tCapture Page Screenshot")
    end

    def load(event)
      str = "\tWait For Condition  return document.readyState == 'complete'\n"
      str.concat("\tCapture Page Screenshot")
    end

    def click(event)
      str = scroll_to_locator(event.locator)
      str.concat("\tWait Until Element Is Visible  #{event.locator}\n")
      str.concat("#{add_css(event.locator)}\n")
      str.concat("\tWait Until Element Is Enabled  #{event.locator}\n")
      str.concat("\tCapture Page Screenshot\n")
      str.concat("\tClick Element  #{event.locator}\n")
      str.concat("#{wait_for_ajax}")
    end

    def submit(event)
      str = scroll_to_locator(event.locator)
      str.concat("\tWait Until Element Is Visible  #{event.locator}\n")
      str.concat("#{add_css(event.locator)}\n")
      str.concat("\tCapture Page Screenshot\n")
      str.concat("\tSubmit Form  #{event.locator}\n")
      str.concat("#{wait_for_ajax}")
    end

    def change(event)
      str = scroll_to_locator(event.locator)
      str.concat("\tWait Until Element Is Visible  #{event.locator}\n")
      str.concat("\tWait Until Element Is Enabled  #{event.locator}\n")
      str.concat("\tInput Text  #{event.locator}  #{event.text}\n")
      str.concat("#{add_css(event.locator)}\n")
      str.concat("\tCapture Page Screenshot\n")
      str.concat("#{wait_for_ajax}")
    end

    def mouse_over(event)
      str = scroll_to_locator(event.locator)
      str.concat("\tWait Until Element Is Visible  #{event.locator}\n")
      str.concat("\tWait Until Element Is Enabled  #{event.locator}\n")
      str.concat("\tMouse Over  #{event.locator}\n")
      str.concat("\tCapture Page Screenshot")
    end

    def select(event)
      str = scroll_to_locator(event.locator)
      str.concat("\tWait Until Element Is Visible  #{event.locator}\n")
      str.concat("\tWait Until Element Is Enabled  #{event.locator}\n")
      str.concat("\tSelect From List By Label  #{event.locator}  #{event.text}\n")
      str.concat("\tCapture Page Screenshot")
    end

    def checkbox(event)
      str = scroll_to_locator(event.locator)
      str.concat("\tWait Until Element Is Visible  #{event.locator}\n")
      str.concat("\tWait Until Element Is Enabled  #{event.locator}\n")
      if event.text
        str.concat("\tSelect Checkbox  #{event.locator}\n")
      else
        str.concat("\tUnselect Checkbox  #{event.locator}\n")
      end
      str.concat("\tCapture Page Screenshot")
    end

    def assert(event)
      str = scroll_to_locator(event.locator)
      str.concat("\tWait Until Page Contains Element  #{event.locator}\n")
      str.concat("#{add_css(event.locator)}\n")
      str.concat("\tCapture Page Screenshot\n")
      str.concat("\tWait Until Element Contains  #{event.locator}  #{event.text}")
    end

    def add_css(locator)
      style = '5px solid black'
      str = "\tExecute Javascript\n"
      str.concat("\t\t...   var element = document.evaluate( '#{locator}' ,document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null ).singleNodeValue;\n")
      str.concat("\t\t...   if (element != null) {\n")
      str.concat("\t\t...     element.style.border = '#{style}';\n")
      str.concat("\t\t...   }\n")
    end

    def wait_for_ajax
      str = "\t: FOR    ${INDEX}    IN RANGE    1    5000\n"
      str.concat("\t\\    ${IsAjaxComplete}    Execute JavaScript    return window.jQuery!=undefined && jQuery.active==0\n")
      str.concat("\t\\    Run Keyword If    ${IsAjaxComplete}==True    Exit For Loop")
    end

    def scroll_to_locator(locator)
      str = "\tExecute Javascript\n"
      str.concat("\t\t...   var element = document.evaluate( '#{locator}' ,document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null ).singleNodeValue;\n")
      str.concat("\t\t...   if (element != null) {\n")
      str.concat("\t\t...     $(element)[0].scrollIntoView( true )\n")
      str.concat("\t\t...   }\n")
    end
  end
end

