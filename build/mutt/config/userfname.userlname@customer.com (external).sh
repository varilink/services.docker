# userfname.userlname@customer.com connection external to the office network

## IMAP
set folder    = 'imaps://imap.customer.com:993/'
set imap_user = 'userfname.userlname@customer.com'
set imap_pass = 'userpasswd'
set spoolfile = '+INBOX'
mailboxes     = '+INBOX'
set record    = '+Sent'

## SMTP
set smtp_url  = 'smtps://userfname.userlname%40customer.com@smtp.customer.com:465'
set smtp_pass = 'userpasswd'
set realname  = 'Customer user with personal email address'
set from      = 'userfname.userlname@customer.com'
