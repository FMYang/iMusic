//
//  ListTarget.swift
//  zhihu
//
//  Created by yfm on 2023/10/10.
//

import Foundation
import Alamofire

enum ListAPI {
    case list(SourceView.Source)
}

extension ListAPI: APITarget {
    var host: String {
        "https://gitlab.com"
    }
    
    var path: String {
        switch self {
        case .list(let source):
            "/FMYang/kugou/-/raw/main/raw/\(source.rawValue).json?ref_type=heads".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        }
    }
    
    var sampleData: Data? {
        switch self {
        case .list(let source):
//            if source == .channel1 {
                guard let url = Bundle.main.url(forResource: source.rawValue, withExtension: "json"),
                      let jsonData = try? Data(contentsOf: url) else {
                    return nil
                }
                
                return jsonData
//            } else {
//                return nil
//            }
        }
    }
}
