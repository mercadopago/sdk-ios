# Functional Spec — openplatform-sdk-ios

**Versao**: 0.2.3
**Gerado**: 2026-03-06
**Modo**: Reverse Engineering (FULL EXTRACTION)

---

## 1. Visao Geral

O `openplatform-sdk-ios` e uma biblioteca iOS para integracao de pagamentos MercadoPago em aplicativos de terceiros. Ela oferece:

- Tokenizacao segura de cartoes de credito/debito (PCI compliant)
- Campos de entrada seguros (Secure Fields) para dados de cartao
- Consulta de meios de pagamento, parcelas e emissores
- Suporte a 3D Secure (3DS)
- Integracao com Apple Pay
- Analytics automatico de uso

---

## 2. Sistema de Contexto

### Atores

| Ator | Tipo | Interacao |
|------|------|-----------|
| Desenvolvedor iOS | Externo (Integrador) | Instala o SDK, configura e chama a API publica |
| Usuario Final | Humano | Preenche formularios de cartao na UI do aplicativo integrador |
| API MercadoPago | Sistema Externo | Processa tokens, retorna payment methods, installments |
| DeviceFingerPrint | Sistema (Binary SDK) | Coleta dados do dispositivo para anti-fraude |
| Apple Pay (PassKit) | Sistema da Apple | Fornece PKPaymentToken para tokenizacao |
| Analytics (api.mercadolibre.com) | Sistema Interno | Recebe eventos de uso do SDK |

### Dependencias Externas

| Sistema | URL | Finalidade |
|---------|-----|-----------|
| MercadoPago API | `https://api.mercadopago.com` | Tokenizacao de cartao |
| MercadoPago Checkout Off | `https://api.mercadopago.com/cho-off` | Metodos de pagamento, parcelas, emissores |
| MercadoPago 3DS | `https://api.mercadopago.com/cho-off/beta` | 3DS device data e challenge |
| MercadoPago Apple Pay | `https://api.mercadopago.com/platforms/pci/applepay` | Tokenizacao Apple Pay |
| MercadoLibre Analytics | `https://api.mercadolibre.com/tracks` | Tracking de eventos |

---

## 3. Casos de Uso

### UC-001: Inicializar o SDK
**Confianca**: 🔸 CODE_ONLY
**Ator**: Desenvolvedor iOS
**Pre-condicao**: App possui uma `publicKey` valida do MercadoPago e um pais suportado.
**Fluxo principal**:
1. Desenvolvedor chama `MercadoPagoSDK.shared.initialize(Configuration(publicKey:locale:country:))`
2. SDK valida a public key (nao vazia)
3. SDK valida o pais (enum Country com 18 valores)
4. SDK envia evento de analytics de inicializacao
5. SDK fica pronto para uso
**Fluxo alternativo — ja inicializado**:
1. Desenvolvedor chama `setNewConfiguration(_:)` para trocar configuracao sem reinicializar
**Erros possiveis**: `SDKError.notInitialized`, `SDKError.alreadyInitialized`, `SDKError.invalidPublicKey`, `SDKError.countryInvalid`
**Paises suportados**: ARG, BRA, COL, MEX, CHL, NIC, PAN, ECU, HND, GTM, SLV, CUB, PRY, DOM, PER, BOL, CRI, VEN, URY (18 paises)

---

### UC-002: Tokenizar Cartao Novo com Secure Fields
**Confianca**: 🔸 CODE_ONLY
**Ator**: Usuario Final (via app integrador) + Desenvolvedor iOS
**Pre-condicao**: SDK inicializado. Campos de cartao renderizados na UI.
**Fluxo principal**:
1. Usuario preenche `CardNumberTextField`, `ExpirationDateTextfield`, `SecurityCodeTextField`
2. SDK valida em tempo real: Luhn (numero), formato/expiracao (data), comprimento (CVV)
3. Desenvolvedor chama `CoreMethods.createToken(cardNumber:expirationDate:securityCode:cardHolderName:)`
4. SDK coleta device fingerprint via `DeviceFingerPrint.xcframework`
5. SDK envia POST `/v1/card_tokens` com dados encriptados
6. Retorna `CardToken` com `token`, `bin`, `lastFourDigits`, `expirationMonth/Year`
**Fluxo alternativo — com documento**:
- Overload com parametros `documentType: IdentificationType, documentNumber: String`
**Erros**: `CoreMethodsError`, `APIClientError`

---

