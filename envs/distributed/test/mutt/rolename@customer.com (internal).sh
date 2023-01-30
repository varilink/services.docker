# rolename@customer.com connection to the office network

## IMAP
set folder    = 'imaps://imap.customer.com:993/'
set imap_user = 'rolename@customer.com'
set imap_pass = 'rolepasswd'
set spoolfile = '+INBOX'
mailboxes     = '+INBOX'
set record    = '+Sent'

## SMTP
unset ssl_force_tls
unset ssl_starttls
set smtp_url  = 'smtp://smtp:25'
set realname  = 'Customer user with role email address'
set from      = 'rolename@customer.com'
