//
//  StatusScreenUseCase.swift
//  MercadoPagoSDK
//

#if SWIFT_PACKAGE
    import MPCore
#endif

protocol StatusScreenUseCaseProtocol: Sendable {
    func execute(
        orderID: String,
        clientToken: String,
        lastFourDigits: String?,
        sellerInfo: MPSellerInfo?,
        checkoutType: String?
    ) async throws(MercadoPagoCheckoutError) -> StatusScreenOutput
}

struct StatusScreenUseCase: StatusScreenUseCaseProtocol, Sendable {
    private let repository: any StatusScreenRepository
    private let mapper: StatusScreenMapper

    init(
        repository: any StatusScreenRepository = RemoteStatusScreenRepository(),
        mapper: StatusScreenMapper = StatusScreenMapper()
    ) {
        self.repository = repository
        self.mapper = mapper
    }

    func execute(
        orderID: String,
        clientToken: String,
        lastFourDigits: String?,
        sellerInfo: MPSellerInfo?,
        checkoutType: String?
    ) async throws(MercadoPagoCheckoutError) -> StatusScreenOutput {
        let request = StatusScreenRequestBody(
            orderID: orderID,
            lastFourDigits: lastFourDigits,
            sellerInfo: sellerInfo.map {
                .init(name: $0.name, iconURL: $0.logoUrl)
            }
        )

        do {
            let response = try await self.repository.fetchStatusScreen(
                request: request,
                clientToken: clientToken,
                checkoutType: checkoutType
            )
            return try self.mapper.map(response)
        } catch let APIClientError.decodingFailed(error) {
            throw self.contractViolationError(error: error)
        } catch let error as StatusScreenContractError {
            throw self.contractViolationError(error: error)
        } catch let error as APIClientError {
            throw MercadoPagoCheckoutError(from: error, location: .initialization)
        } catch {
            throw MercadoPagoCheckoutError(
                code: .serviceError,
                localizedDescription: "Status Screen is unavailable",
                location: .initialization
            )
        }
    }

    private func contractViolationError(error: Error) -> MercadoPagoCheckoutError {
        return MercadoPagoCheckoutError(
            code: .serviceError,
            localizedDescription: "Status Screen contract violation",
            userInfo: ["status_screen_reason": "contract_violation", "error": error],
            location: .initialization
        )
    }
}