### UC-003: Tokenizar Cartao Salvo
**Confianca**: 🔸 CODE_ONLY
**Ator**: Usuario Final + Desenvolvedor iOS
**Pre-condicao**: SDK inicializado. App possui `cardID` de um cartao salvo do usuario.
**Fluxo principal**:
1. Desenvolvedor chama `CoreMethods.createToken(cardID:expirationDate:securityCode:)`
2. SDK coleta device fingerprint
3. SDK envia POST `/v1/card_tokens` referenciando o cardID existente
4. Retorna `CardToken`
**Nota**: `expirationDate` e `securityCode` podem ser `nil` dependendo da configuracao do emissor.

---

### UC-004: Tokenizar com Parametros Raw
**Confianca**: 🔸 CODE_ONLY
**Ator**: Desenvolvedor iOS
**Pre-condicao**: SDK inicializado. Dados de cartao ja disponíveis como strings (ex: fluxo programatico, testes).
**Fluxo principal**:
1. Desenvolvedor cria `CardParams(cardNumber:expirationYear:expirationMonth:securityCode:...)`
2. Chama `CoreMethods.createToken(CardParams)`
3. SDK envia tokenizacao
4. Retorna `CardToken`
**Nota**: Este fluxo nao usa os Secure Fields — dados de cartao transitam como strings; menos recomendado para producao do ponto de vista PCI.

---

### UC-005: Consultar Meios de Pagamento por BIN
**Confianca**: 🔸 CODE_ONLY
**Ator**: Desenvolvedor iOS
**Pre-condicao**: SDK inicializado. Usuario digitou os primeiros 6-8 digitos do cartao (BIN).
**Fluxo principal**:
1. App captura o BIN via callback `CardNumberTextField.onBinChanged`
2. Desenvolvedor chama `CoreMethods.paymentMethods(bin:mode:)`
3. SDK consulta GET `/cho-off/v1/payment_methods`
4. Retorna array de `PaymentMethod` com bandeira, tipo, comprimento do cartao, comprimento do CVV, etc.
**ProcessingMode**: `.aggregator` (padrao) ou `.gateway`

---

### UC-006: Consultar Parcelas
**Confianca**: 🔸 CODE_ONLY
**Ator**: Desenvolvedor iOS
**Pre-condicao**: SDK inicializado. App conhece o valor da compra e o BIN.
**Fluxo principal**:
1. Desenvolvedor chama `CoreMethods.installments(amount:bin:mode:)`
2. SDK consulta GET `/cho-off/v1/installments`
3. Retorna array de `Installment` com `payerCosts` (parcelas disponíveis com valores, taxas, labels)

---

### UC-007: Consultar Emissores
**Confianca**: 🔸 CODE_ONLY
**Ator**: Desenvolvedor iOS
**Pre-condicao**: SDK inicializado. App conhece o BIN e o paymentMethodID.
**Fluxo principal**:
1. Desenvolvedor chama `CoreMethods.issuers(bin:paymentMethodID:)`
2. SDK consulta GET `/cho-off/v1/card_issuers`
3. Retorna array de `Issuer` (bancos emissores do cartao)

---

### UC-008: Consultar Tipos de Identificacao
**Confianca**: 🔸 CODE_ONLY
**Ator**: Desenvolvedor iOS
**Pre-condicao**: SDK inicializado.
**Fluxo principal**:
1. Desenvolvedor chama `CoreMethods.identificationTypes()`
2. SDK consulta GET `/cho-off/v1/identification_types`
3. Retorna array de `IdentificationType` (CPF, DNI, CUIT, etc.)
**Excecao**: Nao disponivel para Mexico.

---

### UC-009: Fluxo 3D Secure
**Confianca**: 🔸 CODE_ONLY
**Ator**: Desenvolvedor iOS + Sistema do Banco (ACS)
**Pre-condicao**: SDK inicializado. Token de cartao ja criado. Banco exige autenticacao 3DS.
**Fluxo principal**:
1. App recebe indicacao de que 3DS e necessario (ex: resposta do backend do vendedor)
2. App chama `CoreMethods.sendDeviceData(cardTokenId:appId:deviceData:referenceNumber:ephemeralPublicKey:transactionID:)`
3. SDK envia POST `/cho-off/beta/v1/challenges/threeds/device`
4. App chama `CoreMethods.challengeParameters(id)` → GET challenge parameters
5. App exibe o challenge 3DS (WebView ou SDK 3DS)
6. Apos conclusao:
   - Sucesso: `CoreMethods.finishChallenge(id)`
   - Cancelado: `CoreMethods.cancelChallenge(id)`
   - Erro: `CoreMethods.errorChallenge(id, errorCode:, errorMessageType:)`
   - Timeout: `CoreMethods.timeoutChallenge(id)`
