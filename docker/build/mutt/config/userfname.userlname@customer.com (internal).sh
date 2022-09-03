# userfname.userlname@customer.com connection to the office network

## IMAP
set folder    = 'imaps://imap.customer.com:993/'
set imap_user = 'userfname.userlname@customer.com'
set imap_pass = 'userpasswd'
set spoolfile = '+INBOX'
mailboxes     = '+INBOX'
set record    = '+Sent'

## SMTP
unset ssl_force_tls
unset ssl_starttls
set smtp_url  = 'smtp://smtp:25'
set realname  = 'Customer user with personal email address'
set from      = 'userfname.userlname@customer.com'
