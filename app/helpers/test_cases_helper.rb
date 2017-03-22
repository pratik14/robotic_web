module TestCasesHelper

  def get_class(keyword, field)
    args = keyword.required_args
    args.include?(field) ? '' : 'hidden'
  end

end
