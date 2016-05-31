class NumberMaster < ActiveRecord::Base

  def self.get_num
    num = self.first
    val = num.now_val + num.steps
    if val > num.max_val
      num.now_val = num.min_val
    else
      num.now_val = val
    end
    num.save
    num.now_val
  end
end
