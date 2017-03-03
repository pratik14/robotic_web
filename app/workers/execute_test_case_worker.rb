class ExecuteTestCaseWorker
  include Sidekiq::Worker

  def perform(test_case_id)
    begin
      test_case = TestCase.find test_case_id
      output = system("robot --log none --report none --output output.xml #{test_case.file_name}")
      output = `echo $?`
      # if output == "0\n"
      #   test_case.status = 'passed'
      # else
      #   test_case.status = 'failed'
      # end
      save_result_to_db(test_case)
      test_case.save
    rescue Exception => e
      test_case.status = 'failed'
      test_case.message = e
      test_case.save
    end
  end

  def save_result_to_db(test_case)
    hash = Hash.from_xml(File.read("#{Rails.root}/output.xml"))
    test_case.status = hash['robot']['suite']['status']['status']
    if test_case.status == 'FAIL'
      test_case.message = hash['robot']['suite']['test']['status']
    end
    hash = hash['robot']['suite']['test']['kw']
    hash.each_with_index do |kw, index|
      event = test_case.events[index]
      event.status = kw['status']['status']
      if event.status == 'PASS'
        event.message = kw['msg']
      else
        event.message = kw['msg'][1]
      end
      event.save
    end
    test_case.save
  end
end
