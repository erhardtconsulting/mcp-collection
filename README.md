# MCP‑Collection

> **A single Docker image that ships multiple Model‑Context‑Protocol (MCP) servers and exposes them through a unified entry‑point.**

---

## ✨  Highlights

* **One image – many servers**: choose the desired MCP server at runtime via a single argument.
* **Remote‑ready out of the box**: the bundled [supergateway](https://github.com/supercorp-ai/supergateway) bridges the server’s `stdio` interface to HTTP/SSE or WebSocket.
* **Kubernetes‑first**: baked‐in health endpoints, non‑root user, and tiny distroless runtime layer (≤80MB).
* **Deterministic builds**: Python dependencies locked with `uv.lock`; no run‑time installation required or allowed.

---

## 🚀  Getting started

```bash
# pull the multi‑arch image
docker pull ghcr.io/erhardtconsulting/mcp‑collection:1.0.0

# list available MCP servers (shows help)
docker run --rm ghcr.io/erhardtconsulting/mcp‑collection

# run the Git server with extra flags for the underlying CLI
docker run --rm -p 8080:8080 \
  ghcr.io/erhardtconsulting/mcp‑collection mcp-server-fetch --test
```

### Included MCP servers

| Package            |
|--------------------|
| `mcp-server-fetch` |

## 🐳  Image layout

```
/mcp-collection
├── root
     ├──docker-entrypoint.sh # selects & validates the server, launches supergateway
     ├── .venv/              # isolated Python environment for all MCP servers
     ├── node_modules/       # isolated Node environment for all MCP servers
     ├── pyproject.toml      # dependency list for Python MCP servers
     └── package.json        # dependency list for Node MCP servers
```

The entry‑point performs the following steps:
1. Activates the virtual environment (`.venv`).
2. Reads a **fixed whitelist** (`ALLOWED_SERVERS`).
3. Validates the user‑supplied server name.
4. Execs `supergateway --stdio "<server> [extra‑args]"`.

---

## ☸️  Example Kubernetes deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mcp-collection
spec:
  selector:
    matchLabels: {app: mcp-collection}
  template:
    metadata:
      labels: {app: mcp-collection}
    spec:
      containers:
      - name: mcp
        image: ghcr.io/erhardtconsulting/mcp-collection:1.0.0
        args: ["mcp-server-kubernetes"]
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: mcp-collection
spec:
  selector: {app: mcp-collection}
  ports:
  - port: 80
    targetPort: 8080
```

Pair the Service with an Ingress or Gateway API resource to expose it externally.

---

## 🛡  Security notes

* Container runs as a non‑root UID (`1000:1000`).
* No shell is kept after `exec`, reducing the attack surface.
* Use a reverse proxy or API‑gateway to enforce TLS & authentication.

---

## 🤝  Contributing

1. Fork the repo
2. Add or update an MCP server in `root/app/package.json`/`root/app/pyproject.toml` **and** `entrypoint.sh`.
3. Run `make test` locally.
4. Open a PR; GitHub Actions will lint, build, and scan the image.

---

## 📜  License

Released under the MIT License – see `LICENSE` for details.

---

**MCP‑Collection** is maintained by *erhardt consulting GmbH* – happy hacking!

