# username1@varilink.co.uk connecting to IMAP and SMPT via the Internet

## General options
set ssl_starttls = yes
set ssl_force_tls = yes

## Receive options
set folder    = imaps://username1@imap.customer.com/
set imap_user = username1
set imap_pass = userpass1
set spoolfile = +INBOX
mailboxes     = +INBOX
set record    = +Sent

## Send options
set smtp_url  = smtps://smtp.customer.com
set realname  = 'User 1'
set from      = username1@customer.com
