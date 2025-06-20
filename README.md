# 🔐 Sealed Secrets for QRify Environments

This repo manages **encrypted Kubernetes secrets** for all environments (`dev`, `prod`, etc.) using [Bitnami Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets).

Secrets are committed in encrypted form and automatically deployed to the cluster via **ArgoCD**.

---

## 📁 Folder Structure

```
sealed-secrets/
├── secrets/
│   ├── dev/
│   │   └── <encrypted-secrets>.yaml
│   ├── prod/
│   │   └── <encrypted-secrets>.yaml
│   └── <env>/
│       └── ...
├── pub-cert.pem          # Used to encrypt secrets locally
├── scripts/
│   └── encrypt.sh        # Encrypt a new secret (see below)
└── .github/
    └── workflows/
        └── deploy-secrets.yaml
```

---

## 🚀 Automatic Deployment

On every `push` to `main` that modifies anything under the `secrets/` folder, GitHub Actions will:

1. Set up access to your Kubernetes cluster (EKS)
2. Loop through all folders under `secrets/`
3. Apply every Sealed Secret found via `kubectl apply`

---

## ✍️ Encrypting a New Secret

To add a new encrypted secret:

### 📦 Installing kubeseal (if needed)
If you don’t have kubeseal installed, you can get it here:

macOS (Homebrew):
```bash
brew install kubeseal
```

Linux:
```bash
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.25.0/kubeseal-0.25.0-linux-amd64.tar.gz
tar -xvzf kubeseal-0.25.0-linux-amd64.tar.gz
sudo install kubeseal /usr/local/bin/
```

Windows:
```bash
choco install kubeseal
```

1. Make sure the `sealed-secrets` controller is already running in your cluster.


2. Download the **public cert** used by the controller:

```bash
kubeseal --controller-namespace kube-system --controller-name sealed-secrets --fetch-cert > pub-cert.pem

```

3. Run the helper script:

```bash
./scripts/encrypt.sh <env> <secret-name> key1=value1 key2=value2 ...
```

Example:

```bash
./scripts/encrypt.sh dev aws-creds AWS_ACCESS_KEY=xxx AWS_SECRET_KEY=yyy
```

4. Commit the generated file under `secrets/dev/aws-creds.yaml`

5. Push to `main` — Secrets will be auto-deployed by ArgoCD app.

---

## 👀 Tips

- Do **not** commit unencrypted Kubernetes `Secret` resources.
- Do **not** store private keys or `kubeseal` private certs in this repo.

---

## 🧹 Cleanup

To remove a secret:

```bash
git rm secrets/<env>/<secret-name>.yaml
git commit -m "remove secret"
git push
```

GitHub Actions will remove it from the cluster on the next sync.

---

