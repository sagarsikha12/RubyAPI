#/mailers/application_mailer.rb
class ApplicationMailer < ActionMailer::Base
  default from: "awareshare2023@gmail.com"

  layout 'text_mailer', only: [:text]
end
