//
//  ServiceStatusViewModel.swift
//  NightscoutServiceKitUI
//
//  Created by Pete Schwamb on 10/1/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import Foundation

import NightscoutServiceKit
import LoopKit

protocol ServiceStatusViewModelDelegate {
    func verifyConfiguration(completion: @escaping (Error?) -> Void)
    func updateSecondaryNightscoutCredentials(urlString: String, apiSecret: String) throws
    var siteURL: URL? { get }
    var secondarySiteURL: URL? { get }
    var secondaryApiSecret: String? { get }
}

enum ServiceStatus {
    case checking
    case normalOperation
    case error(Error)
}

extension ServiceStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .checking:
            return LocalizedString("Checking...", comment: "Description of ServiceStatus of checking")
        case .normalOperation:
            return LocalizedString("OK", comment: "Description of ServiceStatus of checking")
        case .error(let error):
            return error.localizedDescription
        }
    }
}

class ServiceStatusViewModel: ObservableObject {
    @Published var status: ServiceStatus = .checking
        
    let delegate: ServiceStatusViewModelDelegate
    var didLogout: (() -> Void)?
    
    var urlString: String {
        return delegate.siteURL?.absoluteString ?? LocalizedString("Not Available", comment: "Error when nightscout service url is not set")
    }

    var secondaryUrlString: String {
        return delegate.secondarySiteURL?.absoluteString ?? LocalizedString("Not Configured", comment: "Secondary Nightscout URL is not configured")
    }

    var secondaryStatusString: String {
        if delegate.secondarySiteURL != nil && delegate.secondaryApiSecret?.isEmpty == false {
            return LocalizedString("Configured", comment: "Secondary Nightscout is configured")
        } else {
            return LocalizedString("Off", comment: "Secondary Nightscout is disabled")
        }
    }
    func saveSecondaryNightscout(urlString: String, apiSecret: String) {
        do {
            try delegate.updateSecondaryNightscoutCredentials(urlString: urlString, apiSecret: apiSecret)
            objectWillChange.send()
        } catch {
            self.status = .error(error)
        }
    }
    init(delegate: ServiceStatusViewModelDelegate) {
        self.delegate = delegate
        
        delegate.verifyConfiguration { (error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.status = .error(error)
                } else {
                    self.status = .normalOperation
                }
            }
        }
    }
}
