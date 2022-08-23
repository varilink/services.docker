## General options
set ssl_starttls = no
set ssl_force_tls = no

## Receive options
set folder    = imap://username1@imap.varilink.co.uk/
set imap_user = username1
set imap_pass = userpass1
set spoolfile = +INBOX
mailboxes     = +INBOX
set record    = +Sent

## Send options
set smtp_url  = smtp://smtp.varilink.co.uk:25
set realname  = 'User 1'
set from      = username1@varilink.co.uk
