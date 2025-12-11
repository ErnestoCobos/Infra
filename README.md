# Infrastructure

Infrastructure as Code repository containing Ansible playbooks, Terraform modules, and automation workflows.

## 📁 Structure

```
├── ansible/              # Ansible configuration and playbooks
│   ├── inventory/        # Host inventory files
│   ├── playbooks/        # Ansible playbooks
│   ├── roles/            # Reusable roles
│   └── requirements.yml  # Ansible Galaxy requirements
├── terraform/            # Terraform modules (WIP)
├── scripts/              # Utility scripts
└── .github/workflows/    # GitHub Actions workflows
```

## 🚀 Quick Start

### Prerequisites

- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) >= 2.15
- [Tailscale](https://tailscale.com/) for secure network access
- SSH key configured for target servers

### Local Usage

```bash
# Install Ansible collections
cd ansible
ansible-galaxy collection install -r requirements.yml

# Run update check
ansible-playbook playbooks/update.yml --check --diff

# Apply updates
ansible-playbook playbooks/update.yml
```

### CLI Tool

```bash
# Check for updates (smart mode)
./scripts/server-update.sh smart

# Only check what updates are available
./scripts/server-update.sh check

# Apply updates with reboot
./scripts/server-update.sh apply-reboot

# Download logs from last run
./scripts/server-update.sh logs
```

## 🔄 Automated Workflows

### Server Updates (Weekly - Mondays 6am UTC)

The `server-updates.yml` workflow runs in **smart mode**:
1. Checks for available updates
2. If reboot is **NOT required** → applies updates automatically
3. If reboot **IS required** → sends email notification for manual action

#### Execution Modes

| Mode | Description |
|------|-------------|
| `smart` | Check first. Apply only if no reboot needed (default) |
| `check` | Only check what updates are available |
| `apply` | Apply updates without reboot |
| `apply-reboot` | Apply updates AND reboot if needed |

## 🔐 Required Secrets

Configure these in GitHub repository settings:

| Secret | Description |
|--------|-------------|
| `SSH_PRIVATE_KEY` | SSH private key for server access |
| `TS_OAUTH_CLIENT_ID` | Tailscale OAuth client ID |
| `TS_OAUTH_SECRET` | Tailscale OAuth secret |
| `RESEND_API_KEY` | Resend API key for email notifications |
| `GEMINI_API_KEY` | Google Gemini API key for email generation |
| `EMAIL_FROM` | Sender email address |
| `NOTIFY_EMAIL` | Recipient email address |

## 📧 Notifications

Email notifications are generated using **Google Gemini** for professional, context-aware content and sent via **Resend**.

- ✅ Success emails for completed updates
- ⚠️ Urgent emails when reboot is required
- ❌ Error emails when updates fail

## 📄 License

Private repository. All rights reserved.
