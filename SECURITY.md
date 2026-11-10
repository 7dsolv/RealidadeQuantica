# Security and supported scope

Report vulnerabilities privately via [Security → Report a vulnerability](https://github.com/7dsolv/RealidadeQuantica/security/advisories/new).
Do not publish keys, tokens, private sensor data or sensitive logs in Issues.
The newest minor release receives fixes; no response-time SLA is offered.

The laboratory is research software and CAD/RTL simulation. It does not control
heaters or provide a safety function. Real deployments need independent hardware
protections, a calibrated sensor, electrical review and physical validation.

Run trusted code and models. SHA-256 detects changed package bytes; provenance
and review establish which package is authorized. Keep the App key in Actions
Secrets. Public build artifacts contain no credentials. Revoke exposed keys
before resuming operation and retain the incident's sanitized source/run IDs.

Generated updates use restricted paths, source/state fingerprints and pull
requests. Code, policies and workflows require owner review; generated output
must still pass the required checks. Never bypass a failing integrity gate.
