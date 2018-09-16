# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

AcctType.create!(code: 'R', description: 'Root', abbreviation: 'Root', home_root: '/')
AcctType.create!(code: 'S', description: 'System user', abbreviation: 'Sys', home_root: '/home/')
AcctType.create!(code: 'A', description: 'Alias', abbreviation: 'Alias', home_root: '/alias/')
AcctType.create!(code: 'V', description: 'Virtual user', abbreviation: '', home_root: '/home/vmail/',
                 uid: 'vmail', gid: 'vmail', transport: 'lmtp:unix:private/dovecot-lmtp')

MailUser.create!(username: 'root', password: 'changeme', acct_type: 'R', admin: 1)
MailUser.create(username: 'postmaster', password_digest: 'x', acct_type: 'A')
MailUser.create(username: 'hostmaster', password_digest: 'x', acct_type: 'A')
MailUser.create(username: 'webmaster', password_digest: 'x', acct_type: 'A')
MailUser.create(username: 'abuse', password_digest: 'x', acct_type: 'A')
MailUser.create(username: 'noc', password_digest: 'x', acct_type: 'A')
MailUser.create(username: 'security', password_digest: 'x', acct_type: 'A')

MailRouting.create!(address_user: 'root', address_domain: '*', recipient: 'root')
MailRouting.create!(address_user: 'admin', address_domain: '*', recipient: 'root')
MailRouting.create!(address_user: 'administrator', address_domain: '*', recipient: 'root')
MailRouting.create!(address_user: 'postmaster', address_domain: '*', recipient: 'postmaster')
MailRouting.create!(address_user: 'hostmaster', address_domain: '*', recipient: 'hostmaster')
MailRouting.create!(address_user: 'webmaster', address_domain: '*', recipient: 'webmaster')
MailRouting.create!(address_user: 'abuse', address_domain: '*', recipient: 'abuse')
MailRouting.create!(address_user: 'noc', address_domain: '*', recipient: 'noc')
MailRouting.create!(address_user: 'security', address_domain: '*', recipient: 'security')
