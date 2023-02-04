# ------------------------------------------------------------------------------
# envs/to-be/test/mutt/rolename@customer.com (external).sh
# ------------------------------------------------------------------------------

# Mutt configuration file for the user rolename@customer.com making a connection
# from an email client that is external to the office network. Password used for
# IMAP and SMTP connection must match that set for the user in:
# envs/to-be/playbooks/customer/group_vars/all/public.yml

# IMAP
set folder    = 'imaps://imap.customer.com:993/'
set imap_user = 'rolename@customer.com'
set imap_pass = 'fS931Q!RxMqX0HUI'
set spoolfile = '+INBOX'
mailboxes     = '+INBOX'
set record    = '+Sent'

# SMTP
set smtp_url  = 'smtps://rolename%40customer.com@smtp.customer.com:465'
set smtp_pass = 'fS931Q!RxMqX0HUI'
set realname  = 'Customer user with role email address'
set from      = 'rolename@customer.com'
