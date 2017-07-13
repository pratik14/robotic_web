module TestCasesHelper

  def get_class(keyword, field)
    args = keyword.required_args
    args.include?(field) ? '' : 'hidden'
  end

  def status_badge(status)
    badge = 'test-status label label-'
    mapping = { pending: 'primary', running: 'warning', pass: 'success', fail: 'danger' }
    return badge + mapping[status.to_sym]
  end
end
