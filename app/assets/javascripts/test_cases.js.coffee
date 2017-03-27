$(document).on "turbolinks:load", ->
  $('#events').sortable
    start: (event, ui) ->
      start_pos = ui.item.index()
      ui.item.data 'start_pos', start_pos
      ui.item.css('border', '2px dashed blue');
      return
    update: (event, ui) ->
      index = ui.item.index()
      start_pos = ui.item.data('start_pos')
      ui.item.css('border', '2px solid blue');
      if start_pos < index
        i = index + 1
        while i > 0
          $('#events li:nth-child(' + i + ')').find('.test_case_events_order_number input').val i
          i--
      else
        i = index
        while i <= $('#events li').length
          $('#events li:nth-child(' + i + ')').find('.test_case_events_order_number input').val i
          i++
      return
    axis: 'y'

  $('#events').on 'cocoon:after-insert', ->
    $('.test_case_events_keyword_id:last select').val('1')
    $('.test_case_events_keyword_id:last select').trigger('change')
    $('.test_case_events_order_number:last input').val($('ul#events li').length + 1)
    $('#events').sortable('refresh')

  $('form').on 'change', '.test_case_events_keyword_id select',  ->
    that = $(this)
    required_args = keyword_list[that.val()]
    that.closest('.nested-fields').find('.value_fields.form-group').hide()
    $.each required_args, (index, value) ->
      that.closest('.nested-fields').find('.' + value).show()
  $('.test_case_events_keyword_id select').trigger('change')
