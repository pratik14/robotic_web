class ExecuteTestCaseWorker
  include Sidekiq::Worker

  def perform(test_case_id)
    begin
      test_case = TestCase.find test_case_id
      output = system("robot --log none --report none --output #{test_case.file_path}.xml #{test_case.file_path}")
      output = `echo $?`
      save_result_to_db(test_case)
      test_case.save
    rescue Exception => e
      test_case.status = 'FAIL'
      test_case.message = e
      test_case.save(validate: false)
    end
  end

  def set_test_case_result(test_case, hash)
    test_case.status = hash['robot']['suite']['status']['status']
    if test_case.status == 'FAIL'
      test_case.message = hash['robot']['suite']['test']['status']
    end
    test_case.save(validate: false)
  end

  def save_result_to_db(test_case)
    hash = Hash.from_xml(File.read("#{test_case.file_path}.xml"))
    set_test_case_result(test_case, hash)
    hash = hash['robot']['suite']['test']['kw']
    newIndex = 0
    hash.each_with_index do |kw, index|
      event = test_case.events[newIndex]
      event.status = kw['status']['status']
      screenshot_path = "#{Rails.root}/tmp/robot_file/#{test_case.id}/selenium-screenshot-#{newIndex + 1}.png"
      if File.exist?(screenshot_path)
        event.avatar =  File.open(screenshot_path, 'rb')
      end
      if event.status == 'FAIL'
        event.message = 
          if event.trigger == 'Change'
            "Element with locator: #{event.locator} not found"
          else
            "Element with text: #{event.text} not found"
          end
      else
        event.message = 
          case event.trigger
          when 'GoTo'
            "Open Browser #{event.url}"
          when 'Load'
            "Wait till page get loaded"
          when 'Click'
            "Click element with text: #{event.text}"
          when 'Submit'
            "Submit form"
          when 'Change'
            "Change text to: #{event.text}"
          when 'MouseOver'
            "MouseOver text: #{event.text}"
          when 'Assert'
            "Page should contain: #{event.text}"
          end
      end

      event.save!
      if external_events.include? kw['name']
        newIndex = newIndex + 1
      end
    end
  end


  def external_events
    ["Open Browser", "Click Element", "Input Text", "Mouse Over", "Wait Until Element Contains", "Wait For Condition", "Submit Form"]
  end
end
