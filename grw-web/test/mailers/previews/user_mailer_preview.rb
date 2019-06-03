# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  def invitation
    token = UserToken.active.invitations.first
    UserMailer.invitation(token)
  end

  def password_reset
    token = UserToken.active.password_resets.first
    UserMailer.password_reset(token)
  end

end
