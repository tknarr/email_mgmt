# Server roles
# ============

server 'dev1.silverglass-tech.com', roles: %{web app db}


# Configuration
# =============


# Custom SSH Options
# ==================

# Global options
# --------------
set :ssh_options,
    keys_only: true,
    keys: %w[/home/tknarr/.ssh/id_awsdev],
    forward_agent: false,
    auth_methods: %w[publickey],
