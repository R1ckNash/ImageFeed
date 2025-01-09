//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Ilia Liasin on 05/01/2025.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append("--disable-pagination")
        app.launch()
    }
    
    func testAuth() {
        sleep(5)
        
        let button = app.buttons["Authenticate"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        button.tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 15))
        
        loginTextField.tap()
        loginTextField.typeText("lyasin.i@mail.ru")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 15))
        
        passwordTextField.tap()
        sleep(5)
        passwordTextField.typeText("fP7MEx!5E!nqE.S")
        sleep(5)
        webView.swipeUp()
        sleep(5)
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        
        sleep(5)
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(5)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        cellToLike.buttons["like_button"].tap()
        cellToLike.buttons["like_button"].tap()
        
        sleep(5)
        
        cellToLike.tap()
        
        sleep(5)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let backButton = app.buttons["back_button"]
        backButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts[""].exists)
        XCTAssertTrue(app.staticTexts[""].exists)
        
        app.buttons["logout button"].tap()
        
        app.alerts["Bye bye!"].scrollViews.otherElements.buttons["Yes"].tap()
        XCTAssertTrue(app.buttons["Authenticate"].waitForExistence(timeout: 3))
    }
}
