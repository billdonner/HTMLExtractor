import XCTest
@testable import HTMLExtractor


final class HTMLExtractorTests: XCTestCase {
    func extractTest(url:URL,expectedTitle:String,expectedLinkCount:Int)->Bool {
        func iextractTest(html:String,expectedTitle:String,expectedLinkCount:Int) -> Bool {
            let extracted = HTMLExtractor.extractFrom(html: html)
            let titlematch = extracted.title == expectedTitle
            if !titlematch {// print("failed titles - \(extracted.title)")
                
            }
            let countmatch = extracted.links.count == expectedLinkCount
            if !countmatch  { //print("failed count - \(extracted.links.count)")
                
            }
            let passtest = countmatch && titlematch
           // passtest ? print("*passed") : print("*failed")
            return passtest
        }
        do {
            let html = try String(contentsOf: url, encoding: .utf8)
            return iextractTest(html: html,expectedTitle:expectedTitle,expectedLinkCount:expectedLinkCount)
        }
        catch {
            print("Could not get contents Of \(url)")
            return false
        }
    }
    
    
    func testextractsA() {
        
        let a =    extractTest(url: URL(string: "https://billdonner.github.io/LinkGrubber/linkgrubberexamples/zero-site/")!,
                               expectedTitle: "Completely Empty Page With One Bad Link",expectedLinkCount: 2)
        XCTAssert(a)
        
    }
    func testextractsB() {
        
        let b =
            extractTest(url: URL(string: "https://billdonner.github.io/LinkGrubber/linkgrubberexamples/one-site/")!,
                        expectedTitle: "Assorted Links to Parse",expectedLinkCount: 5)
        XCTAssert(b)
    }
    func testextractsC() {
        let c =  extractTest(url: URL(string: "https://billdonner.github.io/LinkGrubber/linkgrubberexamples/two-site/")!,
                             expectedTitle: "Two Link Page",expectedLinkCount: 0)
        XCTAssert(c)
    }
    func testextractsD() {
        //this page does not exist and tus is assumed to fail
        let c =  extractTest(url: URL(string: "https://billdonner.github.io/LinkGrubber/linkgrubberexamples/one-site/zero-site")!,
                             expectedTitle: "Two Link Page",expectedLinkCount: 0)
        XCTAssert(!c)
    }
    func testextractsE() {
        //this page does not exist and tus is assumed to fail
        let c =  extractTest(url: URL(string: "https://billdonner.github.io/LinkGrubber/linkgrubberexamples/one-site/one-site")!,
                             expectedTitle: "Two Link Page",expectedLinkCount: 0)
        XCTAssert(!c)
    }

    
    static var allTests = [
        ("testextractsA", testextractsA),
        ("testextractsB", testextractsB),
        ("testextractsC", testextractsC),
        ("testextractsD", testextractsD),
        ("testextractsE", testextractsE)
    ]
}
