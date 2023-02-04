# ------------------------------------------------------------------------------
# envs/to-be/test/mutt/user1fname.user1lname@home.com (internal).sh
# ------------------------------------------------------------------------------

# Mutt configuration file for the user user1fname.user1lname@home.com making a
# connection from an email client that is internal to the office network.
# Since user1fname is the admin user the password used for IMAP authentication
# must match that set in:
# build/sshd/Dockerfile


# IMAP
set folder    = 'imap://imap:143/'
set imap_user = 'user1fname'
set imap_pass = 'user1passwd'
set spoolfile = '+INBOX'
mailboxes     = '+INBOX'
set record    = '+Sent'

# SMTP
unset ssl_force_tls
unset ssl_starttls
set smtp_url  = 'smtp://smtp:25'
set realname  = 'Home user 1'
set from      = 'user1fname.user1lname@home.com'
