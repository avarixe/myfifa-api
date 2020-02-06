# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'MyFIFA Manager <myfifa@jhyuk.com>'
  layout 'mailer'
end
