## General options
set ssl_starttls = yes
set ssl_force_tls = yes

## Receive options
set folder    = imaps://user2fname@imap.home.com/
set imap_user = user2fname
set imap_pass = user2passwd
set spoolfile = +INBOX
mailboxes     = +INBOX
set record    = +Sent

## Send options
set smtp_url  = smtps://smtp.home.com
set realname  = 'User 2'
set from      = user2fname.user2lname@home.com
