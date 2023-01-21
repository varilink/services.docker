# ------------------------------------------------------------------------------
# build/mutt/config/userfname.userlname@customer.com (external).sh
# ------------------------------------------------------------------------------

# Mutt configuration file for the user userfname.userlname@customer.com making a
# connection from an email client that is external to the office network. Note
# that the password used for both IMAP and SMTP connection must match that set
# in envs/[env]/playbooks/customer/group_vars/all.yml vars files, where [env] is
# one of "live", "to-be" or "distributed".

## IMAP
set folder    = 'imaps://imap.customer.com:993/'
set imap_user = 'userfname.userlname@customer.com'
set imap_pass = 'dN398*gDd00O7@6V'
set spoolfile = '+INBOX'
mailboxes     = '+INBOX'
set record    = '+Sent'

## SMTP
set smtp_url  = 'smtps://userfname.userlname%40customer.com@smtp.customer.com:465'
set smtp_pass = 'dN398*gDd00O7@6V'
set realname  = 'Customer user with personal email address'
set from      = 'userfname.userlname@customer.com'
