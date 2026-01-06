//
//  MockThreeDSRepository.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 06/01/26.
//
import CommonTests
@testable import CoreMethods
import MPCore
import XCTest

final class MockThreeDSRepository: ThreeDSRepositoryProtocol, @unchecked Sendable {
    struct PostCall: Equatable {
        let body: MPThreeDSAuthRequestParametersBody
    }
    
    struct GetCall: Equatable {
        let id: String
    }
    
    struct PatchCall: Equatable {
        let id: String
        let body: MPThreeDSUpdateStatusBody
    }
    
    var postCalls: [PostCall] = []
    var getCalls: [GetCall] = []
    var patchCalls: [PatchCall] = []
    
    var postResult: ThreeDSDeviceDataResponse = .init()
    var postError: Error?
    
    var getResult: MPThreeDSChallengeResponse = MPThreeDSChallengeResponse(
        status: "authenticated",
        data: nil
    )
    var getError: Error?
    
    var patchResult: Data = Data()
    var patchError: Error?
    
    func postSDKData(_ data: MPThreeDSAuthRequestParametersBody) async throws -> ThreeDSDeviceDataResponse {
        postCalls.append(.init(body: data))
        if let postError {
            throw postError
        }
        return postResult
    }
    
    func getChallenge(_ id: String) async throws -> MPThreeDSChallengeResponse {
        getCalls.append(.init(id: id))
        if let getError {
            throw getError
        }
        return getResult
    }
    
    func patchChallenge(_ id: String, body: MPThreeDSUpdateStatusBody) async throws -> Data {
        patchCalls.append(.init(id: id, body: body))
        if let patchError {
            throw patchError
        }
        return patchResult
    }
}
