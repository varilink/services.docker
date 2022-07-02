## General options
set ssl_starttls = no
set ssl_force_tls = no

## Receive options
set folder    = imap://username2@imap.varilink.co.uk/
set imap_user = username2
set imap_pass = userpass2
set spoolfile = +INBOX
mailboxes     = +INBOX
set record    = +Sent

## Send options
set smtp_url  = smtp://smtp.varilink.co.uk:25
set realname  = 'User 2'
set from      = username2@varilink.co.uk
