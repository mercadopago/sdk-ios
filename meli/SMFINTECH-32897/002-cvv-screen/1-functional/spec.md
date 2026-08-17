# Tela de CVV — Functional Spec

**Status**: approved
**Owner**: Samanta Albanez
**Jira**: [SMFINTECH-32897](https://mercadolibre.atlassian.net/browse/SMFINTECH-32897)
**Parent Feature**: [001-selector-de-meios](../../../001-selector-de-meios/1-functional/spec.md)
**Created**: 2026-06-25
**Last Updated**: 2026-06-26 (clareza SDK vs BFF em security_code.screen / has_preapproval_scope)

---

> **Purpose**: Esta spec define o comportamento e a UX da tela de CVV dentro do PaymentBrick Nativo. A tela é exibida quando o comprador seleciona um cartão salvo que exige validação do código de segurança antes de prosseguir.

---

## Problem Statement

Após selecionar um cartão salvo a tela de Payment, teremos de uma tela para que usuário insira o código de segurança do cartão.

---

## Scope

### In Scope
Exibir uma tela para inserir código de segurança do cartão que deverá conter:
Campos e elementos presentes na tela
- Título: "Completá el código de seguridad"
- Botão voltar
- Ícone da bandeira: logo Visa
- Nome do banco: "Santander"
- Dígitos mascarados do cartão: "•••• 4567"
- Tipo do cartão: "Visa Crédito"
- Label do campo: "Código de seguridad"
- Ícone de ajuda: "?"
- Campo de entrada numérica com placeholder "Ej.: 123"
- Borda vermelha no campo (estado de erro)
- Ícone de erro e mensagem: "Completá este campo."
- Label de total: "Total"
- Valor total: "$ 188.000"
- Botão "Continuar" (estado desabilitado)
- Exibição da tela de CVV quando `security_code.screen` está presente no response do BFF
- Pulo automático da tela quando `security_code.screen` está ausente no response (o BFF omite esse campo para cartões com `has_preapproval_scope = true` ou `security_code.length = 0`)
- Tokenização do cartão
### Out of Scope
- Exibição de erro de CVV inválido retornado pelo servidor (tratado na tela de resultado)

---

## User Stories

### US-1: Comprador insere CVV para cartão salvo

**As a** comprador que selecionou um cartão salvo com CVV obrigatório
**I want** ver um campo para inserir o código de segurança
**So that** eu possa prosseguir com o pagamento de forma segura

**Acceptance Criteria:**
- [ ] AC-1: A tela é exibida somente quando `security_code.screen` está presente no response do BFF
- [ ] AC-2: O campo exibe o placeholder dinâmico gerado pelo BFF (ex: "Ej.: 123" para 3 dígitos, "Ej.: 1234" para 4 dígitos)
- [ ] AC-3: O campo aceita apenas dígitos numéricos, respeitando o `length` definido pelo BFF
- [ ] AC-4: O botão de continuar (`button.label`) só é habilitado após preenchimento completo do CVV
- [ ] AC-5: O comprador pode voltar à tela seletora de meios
- [ ] AC-6: Ao tocar em continuar com CVV válido, o SDK tokeniza o cartão e avança para a tela de Revisa e Confirma

**Priority:** High
**Complexity:** S

---

### US-2: Comprador com cartão de autorização prévia pula a tela de CVV

**As a** comprador com cartão salvo que possui `has_preapproval_scope = true`
**I want** que o pagamento avance sem pedir meu CVV
**So that** a experiência seja mais fluida para cartões já autorizados

**Acceptance Criteria:**
- [ ] AC-1: Quando `security_code.screen` está ausente no response, o SDK não exibe a tela de CVV
- [ ] AC-2: O fluxo avança diretamente para a tela de Revisa e Confirma

> **Nota:** O SDK não verifica `has_preapproval_scope` diretamente. A única checagem do SDK é a presença ou ausência de `security_code.screen` no response. O BFF é responsável por omitir esse campo quando o cartão possui `has_preapproval_scope = true`.

**Priority:** High
**Complexity:** S

---

### US-3: Cartão salvo sem CVV obrigatório por ausência de `security_code.screen` (não relacionado a preapproval)

**As a** comprador com cartão salvo onde `has_preapproval_scope = false`, mas o BFF não retorna `security_code.screen` (ex: `security_code.length = 0`)
**I want** que o fluxo avance sem pedir meu CVV
**So that** a experiência não seja bloqueada por uma tela desnecessária

**Acceptance Criteria:**
- [ ] AC-1: Quando `security_code.screen` está ausente, o SDK pula a tela independentemente do valor de `has_preapproval_scope`
- [ ] AC-2: O fluxo avança diretamente para a tela de Revisa e Confirma

> **Nota:** Este cenário reforça que a regra do SDK é puramente baseada na presença de `security_code.screen`. O motivo pelo qual o BFF omite o campo (preapproval, length=0, ou outro) é transparente para o SDK.

**Priority:** Medium
**Complexity:** S

---

### US-4: Comprador com `has_preapproval_scope = false` e `security_code.screen` presente tem CVV exigido normalmente

**As a** comprador com cartão salvo onde `has_preapproval_scope = false`
**I want** ser solicitado a inserir o CVV quando o BFF retorna `security_code.screen`
**So that** o pagamento seja processado com a validação de segurança correta

**Acceptance Criteria:**
- [ ] AC-1: Quando `has_preapproval_scope = false` e `security_code.screen` está presente, a tela de CVV é exibida normalmente
- [ ] AC-2: O comportamento da tela é idêntico ao US-1

> **Nota:** Este US deixa explícito que `has_preapproval_scope = false` por si só não garante nem impede a exibição da tela — a decisão sempre parte da presença de `security_code.screen` no response.

**Priority:** Medium
**Complexity:** S

---

## User Experience

### Fluxo da tela de CVV

```
Tela seletora de meios
        ↓
Comprador seleciona cartão salvo
        ↓
SDK lê response do BFF (GET /cho-off/v1/payment_brick/initialization)
        ↓
┌─────────────────────────────────────────────────┐
│   security_code.screen presente no response?    │
└─────────────────────────────────────────────────┘
        │
        ├── NÃO ──────────────────────────────────────────────────────────────┐
        │    Motivos possíveis (decisão do BFF, transparente ao SDK):         │
        │    · has_preapproval_scope = true  →  BFF omite security_code.screen│
        │    · security_code.length = 0      →  BFF omite security_code.screen│
        │                                                                     │
        │    SDK pula tela de CVV                                             │
        │         ↓                                                           │
        │    Tela de Revisa e Confirma  ◄────────────────────────────────────-┘
        │
        └── SIM
               ↓
          Tela de CVV exibida
          (todos os labels e config vindos de security_code.screen)
               │
               ├── [Comprador toca "←" voltar]
               │          ↓
               │    Retorna à tela seletora de meios
               │    (seleção do cartão preservada)
               │
               └── [Comprador digita CVV via teclado numérico customizado]
                          ↓
                  ┌───────────────────────────────────────────┐
                  │  CVV completo?                            │
                  │  (dígitos == security_code.screen.length) │
                  └───────────────────────────────────────────┘
                          │
                          ├── NÃO
                          │    Botão "Continuar" permanece desabilitado
                          │    Comprador continua digitando
                          │
                          └── SIM
                               Botão "Continuar" habilitado
                                    ↓
                               Comprador toca "Continuar"
                                    ↓
                               SDK tokeniza o cartão com o CVV
                                    ↓
                               Tela de Revisa e Confirma
```

### Labels da tela

A tela é composta por dois grupos de dados: labels providos pelo BFF via `security_code.screen`, e dados do cartão selecionado.

#### Labels via `security_code.screen` (response de `GET /cho-off/v1/payment_brick/initialization`)

| Elemento | Campo no BFF | Exemplo (conforme tela) |
|---|---|---|
| Título da tela | `security_code.screen.header.title` | "Completá el código de seguridad" |
| Label do campo | `security_code.screen.field.label` | "Código de seguridad" |
| Placeholder do campo | `security_code.screen.field.placeholder` | "Ej.: 123" (3 dígitos) / "Ej.: 1234" (4 dígitos) |
| Texto auxiliar (ícone "?") | `security_code.screen.field.helper` | "Está en el reverso de tu tarjeta." |
| Botão de continuar | `security_code.screen.button.label` | "Continuar" |

#### Dados do cartão selecionado (vindos do método no response de `GET /cho-off/v1/payment_brick/initialization`)

| Elemento | Campo | Exemplo |
|---|---|---|
| Ícone da bandeira | `method.icon_url` | logo Visa |
| Título do cartão (banco + dígitos) | `method.title` | "Santander •••• 4567" |
| Tipo do cartão | `method.subtitle` | "Visa Crédito" |
| Label do total | `footer.total_label` | "Total" |
| Valor total | `footer.total_amount` | "R$ 100" |

> O BFF entrega `title` e `subtitle` já formatados — o SDK não compõe esses valores a partir de campos separados.

#### Estado de erro do campo

Ativado quando o comprador tenta avançar com o campo vazio ou incompleto. Todos os elementos visuais do erro são exibidos simultaneamente:

| Elemento visual | Descrição |
|---|---|
| Borda do campo | Muda para vermelho |
| Ícone de erro | Círculo vermelho exibido à esquerda da mensagem |
| Mensagem de erro | Texto `security_code.screen.field.error` em vermelho abaixo do campo |

---

## Success Metrics

| Métrica | Descrição |
|---|---|
| Taxa de conclusão da tela de CVV | % de compradores que preenchem o CVV e avançam vs. os que abandonam nessa tela |
| Taxa de pulo (preapproval) | % de seleções de cartão salvo que pulam a tela de CVV |

---

## Edge Cases

- **Comprador volta da tela de CVV**: retorna à tela seletora de meios sem perder a seleção do cartão
- **`security_code.length = 0`**: BFF omite `screen` — SDK pula a tela
- **CVV com comprimento diferente de 3 ou 4**: não mapeado nesta entrega — BFF sempre retorna `length` de 3 ou 4 para MLA

---

## Critical E2E Test Scenarios

| ID | Cenário | US | Prioridade |
|---|---|---|---|
| E2E-CVV-1 | Comprador preenche CVV de 3 dígitos e avança para Revisa e Confirma | US-1 | 🔴 Crítico |
| E2E-CVV-2 | Comprador preenche CVV de 4 dígitos e avança para Revisa e Confirma | US-1 / US-4 | 🔴 Crítico |
| E2E-CVV-3 | Cartão com `has_preapproval_scope = true` pula tela de CVV diretamente | US-2 | 🔴 Crítico |
| E2E-CVV-4 | `security_code.screen` ausente com `has_preapproval_scope = false` pula tela de CVV | US-3 | 🔴 Crítico |
| E2E-CVV-5 | `security_code.length = 0` — BFF omite `screen`, SDK pula tela de CVV | US-3 | 🔴 Crítico |
| E2E-CVV-6 | Botão "Continuar" permanece desabilitado enquanto CVV está incompleto | US-1 | 🟡 Importante |
| E2E-CVV-7 | Botão "Continuar" é habilitado somente após CVV atingir o `length` definido pelo BFF | US-1 | 🟡 Importante |
| E2E-CVV-8 | Comprador volta ao seletor de meios — seleção do cartão é preservada | US-1 | 🟡 Importante |
| E2E-CVV-9 | Comprador apaga um dígito após CVV completo — botão "Continuar" volta a ser desabilitado | US-1 | 🟡 Importante |
| E2E-CVV-10 | Placeholder exibe formato correto para 3 dígitos ("Ej.: 123") | US-1 | 🟠 Edge Case |
| E2E-CVV-11 | Placeholder exibe formato correto para 4 dígitos ("Ej.: 1234") | US-1 | 🟠 Edge Case |
