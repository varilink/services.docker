# user2fname.user2lname@home.com connection to the office network

## IMAP
set folder    = 'imap://imap:143/'
set imap_user = 'user2fname'
set imap_pass = 'user2passwd'
set spoolfile = '+INBOX'
mailboxes     = '+INBOX'
set record    = '+Sent'

## SMTP
unset ssl_force_tls
unset ssl_starttls
set smtp_url  = 'smtp://smtp:25'
set realname  = 'Home user 2'
set from      = 'user2fname.user2lname@home.com'
