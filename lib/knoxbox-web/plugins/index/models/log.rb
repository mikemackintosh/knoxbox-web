class Log < ActiveRecord::Base
  def icon
    case category
      when 'download'
        'file'
      when 'login'
        'coffee'
      when 'security'
        'lock'   
      when 'update'
        'pencil'         
      else
        'briefcase'
    end
  end
end