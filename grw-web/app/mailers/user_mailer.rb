class UserMailer < ApplicationMailer

  def invitation(user_token)
    @category = user_token.category
    @token    = user_token.email_token
    @email    = user_token.user.email
    @phone    = user_token.user.phone
    @host     = host_for(user_token.user.account)

    mail(to:      @email,
         subject: "Zaproszenie do Example")
  end

  def password_reset(user_token)
    @category = user_token.category
    @token    = user_token.email_token
    @email    = user_token.user.email
    @phone    = user_token.user.phone
    @host     = host_for(user_token.user.account)

    mail(to:      @email,
         subject: "Zmiana hasła w serwisie Example")
  end

end
