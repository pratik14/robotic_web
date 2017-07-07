module Events
  module Message
    extend ActiveSupport::Concern

    def display_message
      self.pass? ? success_msgs : fail_msgs
    end

    def fail_msgs
      if trigger == 'Change'
        "Element with locator: #{self.locator} not found"
      else
        "Element with text: #{self.text} not found"
      end
    end

    def success_msgs
      case self.trigger
      when 'GoTo'
        "Open Browser #{self.url}"
      when 'Load'
        "Wait till page get loaded"
      when 'Click'
        "Click element with text: #{self.text}"
      when 'Submit'
        "Submit form"
      when 'Change'
        "Change text to: #{self.text}"
      when 'MouseOver'
        "MouseOver text: #{self.text}"
      when 'Assert'
        "Page should contain: #{self.text}"
      when 'Select'
        "Select option with : #{self.text}"
      when 'Checkbox'
        if self.text
          "Select Checkbox"
        else
          "Unselect Checkbox"
        end
      end
    end
  end
end
