# Discrepancies Report — openplatform-sdk-ios

**Gerado**: 2026-03-06
**Fase**: 3 — Deep Cross-Validation

## Discrepancias Encontradas

### DISC-001: Bug — Country COL mapeada para SiteID errado
**Severidade**: CRITICAL (BUG)
**Fonte**: Code Analysis (code-only)
**Arquivo**: `Sources/MPCore/Internal/Core/Extensions/Country+SiteID.swift`
**Descricao**: O enum `Country.COL` (Colombia) retorna SiteID `"MLC"` (Chile) em vez de `"MCO"` (Colombia).
**Impacto**: Requests feitas por usuarios colombianos serao enviadas com SiteID incorreto, potencialmente causando falhas ou cobranças erradas.
**Acao recomendada**: Corrigir o mapeamento de `.COL` para `"MCO"`.

### DISC-002: Versao Swift inconsistente entre fontes
**Severidade**: WARNING
**Fontes**: README.md vs Package.swift vs Podspec
**Descricao**:
  - README.md afirma: "Swift 5.5+"
  - Package.swift: `swift-tools-version: 6.0`
  - MercadoPagoSDKCoreMethods.podspec: `s.swift_version = '6.0'`
**Acao recomendada**: Atualizar README para Swift 6.0.

### DISC-003: MercadoPagoCheckout existe no codigo mas nao e produto publico
**Severidade**: WARNING
**Fonte**: Code Analysis
**Descricao**: O modulo `MercadoPagoCheckout` com `CardFormBrick` esta no diretorio `Sources/` mas nao aparece como `.library` nos products do `Package.swift`.
**Acao recomendada**: Clarificar status do modulo (em desenvolvimento / experimental).

### DISC-004: Country URY nao esta no enum Country
**Severidade**: INFO (verificar)
**Fonte**: Code Analysis
**Descricao**: O enum `Country` lista `VEN` e `URY` no comentario do arquivo mas a implementacao precisa ser verificada se URY esta corretamente mapeado para SiteID `"MLU"`.
**Acao recomendada**: Verificar mapeamento Country+SiteID para todos os 18 paises.

## Itens Verificados e Consistentes

| Item | Status | Fonte |
|------|--------|-------|
| Endpoints de API | OK | Code analysis |
| Modelos publicos (CardToken, PaymentMethod, etc.) | OK | Code analysis |
| Protocolo de autenticacao (public_key) | OK | Code analysis |
| Suporte a 3DS (envio de device data + challenge) | OK | Code analysis |
| Integracao Apple Pay com PassKit | OK | Code analysis |
| Validacao Luhn para numero de cartao | OK | Code analysis |
| Validacao de data de expiracao | OK | Code analysis |
| Swift Concurrency (actors, Sendable) | OK | Code analysis |
| Cobertura minima de testes (80%) | OK | Fastlane xcov |

## Acoes Prioritarias

1. **CRITICAL**: Corrigir bug DISC-001 (Country COL → SiteID "MCO")
2. **WARNING**: Atualizar README para Swift 6.0 (DISC-002)
3. **WARNING**: Definir status do modulo MercadoPagoCheckout (DISC-003)
