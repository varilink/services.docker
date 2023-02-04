# ------------------------------------------------------------------------------
# envs/live/test/mutt/user2fname.user2lname@home.com (internal).sh
# ------------------------------------------------------------------------------

# Mutt configuration file for the user user2fname.user2lname@home.com making a
# connection from an email client that is internal to the office network.
# Password used for IMAP connection must match that set for the user in:
# envs/live/playbooks/home/group_vars/all.yml

# IMAP
set folder    = 'imap://imap:143/'
set imap_user = 'user2fname'
set imap_pass = 't7515%8*MixUyR7o'
set spoolfile = '+INBOX'
mailboxes     = '+INBOX'
set record    = '+Sent'

# SMTP
unset ssl_force_tls
unset ssl_starttls
set smtp_url  = 'smtp://smtp:25'
set realname  = 'Home user 2'
set from      = 'user2fname.user2lname@home.com'
