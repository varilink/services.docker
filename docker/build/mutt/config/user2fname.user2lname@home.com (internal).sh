## General options
set ssl_starttls = no
set ssl_force_tls = no

## Receive options
set folder    = imap://user2fname@imap.home.com/
set imap_user = user2fname
set imap_pass = user2passwd
set spoolfile = +INBOX
mailboxes     = +INBOX
set record    = +Sent

## Send options
set smtp_url  = smtp://smtp.home.com:25
set realname  = 'User 2'
set from      = user2fname.user2lname@home.com
