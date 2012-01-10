class ValidationFailed < StandardError ; end

def validate(msg)
  print "#{msg}: "
  begin
    if yield
      puts "[ " + bgreen("Pass") + " ]"
    else
      raise ValidationFailed, ''
    end
  rescue ValidationFailed => fail
    puts "[ " + red("Failed") + " ] " + bwhite(fail.message)
  end
end

def passed(msg = nil)
  true
end

def failed(msg = '')
  raise ValidationFailed, msg
end