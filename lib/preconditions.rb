# Modeled after http://docs.guava-libraries.googlecode.com/git/javadoc/com/google/common/base/Preconditions.html
module Preconditions

  def Preconditions.check_argument(expression, error_message=nil)
    if !expression
      raise error_message || "check_argument failed"
    end
    nil
  end

  def Preconditions.check_state(expression, error_message=nil)
    if !expression
      raise error_message || "check_state failed"
    end
    nil
  end

  def Preconditions.check_not_null(reference, error_message=nil)
    if reference.nil?
      raise error_message || "argument cannot be nil"
    end
    reference
  end

end
