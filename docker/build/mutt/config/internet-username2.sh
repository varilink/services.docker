## General options
set ssl_starttls = yes
set ssl_force_tls = yes

## Receive options
set folder    = imaps://username2@imap.varilink.co.uk/
set imap_user = username2
set imap_pass = userpass2
set spoolfile = +INBOX
mailboxes     = +INBOX
set record    = +Sent

## Send options
set smtp_url  = smtps://smtp.varilink.co.uk
set realname  = 'User 2'
set from      = username2@varilink.co.uk