7. SDK envia PATCH para atualizar status do challenge
**Directory Servers suportados**: Visa, Debvisa, Master, Debmaster, Amex

---

### UC-010: Tokenizar com Apple Pay
**Confianca**: 🔸 CODE_ONLY
**Ator**: Usuario Final (via Face ID / Touch ID) + Desenvolvedor iOS
**Pre-condicao**: Dispositivo suporta Apple Pay (`MPApplePay.canMakePayments() == true`).
**Fluxo principal**:
1. Desenvolvedor verifica suporte: `MPApplePay.canMakePayments()`
2. Cria `PKPaymentRequest`: `MPApplePay.paymentRequest(withMerchantIdentifier:currency:)`
3. Apresenta sheet Apple Pay ao usuario
4. Usuario autentica com Face ID / Touch ID
5. App recebe `PKPaymentToken` do sistema
6. Chama `mpApplePay.createToken(paymentToken, status:)` → POST `/platforms/pci/applepay/v1/tokenize`
7. Retorna `MPApplePayToken` com `id` e `bin`
**Redes suportadas**: Visa, Mastercard, Maestro

---

### UC-011: Customizar Aparencia dos Secure Fields
**Confianca**: 🔸 CODE_ONLY
**Ator**: Desenvolvedor iOS
**Fluxo principal**:
1. Desenvolvedor cria um objeto de style usando o builder pattern:
   `TextFieldDefaultStyle().textColor(.blue).font(...).borderWidth(2).cornerRadius(8)`
2. Chama `field.setStyle(style, for: .idle)` para cada estado (idle, focused, error, disabled)
3. SDK aplica o style ao campo

---

### UC-012: Usar Card Form Brick (Pre-built UI)
**Confianca**: 🔸 CODE_ONLY
**Ator**: Desenvolvedor iOS
**Status**: Em desenvolvimento (nao exposto como product SPM publico)
**Fluxo principal**:
1. Desenvolvedor configura `MercadoPagoCheckout(theme: Theme(...))`
2. Embute `CardFormBrick()` na hierarquia de views SwiftUI
3. Brick exibe formulario completo de cartao pre-montado com validacao

---

## 4. Regras de Negocio

| ID | Regra | Fonte |
|----|-------|-------|
| BR-001 | SDK deve ser inicializado antes de qualquer chamada de API | 🔸 CODE_ONLY |
| BR-002 | `public_key` nao pode ser vazia | 🔸 CODE_ONLY |
| BR-003 | Pais deve ser um dos 18 valores do enum `Country` | 🔸 CODE_ONLY |
| BR-004 | Numero de cartao e validado com algoritmo de Luhn antes da tokenizacao | 🔸 CODE_ONLY |
| BR-005 | Data de expiracao e validada (formato, data valida, nao expirada) | 🔸 CODE_ONLY |
| BR-006 | `identificationTypes()` nao esta disponivel para Mexico | 🔸 CODE_ONLY |
| BR-007 | Apple Pay requer verificacao de suporte do dispositivo antes de uso | 🔸 CODE_ONLY |
| BR-008 | Redes Apple Pay suportadas: Visa, Mastercard, Maestro apenas | 🔸 CODE_ONLY |
| BR-009 | Device fingerprint e coletado e enviado em toda tokenizacao | 🔸 CODE_ONLY |
| BR-010 | Analytics sao disparados automaticamente em todos os metodos publicos | 🔸 CODE_ONLY |
| BR-011 | [BUG] Country COL esta mapeada para SiteID "MLC" (Chile) em vez de "MCO" | 🔸 CODE_ONLY |

---

## 5. Glossario

| Termo | Definicao |
|-------|-----------|
| Token | Representacao segura dos dados de cartao gerada pela API MercadoPago |
| BIN | Primeiros 6-8 digitos do numero do cartao (Bank Identification Number) |
| Secure Field | Campo de UI que encapsula dados sensiveis de cartao de forma PCI compliant |
| 3DS | 3D Secure — protocolo de autenticacao adicional do banco emissor (v2.2.0) |
| Processing Mode | Modo de processamento: `aggregator` (padrao) ou `gateway` |
| CardFormBrick | Componente SwiftUI pre-montado com o formulario completo de cartao |
| PCI | Payment Card Industry — padroes de seguranca para dados de cartao |
| ACS | Access Control Server — servidor do banco que autentica o 3DS challenge |
| Site ID | Identificador do pais/site na plataforma MercadoPago (ex: MLB, MLA, MCO) |
