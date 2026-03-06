# meli/extracted — Indice de Extracao

**Data**: 2026-03-06
**Modo**: FULL EXTRACTION
**Repositorio**: fury_openplatform-sdk-ios (v0.2.3)
**Estrategia**: FULL (sem specs pre-existentes)

## Arquivos Gerados

| Arquivo | Descricao | Fase |
|---------|-----------|------|
| `raw/existing-specs/DETECTION_REPORT.md` | Frameworks detectados e estrategia | 0 |
| `raw/code-analysis/architecture/architecture.md` | Stack e arquitetura | 1 |
| `raw/code-analysis/api-specs/endpoints.md` | Endpoints REST consumidos | 1 |
| `raw/README.md` | Metadados de extracao | 1 |
| `DOCUMENTATION_GAPS.md` | Gaps e ausencias identificados | 2 |
| `DISCREPANCIES_REPORT.md` | Discrepancias e bugs | 3 |
| `functional-spec.md` | Spec funcional (12 casos de uso) | 4 |
| `technical-spec.md` | Spec tecnica (API publica, endpoints, patterns) | 4 |
| `PATTERNS.md` | 9 patterns identificados no codigo | 5 |

## Resumo da Extracao

- **Tipo de projeto**: iOS SDK client-side (nao e servico Fury backend)
- **Stack**: Swift 6.0, iOS 13+, SPM + CocoaPods
- **Arquitetura**: Clean Architecture com DI por protocol composition
- **Features principais**: Card Tokenization, Secure Fields (PCI), 3DS, Apple Pay, Analytics
- **Casos de uso documentados**: 12
- **Patterns documentados**: 9
- **Bugs encontrados**: 1 CRITICAL (Country COL → SiteID errado)
- **Discrepancias**: 4 (1 CRITICAL, 2 WARNING, 1 INFO)
- **Gaps de documentacao**: 7

## Proximos Passos

- Revisar specs em `meli/specs/` (promovidas da extracao)
- Corrigir bug DISC-001: `Country.COL` → SiteID `"MCO"`
- Iniciar features com `/meli.start`
