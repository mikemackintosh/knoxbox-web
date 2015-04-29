class Log < ActiveRecord::Base
  def icon
    case category
      when 'download'
        'arrow-circle-down'
      when 'login'
        'coffee'
      when 'security'
        'lock'
      when 'certificate-create'
        'certificate'
      when 'certificate-revoke'
        'bomb'
      when 'token-changed'
        'warning'
      when 'token-test'
        'thumbs-up'
      when 'updated-password'
        'user-secret'
      when 'password-test'
        'thumbs-up'
      when 'update'
        'pencil'         
      else
        'briefcase'
    end
  end
end