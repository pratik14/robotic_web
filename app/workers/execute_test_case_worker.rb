class ExecuteTestCaseWorker
  include Sidekiq::Worker

  def perform(test_case_id)
    begin
      test_case = TestCase.find test_case_id
      output = system("robot --log none --report none --output #{test_case.file_name}.xml #{test_case.file_name}")
      output = `echo $?`
      # if output == "0\n"
      #   test_case.status = 'passed'
      # else
      #   test_case.status = 'failed'
      # end
      save_result_to_db(test_case)
      test_case.save
    rescue Exception => e
      test_case.status = 'FAIL'
      test_case.message = e
      test_case.save(validate: false)
    end
  end

  def set_test_case_result(hash)
    test_case.status = hash['robot']['suite']['status']['status']
    if test_case.status == 'FAIL'
      test_case.message = hash['robot']['suite']['test']['status']
    end
    test_case.save(validate: false)
  end

  def save_result_to_db(test_case)
    hash = Hash.from_xml(File.read("#{Rails.root}/#{test_case.file_name}.xml"))
    # set_test_case_result(hash)
    hash = hash['robot']['suite']['test']['kw']
    newIndex = -1
    hash.each_with_index do |kw, index|
      unless kw['name'] == 'Capture Page Screenshot'
        newIndex = newIndex + 1
        event = test_case.events[newIndex]
        event.status = kw['status']['status']
        if File.exist?("#{Rails.root}/selenium-screenshot-#{newIndex + 1}.png")
          event.avatar =  File.open("#{Rails.root}/selenium-screenshot-#{newIndex + 1}.png", 'rb')
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
          event.message = kw['msg'].join(',')
        end

        if event.keyword.name == 'Click Element'
          event.message = event.message.to_s + event.text.to_s
        end

        event.save!
      end
    end
  end
end
