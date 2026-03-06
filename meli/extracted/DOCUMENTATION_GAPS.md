# Documentation Gaps — openplatform-sdk-ios

**Gerado**: 2026-03-06
**Fase**: 2 — Cross-Validation

## Resumo de Cobertura

| Fonte | Cobertura Estimada | Observacao |
|-------|--------------------|------------|
| Code Analysis | 95% | Codigo-fonte lido integralmente |
| README.md | 40% | Exemplos basicos, sem docs de API completa |
| FuryMCP | N/A | SDK cliente iOS — sem backend Fury |
| OpenAPI Spec | 0% | Nao existe nenhum arquivo openapi.yaml/swagger |

## Gaps Identificados

### GAP-001: Sem especificacao formal de API
**Severidade**: MEDIUM
**Descricao**: Nao ha arquivo `openapi.yaml` ou `swagger.json` descrevendo os endpoints consumidos. Os endpoints foram extraidos do codigo-fonte.
**Recomendacao**: Gerar um openapi.yaml para documentar os contratos de API consumidos.

### GAP-002: DeviceFingerPrint.xcframework opaco
**Severidade**: MEDIUM
**Descricao**: O framework `DeviceFingerPrint.xcframework` e um binario pre-compilado proprietario. Nao e possivel inspecionar sua implementacao. Conhecemos apenas a interface publica via `FingerPrintProtocol` e o metodo `getDeviceData()`.
**Recomendacao**: Documentar o contrato de interface esperado do framework.

### GAP-003: README desatualizado (versao Swift)
**Severidade**: LOW
**Descricao**: README afirma "Swift 5.5+" mas o projeto usa Swift 6.0 (Package.swift swift-tools-version: 6.0 e podspec s.swift_version = '6.0').
**Recomendacao**: Atualizar README para Swift 6.0.

### GAP-004: MercadoPagoCheckout nao documentado
**Severidade**: LOW
**Descricao**: O modulo `MercadoPagoCheckout` com `CardFormBrick` existe no codigo mas nao e exposto como product SPM publico e nao e documentado no README.
**Recomendacao**: Definir se e um produto em desenvolvimento e quando sera liberado.

### GAP-005: Localizacao — idiomas suportados nao documentados
**Severidade**: LOW
**Descricao**: O `defaultLocalization` e `es-AR` mas os arquivos `.strings` em `MPFoundation/Resources/` nao foram totalmente inspecionados para listar todos os idiomas suportados.
**Recomendacao**: Listar idiomas suportados no README.

### GAP-006: Sem documentacao de tratamento de erros
**Severidade**: MEDIUM
**Descricao**: Os tipos de erro (`SDKError`, `CoreMethodsError`, `APIClientError`) existem mas nao ha documentacao de quando cada erro e lancado e como o desenvolvedor deve tratá-los.
**Recomendacao**: Adicionar secao de Error Handling no README com exemplos.

### GAP-007: Sem testes de integracao end-to-end
**Severidade**: LOW
**Descricao**: Os testes existentes sao unitarios. Nao ha testes E2E com mock server ou sandbox da API.
**Recomendacao**: Considerar adicionar testes de contrato com mock server.
