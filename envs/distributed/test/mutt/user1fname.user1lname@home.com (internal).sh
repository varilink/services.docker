# user1fname.user1lname@home.com connection to the office network

## IMAP
set folder    = 'imap://imap:143/'
set imap_user = 'user1fname'
set imap_pass = 'user1passwd'
set spoolfile = '+INBOX'
mailboxes     = '+INBOX'
set record    = '+Sent'

## SMTP
unset ssl_force_tls
unset ssl_starttls
set smtp_url  = 'smtp://smtp:25'
set realname  = 'Home user 1'
set from      = 'user1fname.user1lname@home.com'
