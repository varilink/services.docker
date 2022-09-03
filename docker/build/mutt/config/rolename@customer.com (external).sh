# rolename@customer.com connection external to the office network

## IMAP
set folder    = 'imaps://imap.customer.com:993/'
set imap_user = 'rolename@customer.com'
set imap_pass = 'rolepasswd'
set spoolfile = '+INBOX'
mailboxes     = '+INBOX'
set record    = '+Sent'

## SMTP
set smtp_url  = 'smtps://rolename%40customer.com@smtp.customer.com:465'
set smtp_pass = 'rolepasswd'
set realname  = 'Customer user with role email address'
set from      = 'rolename@customer.com'
