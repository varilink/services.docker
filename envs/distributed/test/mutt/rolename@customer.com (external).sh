# ------------------------------------------------------------------------------
# build/mutt/config/rolename@customer.com (external).sh
# ------------------------------------------------------------------------------

# Mutt configuration file for the user rolename@customer.com making a connection
# from an email client that is external to the office network. Note that the
# password used for both IMAP and SMTP connection must match that set in
# envs/[env]/playbooks/customer/group_vars/all.yml vars files, where [env] is
# one of "live", "to-be" or "distributed".

## IMAP
set folder    = 'imaps://imap.customer.com:993/'
set imap_user = 'rolename@customer.com'
set imap_pass = 'V8m89r%D#Q&oq41y'
set spoolfile = '+INBOX'
mailboxes     = '+INBOX'
set record    = '+Sent'

## SMTP
set smtp_url  = 'smtps://rolename%40customer.com@smtp.customer.com:465'
set smtp_pass = 'V8m89r%D#Q&oq41y'
set realname  = 'Customer user with role email address'
set from      = 'rolename@customer.com'
