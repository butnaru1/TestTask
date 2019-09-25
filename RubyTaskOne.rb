require 'watir'
require 'webdrivers'

# Initalize the Browser
browser = Watir::Browser.new :chrome

# Navigate to Page
browser.goto 'https://wb.micb.md'

# Authenticate to the Form
browser.text_field(name: 'login').set 'oleg_butnaru'
browser.text_field(name: 'password').set 'mypassword'
browser.button(text: 'Autentificare').click

# 10s Pause
sleep(10)
browser.close