# ------------------------------------------------------------------------------
# envs/to-be/test/mutt/userfname.userlname@customer.com (internal).sh
# ------------------------------------------------------------------------------

# Mutt configuration file for the user userfname.userlname@customer.com making a
# connection from an email client that is internal to the office network.
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
unset ssl_force_tls
unset ssl_starttls
set smtp_url  = 'smtp://smtp:25'
set realname  = 'Customer user with personal email address'
set from      = 'userfname.userlname@customer.com'
