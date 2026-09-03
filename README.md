# AI DIVE — Authorized Cybersecurity Assessment Platform

AI DIVE is a small, production-minded MVP for **authorized cybersecurity assessment and vulnerability analysis**. It performs bounded real checks and creates evidence-backed findings; it does not fabricate vulnerabilities, brute-force credentials, deploy payloads, or perform destructive exploitation.

## Architecture

```text
User → Target validation → Authorization attestation → Central scope validation
     → DNS/IP validation → Bounded scanners → Evidence → Findings
     → Deterministic evidence analysis → Dashboard / audit
```

Every active HTTP destination is re-checked by the central scope engine. The MVP uses **exact-host assessment scope**: redirects to a different hostname are blocked rather than automatically authorized. Resolved addresses are independently checked and the scan fails closed if DNS cannot establish a destination or if any resolved address is private/restricted (unless private targets are explicitly enabled by deployment configuration).

## Authorization model

Active scanning is blocked until `authorization_agreement.agreed=true` is supplied. The checkbox/API attestation is an authorization and audit mechanism; it is **not** represented as a guarantee of legal protection or liability. The legacy `/api/scan` endpoint is retained for compatibility but also requires an explicit authorization agreement.

## Real scanner modules

- DNS and IPv4/IPv6 resolution
- Bounded common TCP port connectivity checks
- TLS handshake, negotiated protocol/cipher, trust observations and certificate details when available
- HTTP/HTTPS availability and redirect behavior
- Security headers: HSTS, CSP, X-Content-Type-Options, frame protection, Referrer-Policy, Permissions-Policy
- Cookie flags: Secure, HttpOnly, SameSite
- CORS origin-reflection / credential observations
- Fixed, non-crawling exposure checks for `robots.txt`, `sitemap.xml`, `security.txt`, `.env`, and `.git/HEAD`

HTTP responses are bounded to 1 MiB, redirects are limited, port concurrency is capped, and scanner failures are recorded as partial results instead of inventing findings.

## Storage and retention

Assessment records are stored under:

```text
data/assessments/<assessment-id>/
  assessment.json
  findings.json
  evidence.json
```

Assessment data expires after **72 hours** by default and is cleaned automatically during storage access. Audit events are stored separately in `backend/audit.log`; audit retention is intentionally separate from assessment retention and can be managed/rotated independently.

## API

- `GET /api/health`
- `POST /api/assessments`
- `GET /api/assessments`
- `GET /api/assessments/{id}`
- `POST /api/assessments/{id}/start`
- `POST /api/assessments/{id}/cancel`
- `GET /api/assessments/{id}/findings`
- `GET /api/assessments/{id}/evidence`
- `GET /api/assessments/{id}/audit`
- `GET /api/audit/recent`
- `POST /api/scan` (legacy compatibility; explicit authorization still required)

## Configuration

Copy `.env.example` values into your environment as needed:

```text
AIDIVE_AUTHORIZED_TARGETS=example.com
AIDIVE_ALLOWED_ORIGINS=http://localhost:3000
AIDIVE_ALLOW_PRIVATE_TARGETS=false
AIDIVE_AUDIT_PATH=backend/audit.log
```

`AIDIVE_AUTHORIZED_TARGETS` is a deployment-level allowlist. Leaving it empty means the deployment relies on the user's explicit target authorization attestation while still enforcing public-address SSRF protections and exact-host per-assessment scope.

## Run backend

Python 3.11+ is recommended. The MVP backend has no third-party Python runtime dependency.

```bash
python -m backend.main
```

Backend: `http://localhost:8000`

## Run frontend

```bash
cd frontend
npm install
npm run dev
```

Frontend: `http://localhost:3000`

Set `NEXT_PUBLIC_API_BASE` if the backend is not at `http://localhost:8000`.

## Tests

```bash
python -m unittest -v tests/test_aidive.py
```

The suite covers target parsing, public/private destination checks, exact-host scope enforcement, mixed public/private DNS rejection, finding evidence normalization, and 72-hour storage behavior.

## Analysis layer

The current MVP uses `deterministic-evidence-analyzer`, not a configured external LLM. It summarizes and prioritizes only scanner-supplied evidence. A future LLM provider can be added behind this layer, but it must never invent endpoints, CVEs, exploitation success, or evidence.

## Responsible use

**AI DIVE is designed for authorized security assessment. Users are responsible for obtaining permission and defining an appropriate scope before testing a target.** Active testing can affect systems; use it only against infrastructure you are authorized to assess.
