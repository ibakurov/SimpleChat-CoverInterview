//
//  ChatChatUITests.swift
//  ChatChatUITests
//
//  Created by Illya Bakurov on 8/24/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import XCTest
import Firebase
@testable import ChatChatDEV

class ChatChatUITests: XCTestCase {
    
    //-----------------
    // MARK: - Test Methods
    //-----------------
    
    override class func setUp() {
        super.setUp()
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
    
    override func setUp() {
        super.setUp()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
    }
    
    func testLoginTapWithEmptyNameField() {
        let app = XCUIApplication()
        app.buttons["Login anonymously"].tap()
        app.alerts["Error"].buttons["OK"].tap()
    }
    
    func testLoginTapWithNameFieldEnteredCorrectly() {
        let app = XCUIApplication()
        let enterYourNameTextField = app.textFields["Enter your name"]
        enterYourNameTextField.tap()
        enterYourNameTextField.typeText("Illya")
        app.buttons["Login anonymously"].tap()
        app.navigationBars["RW RIC"].otherElements["RW RIC"].tap()
    }
    
    func testCreatingAChannel() {
        let app = XCUIApplication()
        let enterYourNameTextField = app.textFields["Enter your name"]
        enterYourNameTextField.tap()
        enterYourNameTextField.typeText("Illya")
        app.buttons["Login anonymously"].tap()
        
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.cells.textFields["Create a New Channel"]/*[[".cells.textFields[\"Create a New Channel\"]",".textFields[\"Create a New Channel\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.tap()
        tablesQuery.cells.containing(.button, identifier:"Create").children(matching: .textField).element.typeText("Test Channel")
        tablesQuery/*@START_MENU_TOKEN@*/.cells.buttons["Create"]/*[[".cells.buttons[\"Create\"]",".buttons[\"Create\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.cells.staticTexts["Test Channel"]/*[[".cells.staticTexts[\"Test Channel\"]",".staticTexts[\"Test Channel\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.tap()
        
        deleteTestChannle()
    }
    
    func testSendingTextMessage() {
        let app = XCUIApplication()
        let enterYourNameTextField = app.textFields["Enter your name"]
        enterYourNameTextField.tap()
        enterYourNameTextField.typeText("Illya")
        app.buttons["Login anonymously"].tap()
        
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.cells.textFields["Create a New Channel"]/*[[".cells.textFields[\"Create a New Channel\"]",".textFields[\"Create a New Channel\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.tap()
        tablesQuery.cells.containing(.button, identifier:"Create").children(matching: .textField).element.typeText("Test Channel")
        tablesQuery/*@START_MENU_TOKEN@*/.cells.buttons["Create"]/*[[".cells.buttons[\"Create\"]",".buttons[\"Create\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.cells.staticTexts["Test Channel"]/*[[".cells.staticTexts[\"Test Channel\"]",".staticTexts[\"Test Channel\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.tap()
        
        let toolbarsQuery = app.toolbars
        let newMessageTextView = toolbarsQuery.textViews["New Message"]
        newMessageTextView.tap()
        newMessageTextView.typeText("Hello 👋")
        toolbarsQuery.buttons["Send"].tap()
        app.collectionViews.cells["Illya: Hello 👋"].tap()
        
        deleteTestChannle()
    }
    
    //-----------------
    // MARK: - Helper Methods
    //-----------------
    
    func deleteTestChannle() {
        //Delete the test channel after we tested it.
        
        let asyncRunningExpectation = expectation(description: "SendingTextMessage")
        
        #if ENVDEV
            let channelsRef =  Database.database().reference().child("dev").child("channels")
        #else
            let channelsRef = Database.database().reference().child("channels")
        #endif
        
       channelsRef.queryOrdered(byChild: "name").queryEqual(toValue: "Test Channel").observeSingleEvent(of: .value) { snap in
            if snap.childrenCount == 0 {
                asyncRunningExpectation.fulfill()
                return
            }
            for data in snap.children.allObjects as! [DataSnapshot] {
                if let value = data.value as? [String: Any], let name = value["name"] as? String, name == "Test Channel" {
                    data.ref.removeValue { _,_ in
                        asyncRunningExpectation.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout: 30) { expectationError in
            XCTAssertNil(expectationError, expectationError!.localizedDescription)
        }
    }
    
}
