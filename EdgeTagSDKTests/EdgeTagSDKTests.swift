//
//  EdgeTagSDKTests.swift
//  EdgeTagSDKTests
//
//  Created by Poonam Tiwari on 05/09/22.
//

import XCTest
@testable import EdgeTagSDK

class EdgeTagSDKTests: XCTestCase {

    func testInitWithIDFADisabledAndConsentCheckEnabled() {
        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io", shouldFetchIDFA: false, disableConsentCheck: false)
        let edgeTagManager = EdgeTagManager.shared

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, _ in
            XCTAssert(success)
        })
    }

    func testInitWithIDFADisabledAndConsentCheckDisabled() {
        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io", shouldFetchIDFA: false, disableConsentCheck: true)
        let edgeTagManager = EdgeTagManager.shared

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, _ in
            XCTAssert(success)
        })
    }

    func testInitWithIDFAEnabledAndConsentCheckDisabled() {
        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io", shouldFetchIDFA: true, disableConsentCheck: true)
        let edgeTagManager = EdgeTagManager.shared

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, _ in
            XCTAssert(success)
        })
    }

    func testInitWithIDFAEnabledAndConsentCheckEnabled() {
        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io", shouldFetchIDFA: true, disableConsentCheck: false)
        let edgeTagManager = EdgeTagManager.shared

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, _ in
            XCTAssert(success)
        })
    }

    func testInitWithIDFADisabledAndConsentCheckWithInvalidURL() {
        let edgeConfiguration = EdgeTagConfiguration(withUrl: "invalid url", shouldFetchIDFA: false, disableConsentCheck: false)
        let edgeTagManager = EdgeTagManager.shared

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { _, error in
            XCTAssert(error != nil)
        })
    }

    func testInitWithIDFADisabledAndConsentCheckDisabledWithInvalidURL() {
        let edgeConfiguration = EdgeTagConfiguration(withUrl: "invalid url", shouldFetchIDFA: false, disableConsentCheck: true)
        let edgeTagManager = EdgeTagManager.shared

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { _, error in
            XCTAssert(error != nil)
        })
    }

    func testInitWithIDFAEnabledAndConsentCheckDisabledWithInvalidURL() {
        let edgeConfiguration = EdgeTagConfiguration(withUrl: "invalid url", shouldFetchIDFA: true, disableConsentCheck: true)
        let edgeTagManager = EdgeTagManager.shared

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { _, error in
            XCTAssert(error != nil)
        })
    }

    func testInitWithIDFAEnabledAndConsentCheckEnabledWithInvalidURL() {
        let edgeConfiguration = EdgeTagConfiguration(withUrl: "invalid url", shouldFetchIDFA: true, disableConsentCheck: false)
        let edgeTagManager = EdgeTagManager.shared

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { _, error in
            XCTAssert(error != nil)
        })
    }

    func testConsent() {

        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io", shouldFetchIDFA: true, disableConsentCheck: false)
        let edgeTagManager = EdgeTagManager.shared

        let exp = expectation(description: "\(#function)\(#line)")

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, _ in
            if success {
                edgeTagManager.giveConsentForProviders(consent: ["facebook": false, "smart": false, "all": true], completion: { success, _ in
                    XCTAssert(success)
                    exp.fulfill()
                })
            }
        })
        waitForExpectations(timeout: 40, handler: nil)

    }
    func testTagWithDisableConsentAndNOUserINFO() {

        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io", shouldFetchIDFA: true, disableConsentCheck: true)
        let edgeTagManager = EdgeTagManager.shared

        let exp = expectation(description: "\(#function)\(#line)")
        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, _ in
            if success {
                edgeTagManager.addTag(withData: ["value": "20.00", "currency": "USD"], eventName: "cartEvent", providers: ["all": false, "facebook": true], completion: { success, _ in
                    XCTAssert(success)
                    exp.fulfill()
                })
            }
        })
        waitForExpectations(timeout: 40, handler: nil)
    }

    func testTagWithEnableConsentAndNOUserINFO() {

        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io", shouldFetchIDFA: true, disableConsentCheck: false)
        let edgeTagManager = EdgeTagManager.shared

        let exp = expectation(description: "\(#function)\(#line)")
        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, _ in
            if success {
                edgeTagManager.giveConsentForProviders(consent: ["facebook": false, "smart": false, "all": true], completion: { success, _ in
                    edgeTagManager.addTag(withData: ["value": "20.00", "currency": "USD"], eventName: "cartEvent", providers: ["all": false, "facebook": true], completion: { success, _ in
                        XCTAssert(success)
                        exp.fulfill()
                    })
                })
            }
        })
        waitForExpectations(timeout: 40, handler: nil)
    }

    func testUserDataDictionaryWithDisableConsent() {

        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io", shouldFetchIDFA: true, disableConsentCheck: true)
        let edgeTagManager = EdgeTagManager.shared
        let exp = expectation(description: "\(#function)\(#line)")

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, _ in
            if success {
                edgeTagManager.addDataIDGraph(idGraph: ["email": "me@abckl.ij", "cutomInfo": "Random string entry"], completion: { success, _ in                XCTAssert(success)
                    exp.fulfill()
                })
            }
        })
        waitForExpectations(timeout: 40, handler: nil)
    }

    func testUserDataDictionaryWithEnableConsent() {

        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io", shouldFetchIDFA: true, disableConsentCheck: true)
        let edgeTagManager = EdgeTagManager.shared
        let exp = expectation(description: "\(#function)\(#line)")

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, _ in
            if success {
                edgeTagManager.addDataIDGraph(idGraph: ["email": "me@abckl.ij", "cutomInfo": "Random string entry"], completion: { success, _ in              XCTAssert(success)
                    exp.fulfill()
                })
            }
        })
        waitForExpectations(timeout: 40, handler: nil)
    }

    func testUserDataWithDisableConsent() {

        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io", shouldFetchIDFA: true, disableConsentCheck: true)
        let edgeTagManager = EdgeTagManager.shared
        let exp = expectation(description: "\(#function)\(#line)")

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, _ in
            if success {
                edgeTagManager.addUserIDGraph(userKey: "email", userValue: "me@domain.com", completion: { success, _ in
                    XCTAssert(success)
                    exp.fulfill()
                })
            }
        })
        waitForExpectations(timeout: 40, handler: nil)
    }

    func testUserDataWithEnableConsent() {

        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io", shouldFetchIDFA: true, disableConsentCheck: false)
        let edgeTagManager = EdgeTagManager.shared
        let exp = expectation(description: "\(#function)\(#line)")

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, _ in
            if success {
                edgeTagManager.addUserIDGraph(userKey: "email", userValue: "me@domain.com", completion: { success, _ in
                    XCTAssert(success)
                    exp.fulfill()
                })
            }
        })
        waitForExpectations(timeout: 40, handler: nil)
    }

    func testGetData() {
        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io", shouldFetchIDFA: true, disableConsentCheck: false)
        let edgeTagManager = EdgeTagManager.shared
        let exp = expectation(description: "\(#function)\(#line)")

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, _ in
            if success {
                edgeTagManager.getDataIDGraph(idGraphKeys: ["cutomInfo", "numberValue", "testBool", "email", "invalid value"], completion: { success, _, _ in
                    XCTAssert(success)
                    exp.fulfill()
                })
            }
        })
        waitForExpectations(timeout: 40, handler: nil)
    }

    func testGetKeys() {
        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io", shouldFetchIDFA: true, disableConsentCheck: false)
        let edgeTagManager = EdgeTagManager.shared
        let exp = expectation(description: "\(#function)\(#line)")

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, _ in
            if success {
                edgeTagManager.getUserKeys(completion: { success, _, _ in
                    XCTAssert(success)
                    exp.fulfill()
                })
            }
        })
        waitForExpectations(timeout: 40, handler: nil)
    }

    func testCreateKVForUserData() {
        PackageProviders.shared.createKVForUserData(kvUserData: ["email": "user@testMail.com"])
    }

    func testGetKVForUserData() {
        let dict = PackageProviders.shared.getKVForUserData()
        XCTAssert(dict.keys.count > 0)
    }

    func testpassIDFAValuesToManager() {
        IDFAHandler.shared.passIDFAValuesToManager(checkForIDFA: true, idfaAccessGranted: true)
        XCTAssert(NetworkManager.shared.idfaAccessGranted)
    }

    func testSendAppInstallEvent() {
        StorageHandler.shared.saveAppInstallEventSent()
        XCTAssert(StorageHandler.shared.getAppInstallEventSent())
    }

    func testGetCookie() {

        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io", shouldFetchIDFA: true, disableConsentCheck: false)
        let edgeTagManager = EdgeTagManager.shared

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, _ in
            if success {
                let cookieStr = StorageHandler.shared.getCookie()
                XCTAssert(cookieStr.count > 0)
            }
        })
    }
}
