
//
//  HTMLExtractor.swift
//
//
//  Created by william donner on 1/12/20.
//  I was motivated to replace Kanna in my apps because I started having wierd warning about mac libraries used in ios

import Foundation
struct HTMLExtractorName {
    var text = "HTMLExtractor"
}

//https://stackoverflow.com/questions/46850186/trying-to-parse-html-in-swift-4-using-only-the-standard-library
//thank you https://stackoverflow.com/users/2303865/leo-dabus for the basics

//MARK:- Public Interface

public enum Linktype {
    case leaf
    case hyperlink
}
public struct LinkElement  {
  public var  title: String
   public   var  href: URL?
  public  var  linktype: Linktype
    
    // when a LinkElement is creted, it tries to make a url from the supplied string
    public init(title:String,href:String,linktype:Linktype,relativeTo:URL?) {
        self.title = title; self.href=URL(string:href,relativeTo:relativeTo); self.linktype=linktype
    }
}
public struct ExtractedFromHTML {
    public struct Link {
        let href : String
        let contents : String
    }
    let title: String
    let links: [Link]
}
public struct ScrapeAndAbsorbBlock {
    public var title: String
    public var links:[LinkElement]
    public init(title:String,links:[LinkElement]){
        self.title = title
        self.links = links
    }
}
// must be open not public for externalized access
open class HTMLExtractor {
    public class func extractFrom(html:String)->ExtractedFromHTML {
        html.extract()
    }
}
extension HTMLExtractor {
    //this function needs a testcase
    public static func converttoScrapeAndAbsorbBlock(_ x:ExtractedFromHTML,relativeTo:URL?) -> ScrapeAndAbsorbBlock {
        var linkelements:[LinkElement] = []
        for y in x.links {
            linkelements.append(LinkElement(title: y.contents, href: y.href, linktype: .hyperlink, relativeTo: relativeTo))
        }
        return ScrapeAndAbsorbBlock(title: x.title, links: linkelements)
    }
}
//MARK:- String Extractions for Parsing
fileprivate extension String {
    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.lowerBound < range.upperBound ? range.upperBound : index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    func slices(from: String, to: String) -> [Substring] {
        let pattern = "(?<=" + from + ").*?(?=" + to + ")"
        return ranges(of: pattern, options: .regularExpression) .map{ self[$0] }
    }
    func extractAnchors()-> [Substring] {
        self.slices(from: "href=\"", to: "\"")
    }
    func extractAnchorBodies()->([Substring], [Substring]) {
        let x = self.slices(from: "href=\"", to: "</a>")
        
        let anchors = x.map() { $0.split(separator:  "\"").first ?? "shite"}
        
        let y = x.map(){$0.split(separator:">").last ?? "xxx"} // supply default so we always have a body
        
        let z = y.map(){$0.split(separator:"<").first ?? "zzz"}
        
        return (anchors,z)
    }
    func extractTitle()-> [Substring] {
        self.slices(from: "<title>", to: "</title>")
    }
    func extract()->ExtractedFromHTML{
        let title = extractTitle().first ?? "NO-TITLE"
        let (x,y) = extractAnchorBodies()
        assert(x.count == y.count,"bad counts \(x.count) != \(y.count)")
        var z : [ExtractedFromHTML.Link] = []
        for i in 0..<x.count {
            z.append(ExtractedFromHTML.Link(href: String(x[i]),contents: String(y[i])))
        }
        return ExtractedFromHTML(title: String(title),links: z)
    }
}//class HTMLExtractor


extension HTMLExtractor {
    static func generalScrapeAndAbsorb (theURL:URL, html:String ) throws -> ScrapeAndAbsorbBlock {
        
        var encounterdLinks:[LinkElement]=[]
        
        func absorbLink(href:String? , txt:String? ,relativeTo: URL?, tag: String )  {
            if let lk = href, //link["href"] ,
                let url = URL(string:lk,relativeTo:relativeTo) {
                let linktype = Linktype.hyperlink
                //processExtension(lgFuncs: lgFuncs, url:url, relativeTo: relativeTo) {
                
                // strip exension if any off the title
                let parts = (txt ?? "fail").components(separatedBy: ".")
                if let ext  = parts.last,  let front = parts.first , ext.count > 0
                {
                    let subparts = front.components(separatedBy: "-")
                    if let titl = subparts.last {
                        let titw =  titl.trimmingCharacters(in: .whitespacesAndNewlines)
                        encounterdLinks.append(LinkElement(title:titw,href:url.absoluteString,linktype:linktype, relativeTo: relativeTo))
                    }
                } else {
                    // this is what happens upstream
                    if  let txt  = txt  {  encounterdLinks.append(LinkElement(title:txt,href:url.absoluteString,linktype:linktype, relativeTo: relativeTo))
                    }
                }
            }
        }// end of absorbLink
        var maintitle = ""
        
        
        func setupWithout() throws {
            let z = HTMLExtractor.extractFrom(html:    html)
            maintitle = z.title
            
            for link in z.links {
                absorbLink(href:link.href,
                           txt: link.contents,
                           relativeTo:theURL,
                           tag: "media")
            }
        }
        
        try setupWithout()//setupWithKanna()//setupWithout()
        return ScrapeAndAbsorbBlock(title:  maintitle, links: encounterdLinks)
    }
}
