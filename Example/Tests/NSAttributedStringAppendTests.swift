//
//  NSAttributedStringAppendTests.swift
//
//  Created by Brian King on 9/1/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import XCTest
import BonMot

let testBundle = Bundle(for: NSAttributedStringAppendTests.self)
let imageForTest = UIImage(named: "robot", in: testBundle, compatibleWith: nil)!

class NSAttributedStringAppendTests: XCTestCase {

    func testImageConstructor() {
        let imageString = NSAttributedString(image: imageForTest)
        let string = "\(Special.objectReplacementCharacter)"
        XCTAssertEqual(imageString.string, string)
    }

    func testBasicJoin() {
        let parts = [NSAttributedString(string: "A"), NSAttributedString(string: "B"), NSAttributedString(string: "C")]
        let string = NSAttributedString(attributedStrings: parts, separator: NSAttributedString(string: "-"))
        XCTAssertEqual("A-B-C", string.string)
    }

    func testAttributesArePassedAlongAppend() {
        let chainString = BonMot(.initialAttributes(["test": "test"])).attributedString(from: imageForTest)
        chainString.append(string: "Test")
        chainString.append(image: imageForTest)
        chainString.append(string: "Test")

        let attributes = chainString.attributes(at: chainString.length - 1, effectiveRange: nil)

        XCTAssertEqual(attributes["test"] as? String, "test")
    }

    func testTabStopsWithSpacer() {
        let stringWidth = CGFloat(115)

        let multiTabLine = NSMutableAttributedString()
        multiTabLine.append(string: "astringwithsomewidth")
        multiTabLine.append(tabStopWithSpacer: 10)
        multiTabLine.append(image: imageForTest)
        multiTabLine.append(tabStopWithSpacer: 10)
        multiTabLine.append(string: "astringwithsomewidth")
        multiTabLine.append(image: imageForTest)

        let stringTab = NSMutableAttributedString(string: "astringwithsomewidth")
        stringTab.append(tabStopWithSpacer: 10)

        let imageTab = NSMutableAttributedString(image: imageForTest)
        imageTab.append(tabStopWithSpacer: 10)

        let stringsWithTabStops: [(CGFloat, NSAttributedString)] = [
            (imageForTest.size.width + 10, imageTab),
            (stringWidth + 10, stringTab),
            ((stringWidth + 10 + imageForTest.size.width) * 2, multiTabLine)
        ]
        for (index, (expectedWidth, string)) in stringsWithTabStops.enumerated() {
            let line = UInt(#line - 2 - stringsWithTabStops.count + index)
            let width = string.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude),
                                            options: .usesLineFragmentOrigin,
                                            context: nil
                ).width

            XCTAssertEqualWithAccuracy(expectedWidth, width, accuracy: 1.0, line: line)
        }
    }

    func testInitialParagraphStyle() {
        let string = NSMutableAttributedString(string: "Test", attributes: [NSParagraphStyleAttributeName: NSParagraphStyle()])
        XCTAssertNotNil(string.attribute(NSParagraphStyleAttributeName, at: 0, effectiveRange: nil) as? NSParagraphStyle)
        string.append(tabStopWithSpacer: 10)
        string.append(string: "ParagraphStyle mutable promotion")
        XCTAssertNotNil(string.attribute(NSParagraphStyleAttributeName, at: 0, effectiveRange: nil) as? NSMutableParagraphStyle)
    }

    /// NSCoding support for StyleAttributeProvider implementations will do nothing, but basic support is present
    /// so NSKeyedArchiver does not throw an exception.
    func testDisappointingNSCodingSupport() {
        let string = styleA.attributedString(from: "astringwithsomewidth")
        string.append(tabStopWithSpacer: 10)
        string.append(image: imageForTest)

        let data = NSKeyedArchiver.archivedData(withRootObject: string)
        var warningTriggerCount = 0
        StyleAttributeProviderHolder.supportWarningClosure = {
            warningTriggerCount += 1
        }
        let unarchivedString = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSAttributedString
        XCTAssertNotNil(unarchivedString)
        let attributes = unarchivedString?.attributes(at: 0, effectiveRange: nil)
        XCTAssertNotNil(attributes)
        let secondUnarchivedString = NSKeyedUnarchiver.unarchiveObject(with: data)
        XCTAssertNotNil(secondUnarchivedString)
        XCTAssertEqual(warningTriggerCount, 1)
    }
}