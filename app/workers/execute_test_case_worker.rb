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
    newIndex = -1
    hash.each_with_index do |kw, index|
      unless exlcuded_events.include? kw['name']
        newIndex = newIndex + 1
        event = test_case.events[newIndex]
        event.status = kw['status']['status']
        screenshot_path = "#{Rails.root}/tmp/robot_file/#{test_case.id}/selenium-screenshot-#{newIndex + 1}.png"
        if File.exist?(screenshot_path)
          event.avatar =  File.open(screenshot_path, 'rb')
        end
        if event.status == 'PASS'
          event.message = kw['msg']
          if event.message.blank?
            doc = kw['doc']
            args = [kw['arguments']['arg']].flatten
            args.each do |arg|
              doc = doc.sub(/`[a-z]*`/, arg)
            end
            event.message = doc
          end
        else
          event.message = [kw['msg']].flatten.join(',')
        end

        if event.keyword.name == 'Click Element'
          event.message = event.message.to_s + event.text.to_s
        end

        event.save!
      end
    end
  end


  def exlcuded_events
    ['Capture Page Screenshot', 'Execute Javascript', 'Set Screenshot Directory', 'Set Window Size', 'Set Selenium Implicit Wait']
  end
end
