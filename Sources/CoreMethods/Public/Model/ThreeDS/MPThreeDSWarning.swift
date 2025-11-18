//
//  MPThreeDSWarning.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 26/08/25.
//

/// Security warning information generated during 3DS SDK initialization.
///
/// The 3DS SDK performs comprehensive security checks during initialization to assess
/// the safety of the mobile device environment. These warnings indicate potential
/// security risks that could compromise 3D Secure authentication integrity.
///
/// **Important:** While warnings don't prevent SDK functionality, they should be
/// carefully evaluated to determine if authentication should proceed. Ignoring
/// high-severity warnings may expose the application to security vulnerabilities.
///
public struct MPThreeDSWarning: Sendable {
    /// Unique identifier for this warning type.
    public let id: String
    
    /// Human-readable warning message describing the issue.
    public let message: String
    
    /// Severity level indicating the importance of this warning.
    public let severity: Severity
    
    /// Security warning severity levels for risk assessment.
    ///
    /// Indicates the potential security impact and recommended response
    /// to device environment risks detected during 3DS SDK initialization.
    public enum Severity: Int, Sendable {
        /// Low-severity security notice with minimal risk.
        case low = 0
        
        /// Medium-severity security warning requiring attention.
        case medium = 1
        
        /// High-severity security risk requiring immediate attention.
        case high = 2
        
        /// Informational message with no security implications.
        case none = 3
    }
}
