# ------------------------------------------------------------------------------
# envs/to-be/test/mutt/userfname.userlname@customer.com (external).sh
# ------------------------------------------------------------------------------

# Mutt configuration file for the user userfname.userlname@customer.com making a
# connection from an email client that is external to the office network.
# Password used for IMAP and SMTP connection must match that set for the user
# in:
# envs/to-be/playbooks/customer/group_vars/all/public.yml

# IMAP
set folder    = 'imaps://imap.customer.com:993/'
set imap_user = 'userfname.userlname@customer.com'
set imap_pass = '3cH73#!q@jjbm@&m'
set spoolfile = '+INBOX'
mailboxes     = '+INBOX'
set record    = '+Sent'

# SMTP
set smtp_url  = 'smtps://userfname.userlname%40customer.com@smtp.customer.com:465'
set smtp_pass = '3cH73#!q@jjbm@&m'
set realname  = 'Customer user with personal email address'
set from      = 'userfname.userlname@customer.com'
