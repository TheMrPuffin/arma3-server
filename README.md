# Arma 3 Dedicated Server – Docker & Helm

### ⚠️ This project is under early active development.

This repository provides a fully containerised Arma 3 dedicated server built on top of the
[`cm2network/steamcmd`](https://hub.docker.com/r/cm2network/steamcmd) base image.  

---

## 🗂️ Repository Structure

```text
/
├─ Dockerfile              # Arma 3 server image
├─ startServer.sh          # CMD script (runs steamcmd + arma3server)
├─ server.cfg              # Default server configuration
├─ LICENSE
├─ README                  # This file!
└─ .github/workflows/      # CI pipelines
   └─ hadolint.yml
```
