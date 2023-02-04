# ------------------------------------------------------------------------------
# envs/to-be/test/mutt/rolename@customer.com (internal).sh
# ------------------------------------------------------------------------------

# Mutt configuration file for the user rolename@customer.com making a connection
# from an email client that is internal to the office network. Password used for
# IMAP connection must match that set for the user in:
# envs/to-be/playbooks/customer/group_vars/all/public.yml

# IMAP
set folder    = 'imaps://imap.customer.com:993/'
set imap_user = 'rolename@customer.com'
set imap_pass = 'fS931Q!RxMqX0HUI'
set spoolfile = '+INBOX'
mailboxes     = '+INBOX'
set record    = '+Sent'

# SMTP
unset ssl_force_tls
unset ssl_starttls
set smtp_url  = 'smtp://smtp:25'
set realname  = 'Customer user with role email address'
set from      = 'rolename@customer.com'
