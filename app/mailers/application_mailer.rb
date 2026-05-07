# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@bodimetrix.com'
  layout 'mailer'
end
