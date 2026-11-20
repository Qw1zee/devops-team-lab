# DevOps VM Lab — starter files

Training project: Lubuntu VM, distinct Linux users (`dev1`, `dev2`, `deploylab`), GitHub feature branches/PRs, CI (Ruff + pytest), and a pull-based CD timer gated on a successful **GitHub Actions** CI run on the current `main` commit.

Use the companion Word guide for *ordered setup instructions*. Do not copy files from this directory directly into privileged system locations without reading them first. The starter is not yet configured for your GitHub username; the deployment script deliberately fails until `GITHUB_USER` is replaced.

- `app.py` / `tests/test_app.py`: demonstration Flask app and tests.
- `.github/workflows/ci.yml`: GitHub-hosted CI on PRs and pushes to main.
- `systemd/devops-lab.service`: localhost-only Gunicorn system service.
- `scripts/cd_poll.sh`: root-owned pull-based deployment script. Requires public repo and `curl`, `jq`, Git, Python env.
- `systemd/devops-lab-cd.service` and `.timer`: execute deployment poll every 5 minutes, after manual enablement.

**Important:** No Docker or incoming SSH from GitHub Actions is required at this stage; the VM pulls approved code outbound over HTTPS. The 5055 port is bound to loopback. For real production, add release immutability, rollback, package locking and threat modeling.

## Developer Two

This section was added by dev2.

The project uses pytest for automated tests
and Ruff for Python code quality checks.
