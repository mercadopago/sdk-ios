//
//  CoreMethodsTest+PaymentMethodStub.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 10/03/25.
//

import CommonTests
@testable import CoreMethods
import MPCore
import Testing
import XCTest

extension CoreMethodsTests {
    enum PaymentMethodStub {
        static var expectedResponse: [PaymentMethod] {
            [
                .init(
                    id: "master",
                    paymentTypeId: "credit_card",
                    status: "active",
                    processingMode: "aggregator",
                    accreditationTime: 2880,
                    merchantAccountId: "",
                    siteId: "MLB",
                    thumbnail: "www.google.com",
                    minAccreditationDays: 0,
                    maxAccreditationDays: 2,
                    totalFinancialCost: 0,
                    financialInstitution: [],
                    issuer: PaymentMethod.Issuer(
                        id: 24,
                        isDefault: true,
                        thumbnail: "www.google.com"
                    ),
                    card: PaymentMethod.CardInfo(
                        bin: 502_432,
                        length: PaymentMethod.CardInfo.CardLength(min: 16, max: 16),
                        validation: "standard",
                        securityCode: PaymentMethod.CardInfo.SecurityCode(
                            mode: "mandatory",
                            location: "back",
                            length: 3
                        )
                    ),
                    bins: [],
                    marketplace: "NONE",
                    deferredCapture: "supported",
                    agreements: [],
                    payerCosts: [
                        PaymentMethod.PayerCost(
                            installments: 1,
                            installmentRate: 0,
                            discountRate: 0,
                            reimbursementRate: 0,
                            minAllowedAmount: 0.5,
                            maxAllowedAmount: 60000,
                            paymentMethodOptionId: "123",
                            labels: []
                        ),
                        PaymentMethod.PayerCost(
                            installments: 2,
                            installmentRate: 8.14,
                            discountRate: 0,
                            reimbursementRate: 0,
                            minAllowedAmount: 10,
                            maxAllowedAmount: 60000,
                            paymentMethodOptionId: "123",
                            labels: []
                        )
                    ],
                    labels: ["zero_dollar_auth"],
                    additionalInfoNeeded: ["cardholder_identification_number", "cardholder_identification_type", "cardholder_name"]
                )
            ]
        }

        static var validResponse: Data {
            let response = """
            [
              {
                "financial_institutions": [],
                "payer_costs": [
                  {
                    "installment_rate": 0,
                    "min_allowed_amount": 0.5,
                    "max_allowed_amount": 60000,
                    "installments": 1,
                    "discount_rate": 0,
                    "reimbursement_rate": 0,
                    "labels": [],
                    "payment_method_option_id": "123"
                  },
                  {
                    "installment_rate": 8.14,
                    "min_allowed_amount": 10,
                    "max_allowed_amount": 60000,
                    "installments": 2,
                    "discount_rate": 0,
                    "reimbursement_rate": 0,
                    "labels": [],
                    "payment_method_option_id": "123"
                  }
                ],
                "agreements": [],
                "issuer": {
                  "default": true,
                  "id": 24,
                  "thumbnail": "www.google.com"
                },
                "card": {
                  "bin": 502432,
                  "length": {
                    "min": 16,
                    "max": 16
                  },
                  "validation": "standard",
                  "security_code": {
                    "mode": "mandatory",
                    "location": "back",
                    "length": 3
                  }
                },
                "total_financial_cost": 0,
                "min_accreditation_days": 0,
                "max_accreditation_days": 2,
                "accreditation_time": 2880,
                "merchant_account_id": "",
                "status": "active",
                "additional_info_needed": [
                  "cardholder_identification_number",
                  "cardholder_identification_type",
                  "cardholder_name"
                ],
                "processing_mode": "aggregator",
                "site_id": "MLB",
                "labels": [
                  "zero_dollar_auth"
                ],
                "deferred_capture": "supported",
                "marketplace": "NONE",
                "id": "master",
                "payment_type_id": "credit_card",
                "thumbnail": "www.google.com"
              }
            ]
            """
            return Data(response.utf8)
        }
    }
}
