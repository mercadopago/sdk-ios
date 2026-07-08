# PaymentBrick Nativo — Selector de Meios — Functional Spec

**Status**: approved
**Owner**: Danielle Ogawa
**Jira**: [SMFINTECH-32897](https://mercadolibre.atlassian.net/browse/SMFINTECH-32897)
**RFC**: [[RFC] PaymentBrick MLA](https://grid.adminml.com/d/01KRE8MW8TVD33X6FDMP0W733W/view)
**Created**: 2026-05-22
**Last Updated**: 2026-05-22T15:12:22Z

> **Payment Flows**: Os fluxos de pagamento (Selecionar Meio — Novo Cartão, Cartão Salvo e Meios Offline) foram extraídos para spec dedicada → [`003-payment-flows/1-functional/spec.md`](../003-payment-flows/1-functional/spec.md)

> **CVV Screen**: Tudo relacionado à tela de CVV foi extraído para spec dedicada → [`002-cvv-screen/1-functional/spec.md`](../002-cvv-screen/1-functional/spec.md)

> **Revisa e Confirma**: US-5, E2E-5 e tela de Revisa e Confirma foram extraídos para spec dedicada → [`20260622-payment-review-confirm/1-functional/spec.md`](../../20260622-payment-review-confirm/1-functional/spec.md)

---

> **Purpose**: Esta spec define o PaymentBrick Nativo — componente SDK de seleção de meios de pagamento para apps nativos Android e iOS. O Brick oferece ao seller uma tela de checkout pronta e integrada à Order API, eliminando a necessidade de implementar lógica de pagamento no cliente.

---

## Problem Statement

Sellers que desenvolvem apps nativos (Android/iOS) não contam com nenhuma solução SDK de checkout pronta. Precisam implementar todo o fluxo de pagamento por conta própria: formulários de cartão, tokenização, integração com APIs de meios de pagamento, tela de revisão — com lógica de negócio espalhada pelo cliente.

O Checkout Bricks web resolve parte desse problema para a web, mas apenas retorna dados do pagamento (token de cartão, meio escolhido) para que o seller processe a transação no seu próprio backend — sem integração com a Order API do lado do Brick.

O PaymentBrick Nativo vai além: oferece a UI de checkout em SDK **e** integração direta com a Order API. O seller configura os dados de pagamento na criação da Order (server-side), e o SDK processa o pagamento sem expor configurações sensíveis no cliente.

**Impacto atual:**
- Sellers nativos gastam tempo e esforço reimplementando a mesma lógica de pagamento em cada app
- Experiência de checkout inconsistente entre sellers, aumentando dropout por má UX
- Dados sensíveis de pagamento expostos no cliente quando o seller implementa por conta própria
- Mercado Pago perde presença e conversão em canais mobile nativos

---

## Objectives

1. **Disponibilizar SDK de checkout nativo** (Android e iOS) com tela de seleção de meios de pagamento pronta
2. **Integrar com a Order API** no modelo Order Builder Mode — configurações sensíveis nunca trafegam pelo cliente
3. **Aumentar conversão em checkouts nativos** reduzindo dropout por fricção no pagamento
4. **Expandir a presença do MercadoPago** em canais mobile nativos de sellers

---

## Scope

### In Scope — Q2.26 (MLA — Argentina)

- **Checkout type `payment`**: tela seletora de meios de pagamento como entrega principal do quarter
- **Cartões salvos**: exibição dos cartões do comprador via `customer_id` (Customers API)
- **Novo cartão**: formulário de cartão com tokenização interna — `card_token` nunca exposto ao seller
- **Pagamentos offline**: Rapipago e Pago Fácil (hardcoded no BFF nesta entrega)
- **Tela de Revisa e Confirma**: endpoint dedicado `GET /review_confirm` com labels variáveis por tipo de meio
- **Integração com Order API** no modelo Order Builder Mode
- **Plataformas**: Android e iOS
- **Site**: MLA (Argentina)

### Out of Scope

- **Meios ecosistêmicos**: saldo em conta, cartões MP/ML (Q3.26)
- **Linha de crédito**: Cuotas sin Tarjeta (Q3.26)
- **Status Screen**: tela de resultado pós-pagamento (Q3.26) — seller recebe dados de boleto via callback nesta entrega
- **Sites MLB, MLM e demais**: estrutura já desenhada para multi-site, entrega futura
- **Consulta dinâmica de métodos offline**: Rapipago/Pago Fácil retornados como hardcoded no BFF nesta entrega
- **CTA de salvamento de cartão com UX dedicado**: salvamento automático pós-pagamento é Extra Mile (ver seção de Edge Cases)

---

## User Stories

### US-1: Seller inicializa o PaymentBrick no app nativo

**As a** seller que desenvolve um app nativo (Android ou iOS)
**I want** inicializar o PaymentBrick com o `order_id` da minha Order e a `public_key`
**So that** o comprador veja a tela de seleção de meios de pagamento sem que eu implemente nenhuma lógica de checkout no cliente

**Acceptance Criteria:**
- [ ] AC-1: O `payment` é iniciado com `order_id` e, opcionalmente, `customer_id` + `card_ids`
- [ ] AC-2: O SDK chama `GET /initialization` e renderiza a tela com os meios disponíveis retornados pelo BFF
- [ ] AC-3: Enquanto aguarda a resposta, o SDK exibe estado de loading (a definir com UX: skeleton ou spinner)
- [ ] AC-4: O seller configura os filtros de exclusão (`excludedTypes`, `excludedMethods` e campo de exclusão por grupo — nome TBD) via builder do `payment`; o SDK repassa esses valores ao BFF, que aplica o filtro server-side antes de retornar os meios disponíveis
- [ ] AC-5: Em caso de erro na inicialização (Order não encontrada, expirada ou falha crítica no BFF), o SDK devolve o erro ao seller via `onError` — a responsabilidade de exibir feedback ao usuário é do seller
- [ ] AC-6: O seller pode configurar comportamentos do checkout: limitar número mínimo (`minInstallments`) e máximo (`maxInstallments`) de parcelas — enviados ao BFF na inicialização para filtrar as opções retornadas —, ocultar a tela de Revisa e Confirma (`showReviewConfirm`) e ocultar a Status Screen (`showStatusScreen`)

**Priority:** High
**Complexity:** L

---

### US-5: Comprador revisa e confirma o pagamento

**As a** comprador que chegou à etapa de confirmação
**I want** ver um resumo do que vou pagar antes de confirmar
**So that** eu tenha controle sobre o pagamento antes de finalizar

**Acceptance Criteria:**
- [ ] AC-1: Ao avançar para a etapa de revisão, o SDK realiza um `GET /review_confirm` ao BFF passando o tipo de meio selecionado; o BFF retorna os labels e campos da tela de acordo com o tipo
- [ ] AC-2: A tela de Revisa e Confirma exibe o meio selecionado, o valor total e os campos do pagador relevantes por tipo
- [ ] AC-3: Para pagamentos offline (ticket), o campo de email é exibido e editável
- [ ] AC-4: Para cartões, apenas o meio de pagamento é exibido (sem campos adicionais do pagador)
- [ ] AC-5: O comprador pode alterar o meio de pagamento a partir desta tela — o SDK retorna à tela seletora
- [ ] AC-6: O valor total exibido vem do BFF formatado — o SDK exibe diretamente sem formatação monetária própria
- [ ] AC-7: O label do botão de confirmação varia por tipo: "Pagar" para cartões, "Crear factura" para offline

**Priority:** High
**Complexity:** M

---

### US-6: Seller recebe o resultado do pagamento via callback

**As a** seller integrado ao PaymentBrick Nativo
**I want** receber o resultado do checkout via callback estruturado
**So that** eu trate o resultado (aprovação, erro, cancelamento) na experiência do meu app sem precisar consultar a Order API

**Acceptance Criteria:**
- [ ] AC-1: Pagamento aprovado → `onSuccess(MPPaymentData.OrderTransaction)` com `orderId` (para o seller consultar a Order no seu backend) e `orderStatus` com o status do pagamento
- [ ] AC-2: Pagamento offline gerado → `onSuccess(MPPaymentData.OrderTransaction)` com `orderId` e `orderStatus`
- [ ] AC-3: Erro crítico (5xx, Order inválida) → `onError(MercadoPagoCheckoutError)` com o erro classificado
- [ ] AC-4: Usuário cancelou → `onUserCancelled(UserCancelledContext)` com o contexto de onde o usuário saiu
- [ ] AC-5: O SDK não retorna token nem dados de cartão — o processamento acontece inteiramente no BFF
- [ ] AC-6: Os callbacks são exaustivos (sem default/else no switch) em ambas as plataformas

**Priority:** High
**Complexity:** S

---

### US-7: Comprador cancela ou abandona o checkout

**As a** comprador que desistiu do pagamento em alguma etapa
**I want** poder sair do checkout a qualquer momento
**So that** o seller saiba onde abandone o fluxo para analytics de funil

**Acceptance Criteria:**
- [ ] AC-1: O `UserCancelledContext` identifica em qual tela o comprador saiu: `paymentBrick`, `cardForm`, `installments`, `cvv`, `payerInfo`, `reviewConfirm`
- [ ] AC-2: O cancelamento não é tratado como erro — `onUserCancelled` é distinto de `onError`
- [ ] AC-3: O seller recebe o contexto de cancelamento para uso em analytics; nenhuma ação de pagamento foi executada

**Priority:** Medium
**Complexity:** S

---

## Success Metrics

| Métrica | Baseline | Meta |
|---|---|---|
| Taxa de conversão do checkout (sessões que chegam ao /process com status approved) | [A definir com Analytics] | [A definir com Produto] |
| Taxa de abandono (sessões na inicialização que não chegam ao /process) | [A definir com Analytics] | [A definir com Produto] |
| Adoção por sellers (sellers ativos usando o PaymentBrick Nativo por semana) | 0 | [A definir com Produto] |

---

## User Experience

### Fluxo principal — payment

```
Seller cria Order (backend)
        ↓
Seller inicializa o SDK com public_key + country_code
        ↓
Seller inicializa o PaymentBrick(payment) com order_id [+ customer_id + card_ids]
        ↓
Loading (skeleton ou spinner — a definir com UX)
        ↓
Tela seletora de meios de pagamento
  └── [Fluxos de pagamento → ver 003-payment-flows]
```

### Telas do SDK (Q2.26)

| Tela | Quando exibida | Responsabilidade |
|---|---|---|
| Tela seletora de meios | Sempre — tela inicial do Brick | SDK renderiza baseado no response de `/initialization` |
| Tela de CVV | Cartão salvo com `security_code.screen` presente | SDK exibe campo de CVV |
| Tela de Revisa e Confirma | Antes de finalizar qualquer pagamento | SDK chama `GET /review_confirm` e renderiza labels do BFF |
| Status Screen | **Fora de escopo Q2.26** | Prevista para Q3.26 |

### Experiência do seller (integrador)

O seller inicializa o SDK e recebe o resultado via um único closure/callback. Toda lógica de pagamento fica encapsulada no SDK + BFF.

---

## Dependencies

- **Order API**: criação e leitura de `payment_settings` na inicialização; processamento do pagamento via `POST /process` — crítico, impossibilita o fluxo se indisponível
- **BFF `fury_bricks-api`**: novos endpoints `GET /cho-off/v1/payment_brick/initialization`, `GET /cho-off/v1/payment_brick/review_confirm` e `POST /cho-off/v1/orders/{order_id}/process` a criar
- **Customers API**: busca de cartões salvos via `customer_id` — parcial; checkout sem cartões salvos ainda funciona
- **KVS**: cache de configurações da Order entre chamadas do BFF — degradação de performance se indisponível, sem perda de funcionalidade (fallback direto para Order API)
- **CardPaymentBrick (existente)**: reutilização de módulo de tokenização e Core Methods no SDK

---

## Risks

| Risco | Probabilidade | Impacto | Mitigação |
|---|---|---|---|
| Order API adiciona breaking changes nos campos de `payment_settings` | Média | Alto | Contrato versionado (`/cho-off/v1/*`); BFF valida campos antes de cachear no KVS |
| Order expira durante o checkout (comprador demora para confirmar) | Média | Médio | BFF detecta no `/process` e retorna erro tratado; SDK orienta usuário a reiniciar |
| Baixa adoção por sellers — complexidade de integração com Order API | Média | Médio | Documentação detalhada; suporte via programa de parceiros; SDK como ponto único de integração |
| KVS com alta latência afeta tempo de resposta do `/initialization` | Baixa | Médio | TTL curto no KVS; fallback direto para Order API em caso de miss |
| SDK lança nova versão com breaking changes no contrato de inicialização ou callbacks | Baixa | Alto | O time está trabalhando em padrões que evitem breaking changes (ex: `CheckoutType` enum extensível); versionamento de endpoints como fallback quando necessário |

---

## Edge Cases

- **Order expirada durante o checkout**: BFF retorna `ORDER_EXPIRED` no `/process`; SDK exibe erro tratado e orienta o comprador a reiniciar o checkout
- **Comprador sem cartões salvos** (nenhum `card_ids`): tela exibe apenas "Novo cartão" e meios offline — sem seção de cartões
- **Seller exclui todos os meios offline exceto um** (ex: apenas Pago Fácil): comportamento a definir com UX — exibir com 1 opção (Opção A) ou pular direto para Revisa e Confirma (Opção B)
- **`customer_id` inválido ou Customers API indisponível**: BFF omite a seção de cartões salvos; checkout prossegue com novo cartão e offline
- **Comprador revoga autorização do cartão entre inicialização e processo**: Order API rejeita no `/process`; SDK devolve `onError` ao seller — sem nova tentativa automática para evitar duplo processamento
- **Salvamento automático de cartão pós-pagamento** (`payment` / `cardTransaction`): o comportamento padrão é `saveCard = true` — quando `customer_id` é fornecido, o BFF salva o cartão na Customers API após pagamento aprovado, de forma transparente ao comprador. No checkout type `saveCard`, o cartão **não** é salvo automaticamente pois não há processamento de pagamento — o SDK tokeniza e entrega o token ao seller via callback

---

## Critical E2E Test Scenarios

### E2E Summary

| ID | Cenário | Prioridade |
|---|---|---|
| E2E-4 | Inicialização com Order expirada | 🔴 Crítico |
| E2E-6 | Exclusão de tipos via `excludedTypes` | 🟡 Importante |
| E2E-8 | Exclusão de método específico via `excludedMethods` | 🟡 Importante |
| E2E-9 | Exclusão de boleto individual via campo de exclusão por grupo (nome TBD) | 🟡 Importante |

---

### E2E-4: Inicialização com Order expirada 🔴

**Contexto**: Seller inicializa o Brick com `order_id` de uma Order expirada

**Steps**:
1. SDK chama `GET /initialization` com Order expirada
2. BFF retorna erro `ORDER_EXPIRED`

**Resultado esperado**: `onError(ORDER_EXPIRED)` disparado — seller recebe o erro e é responsável por exibir feedback ao usuário

---

### E2E-6: Exclusão de tipos via `excludedTypes` 🟡

**Contexto**: Seller configura `excludedTypes: ["ticket"]` na inicialização

**Steps**:
1. Seller inicializa o SDK com `excludedTypes: ["ticket"]`
2. BFF omite meios offline do response de `/initialization`

**Resultado esperado**: Tela seletora exibe apenas cartões; nenhum item de ticket (Rapipago/Pago Fácil)

---

### E2E-8: Exclusão de método específico via `excludedMethods` 🟡

**Contexto**: Seller configura `excludedMethods: ["visa"]` na inicialização; comprador tem cartão Visa salvo e outros cartões

**Steps**:
1. Seller inicializa o SDK com `excludedMethods: ["visa"]`
2. BFF omite cartões Visa do response de `/initialization`

**Resultado esperado**: Cartões Visa não aparecem na tela seletora; demais cartões e meios seguem visíveis

---

### E2E-9: Exclusão de boleto individual via campo de exclusão por grupo (nome TBD) 🟡

**Contexto**: Seller configura exclusão de Rapipago via campo de exclusão por grupo (nome TBD)

**Steps**:
1. Seller configura exclusão de `rapipago` via `setPaymentMethodConfiguration` (campo nome TBD)
2. BFF omite Rapipago do response de `/initialization`, mantendo Pago Fácil

**Resultado esperado**: Tela de seleção de offline exibe apenas Pago Fácil; Rapipago não aparece

---

## Open Questions

1. **Estado de loading da tela seletora**: skeleton (Opção A, alinhado com CardPaymentBrick) ou spinner/tela de loading (Opção B)? — Pendência UX
2. **Experiência com exclusão de tickets para 1 único meio**: exibir na tela seletora (consistência) ou pular diretamente para Revisa e Confirma (menos fricção)? — Pendência UX
3. **Métricas de baseline**: quais são os valores atuais de conversão e abandono em fluxos nativos sem SDK? — Alinhar com Analytics
4. **Devolução de dados para pagamentos offline**: o callback `onSuccess` deve retornar apenas `orderId` + `orderStatus` (alinhado com cartões) ou incluir `barcode_content` e `date_of_expiration` para que o seller exiba o boleto sem consultar a Order API? — Decisão de arquitetura pendente
5. **Integração do card form dentro do PaymentBrick**: como o formulário de novo cartão será integrado ao fluxo do PaymentBrick — reuso do `CardFormBrick` existente como componente embutido, navegação para tela separada ou implementação dedicada? — Decisão de arquitetura pendente

---

## Notes

- Spec funcional baseada na RFC "[RFC] PaymentBrick MLA" v3 (15 mai 2026) — autora: Danielle Ogawa
- Escopo desta spec é o checkout type `payment` como entrega principal de Q2.26 MLA
- Os tipos `cardTransaction` e `saveCard` estão definidos na RFC e referenciados nesta spec; roadmap de entrega a alinhar com Produto
- Pendências UX (seção 14 da RFC) estão refletidas nos Open Questions acima
