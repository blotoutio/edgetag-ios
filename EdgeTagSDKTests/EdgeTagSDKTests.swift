//
//  EdgeTagSDKTests.swift
//  EdgeTagSDKTests
//
//  Created by Poonam Tiwari on 05/09/22.
//

import XCTest
@testable import EdgeTagSDK

class EdgeTagSDKTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

    
    func testInitWithIDFADisabledAndConsentCheckEnabled(){
        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io",shouldFetchIDFA: false,disableConsentCheck: false)
        let edgeTagManager = EdgeTagManager.shared

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, error in
            XCTAssert(success)
        })
    }
    
    func testInitWithIDFADisabledAndConsentCheckDisabled(){
        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io",shouldFetchIDFA: false,disableConsentCheck: true)
        let edgeTagManager = EdgeTagManager.shared

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, error in
            XCTAssert(success)
        })
    }
    
    func testInitWithIDFAEnabledAndConsentCheckDisabled(){
        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io",shouldFetchIDFA: true,disableConsentCheck: true)
        let edgeTagManager = EdgeTagManager.shared

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, error in
            XCTAssert(success)
        })
    }
    
    func testInitWithIDFAEnabledAndConsentCheckEnabled(){
        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io",shouldFetchIDFA: true,disableConsentCheck: false)
        let edgeTagManager = EdgeTagManager.shared

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, error in
            XCTAssert(success)
        })
    }
    
    
    func testInitWithIDFADisabledAndConsentCheckWithInvalidURL(){
        let edgeConfiguration = EdgeTagConfiguration(withUrl: "invalid url",shouldFetchIDFA: false,disableConsentCheck: false)
        let edgeTagManager = EdgeTagManager.shared

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, error in
            XCTAssert(error != nil)
        })
    }
    
    func testInitWithIDFADisabledAndConsentCheckDisabledWithInvalidURL(){
        let edgeConfiguration = EdgeTagConfiguration(withUrl: "invalid url",shouldFetchIDFA: false,disableConsentCheck: true)
        let edgeTagManager = EdgeTagManager.shared

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, error in
            XCTAssert(error != nil)
        })
    }
    
    func testInitWithIDFAEnabledAndConsentCheckDisabledWithInvalidURL(){
        let edgeConfiguration = EdgeTagConfiguration(withUrl: "invalid url",shouldFetchIDFA: true,disableConsentCheck: true)
        let edgeTagManager = EdgeTagManager.shared

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, error in
            XCTAssert(error != nil)
        })
    }
    
    func testInitWithIDFAEnabledAndConsentCheckEnabledWithInvalidURL(){
        let edgeConfiguration = EdgeTagConfiguration(withUrl: "invalid url",shouldFetchIDFA: true,disableConsentCheck: false)
        let edgeTagManager = EdgeTagManager.shared

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, error in
            XCTAssert(error != nil)
        })
    }
    
