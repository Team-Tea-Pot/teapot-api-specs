# TeaPot API Specifications & SDKs

This repository contains the OpenAPI specifications for TeaPot microservices and the autonomous SDK generation pipeline.

## 📂 Structure

```
teapot-api-specs/
├── user-service/               # Service definition
│   ├── openapi.yaml            # API Specification
│   └── generators/             # Generator configurations
│       ├── dart-config.json
│       ├── typescript-config.json
│       ├── java-config.json
│       └── go-config.json
├── sdks/                       # Generated SDKs (ignored in git)
├── scripts/                    # Automation scripts
└── Makefile                    # Command shortcuts
```

## 🚀 Autonomous SDK Generation

We support automatic generation of SDKs for:
- **Dart** (Flutter)
- **TypeScript** (Web/Node)
- **Java** (Android/Backend)
- **Go** (Backend)

### Local Generation

To generate and build all SDKs locally:

```bash
make generate-all
```

This command will:
1. Detect all services with `openapi.yaml`
2. Generate SDKs for all supported languages using Docker
3. **Build and Package** each SDK (npm install, mvn install, etc.)

### Prerequisites

- Docker (required for generation)
- Language tools for building (optional, script skips if missing):
  - Node.js & npm
  - Java & Maven
  - Dart SDK
  - Go

## 🔄 CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/auto-generate-sdks.yml`) automatically:
1. Triggers on changes to any `openapi.yaml`
2. Generates all SDKs
3. Builds and validates them
4. Uploads artifacts

## 📝 Adding a New Service

1. Create a new directory: `mkdir my-new-service`
2. Add `openapi.yaml` inside it.
3. (Optional) Add `generators/` folder with custom configs.
4. Run `make generate-all` to test.
