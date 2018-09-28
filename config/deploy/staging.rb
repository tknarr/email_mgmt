# Server roles
# ============

server 'email_mgmt_deploy@dev1.silverglass-tech.com', roles: %i[app db], database_admin: true


# Configuration
# =============


# Custom SSH Options
# ==================

# Global options
# --------------
set :ssh_options,
    keys: %w[/home/tknarr/.ssh/id_awsdev],
    auth_methods: %w[publickey],
    forward_agent: true