func testConsent(){
    
    let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io",shouldFetchIDFA: true,disableConsentCheck: false)
    let edgeTagManager = EdgeTagManager.shared

    let exp = expectation(description: "\(#function)\(#line)")
    
    edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, error in
        if success{
        edgeTagManager.giveConsentForProviders(consent: ["facebook":false, "smart":false,"all":true], completion: { success, error in
            XCTAssert(success)
            exp.fulfill()
        })
        }
    })
        waitForExpectations(timeout: 40, handler: nil)
    
}
    func testTagWithDisableConsentAndNOUserINFO(){

        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io",shouldFetchIDFA: true,disableConsentCheck: true)
        let edgeTagManager = EdgeTagManager.shared

        let exp = expectation(description: "\(#function)\(#line)")
        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, error in
            if success{
            edgeTagManager.addTag(withData: ["value":"20.00","currency":"USD"], eventName: "cartEvent", providers: ["all":false,"facebook":true], completion: { success, error in
                XCTAssert(success)
                exp.fulfill()
            })
            }
        })
            waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testTagWithEnableConsentAndNOUserINFO(){
        
        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io",shouldFetchIDFA: true,disableConsentCheck: false)
        let edgeTagManager = EdgeTagManager.shared
        
        let exp = expectation(description: "\(#function)\(#line)")
        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, error in
            if success{
            edgeTagManager.giveConsentForProviders(consent: ["facebook":false, "smart":false,"all":true], completion: { success, error in
                edgeTagManager.addTag(withData: ["value":"20.00","currency":"USD"], eventName: "cartEvent", providers: ["all":false,"facebook":true], completion: { success, error in
                    XCTAssert(success)
                    exp.fulfill()
                })
            })
            }
        })
            waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUserDataDictionaryWithDisableConsent(){

        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io",shouldFetchIDFA: true,disableConsentCheck: true)
        let edgeTagManager = EdgeTagManager.shared
        let exp = expectation(description: "\(#function)\(#line)")

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, error in
            if success{
           edgeTagManager.addDataIDGraph(idGraph: ["email":"me@abckl.ij","cutomInfo":"Random string entry"], completion: { success, error in                XCTAssert(success)
               exp.fulfill()
            })
            }
        })
            waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUserDataDictionaryWithEnableConsent(){

        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io",shouldFetchIDFA: true,disableConsentCheck: true)
        let edgeTagManager = EdgeTagManager.shared
        let exp = expectation(description: "\(#function)\(#line)")

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, error in
            if success{
            edgeTagManager.addDataIDGraph(idGraph: ["email":"me@abckl.ij","cutomInfo":"Random string entry"], completion: { success, error in              XCTAssert(success)
                exp.fulfill()
            })
            }
        })
            waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUserDataWithDisableConsent(){

        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io",shouldFetchIDFA: true,disableConsentCheck: true)
        let edgeTagManager = EdgeTagManager.shared
        let exp = expectation(description: "\(#function)\(#line)")

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, error in
            if success{
            edgeTagManager.addUserIDGraph(userKey: "email", userValue: "me@domain.com", completion: { success, error in
                XCTAssert(success)
                exp.fulfill()
            })
            }
        })
            waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUserDataWithEnableConsent(){

        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io",shouldFetchIDFA: true,disableConsentCheck: false)
        let edgeTagManager = EdgeTagManager.shared
        let exp = expectation(description: "\(#function)\(#line)")

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, error in
            if success{
            edgeTagManager.addUserIDGraph(userKey: "email", userValue: "me@domain.com", completion: { success, error in
                XCTAssert(success)
                exp.fulfill()
            })
            }
        })
            waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetData()
    {
        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io",shouldFetchIDFA: true,disableConsentCheck: false)
        let edgeTagManager = EdgeTagManager.shared
        let exp = expectation(description: "\(#function)\(#line)")

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, error in
            if success{
            edgeTagManager.getDataIDGraph(idGraphKeys: ["cutomInfo","numberValue","testBool","email","invalid value"], completion: { success, error, idGraph in
                XCTAssert(success)
                exp.fulfill()
            })
            }
        })
            waitForExpectations(timeout: 40, handler: nil)
    }
   
    func testGetKeys()
    {
        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io",shouldFetchIDFA: true,disableConsentCheck: false)
        let edgeTagManager = EdgeTagManager.shared
        let exp = expectation(description: "\(#function)\(#line)")

        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, error in
            if success{
            edgeTagManager.getUserKeys(completion: { success, error, idGraphKeys in
                XCTAssert(success)
                exp.fulfill()
            })
            }
        })
            waitForExpectations(timeout: 40, handler: nil)
    }
    
    
    func testCreateKVForUserData(){
        PackageProviders.shared.createKVForUserData(kvUserData: ["email":"user@testMail.com"])
    }
    
    func testGetKVForUserData(){
       let dict = PackageProviders.shared.getKVForUserData()
        XCTAssert(dict.keys.count > 0)
    }
    
    func testpassIDFAValuesToManager(){
        IDFAHandler.shared.passIDFAValuesToManager(checkForIDFA: true, idfaAccessGranted: true)
        XCTAssert(NetworkManager.shared.idfaAccessGranted)
    }
    
    func testSendAppInstallEvent(){
        StorageHandler.shared.saveAppInstallEventSent()
        XCTAssert(StorageHandler.shared.getAppInstallEventSent())
    }
    
    func testGetCookie(){
        
        let edgeConfiguration = EdgeTagConfiguration(withUrl: "https://sdk-demo-t.edgetag.io",shouldFetchIDFA: true,disableConsentCheck: false)
        let edgeTagManager = EdgeTagManager.shared
        
        edgeTagManager.initEdgeTag(withEdgeTagConfiguration: edgeConfiguration, completion: { success, error in
            if success{
                let cookieStr = StorageHandler.shared.getCookie()
                XCTAssert(cookieStr.count > 0)
            }
        })
    }
}

