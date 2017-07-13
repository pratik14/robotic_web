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
      tese_case.fail
      test_case.message = e
      test_case.save(validate: false)
    end
  end

  def set_test_case_result(test_case, hash)
    test_case.status = hash['robot']['suite']['status']['status']
    if test_case.status == 'FAIL'
      test_case.fail
      test_case.message = hash['robot']['suite']['test']['status']
    else
      test_case.pass
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
      screenshot_path = "#{Rails.root}/tmp/robot_file/#{test_case.id}/selenium-screenshot-#{newIndex}.png"
      if File.exist?(screenshot_path)
        event.avatar =  File.open(screenshot_path, 'rb')
      end
      event.message = event.display_message
      event.save!
      if external_events.include? kw['name']
        newIndex += 1
      end
    end
  end


  def external_events
    [
      "Open Browser", "Click Element", "Input Text", 
      "Mouse Over", "Wait Until Element Contains", 
      "Wait For Condition", "Submit Form", "Select", "Select Checkbox", 
      "Unselect Checkbox"
    ]
  end
end
