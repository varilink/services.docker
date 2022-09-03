## General options
set ssl_starttls = no
set ssl_force_tls = no

## Receive options
set folder    = imap://user1fname@imap.home.com/
set imap_user = user1fname
set imap_pass = user1passwd
set spoolfile = +INBOX
mailboxes     = +INBOX
set record    = +Sent

## Send options
set smtp_url  = smtp://smtp.home.com:25
set realname  = 'User 1'
set from      = user1fname.user1lname@home.com
