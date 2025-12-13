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

# Apply updates (may require approval if reboot/restart risk is detected)
./scripts/server-update.sh apply

# Apply updates with reboot
./scripts/server-update.sh apply-reboot

# Download logs from last run
./scripts/server-update.sh logs
```

Notes:
- `apply-reboot` always goes through the `maintenance` approval gate.
- `apply` may also require approval when `reboot_required=true` or `service_restart_required=true`.

## 🔄 Automated Workflows

### Server Updates (Weekly - Mondays 6am UTC)

The `server-updates.yml` workflow runs weekly (Monday 18:00 UTC / 12:00 PM CDMX) and is **check-only** on schedule:
1. Connects to servers via Tailscale (MagicDNS)
2. Checks for available updates
3. Sends an email summary **every run** (including “no updates”)

Applying updates is done via `workflow_dispatch` (manual trigger):
- **Smart mode** applies automatically *only* when no reboot is required and no critical service restart risk is detected.
- If a reboot or critical service restart risk is detected, updates require manual approval (GitHub Environment `maintenance`).

#### Execution Modes

| Mode | Description |
|------|-------------|
| `smart` | Check first. Apply only if no reboot and no critical restart risk (default) |
| `check` | Only check what updates are available |
| `apply` | Apply updates (approval required if reboot/restart risk is detected) |
| `apply-reboot` | Apply updates AND reboot if needed (always approval required) |

#### Critical Restart Risk (Heuristic)

During the check, the workflow flags `service_restart_required=true` when upgradable packages match critical patterns.
Minimum set:
- OpenSSH (`openssh-server`, `openssh-client`, `openssh-sftp-server`)
- Java 17 (SonarQube dependency: `openjdk-17-*`, `java-common`, `ca-certificates-java`)
- Tailscale (`tailscale`)

## 🔐 Required Secrets

Configure these in GitHub repository settings:

| Secret | Description |
|--------|-------------|
| `SSH_PRIVATE_KEY` | SSH private key for server access |
| `TS_OAUTH_CLIENT_ID` | Tailscale OAuth client ID |
| `TS_OAUTH_SECRET` | Tailscale OAuth secret |
| `RESEND_API_KEY` | (Optional) Resend API key for email notifications |
| `GEMINI_API_KEY` | (Optional) Google Gemini API key for email generation |
| `EMAIL_FROM` | (Optional) Sender email address |
| `NOTIFY_EMAIL` | (Optional) Recipient email address |

### Manual Approval (Recommended)

Configure a GitHub Environment named `maintenance` with **required reviewers**.
The workflow uses it to gate disruptive applies (reboot or critical service restart risk).

## 📧 Notifications

Email notifications are generated using **Google Gemini** for professional, context-aware content and sent via **Resend**.

- ✅ Success emails for completed updates
- ⚠️ Urgent emails when reboot is required
- ❌ Error emails when updates fail

## 📄 License

Private repository. All rights reserved.
