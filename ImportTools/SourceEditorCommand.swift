//
//  SourceEditorCommand.swift
//  ImportTools
//
//  Created by 张行 on 2018/11/29.
//  Copyright © 2018 张行. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
        invocation.buffer.completeBuffer = sortImportText(invocation: invocation)
        completionHandler(nil)
    }
    
    func sortImportText(invocation: XCSourceEditorCommandInvocation) -> String {
        /* 储存第一次出现 import 所在行数位置 */
        var importSrartLineNumber = 0
        /* 储存#import ""行 */
        var importFiles:[String] = []
        /* 储存 #import <>行 */
        var importFrameworks:[String] = []
        /* 文件所有行 */
        guard var lines = invocation.buffer.lines as? [String] else {
            return invocation.buffer.completeBuffer
        }
        
        for line in invocation.buffer.lines.enumerated() {
            guard let lineText = line.element as? String else {
                continue
            }
            var needDel:Bool = false
            if lineText.range(of: "#import") != nil && lineText.range(of: "\"") != nil {
                /* 查找到#import "" 行*/
                importFiles.append(lineText)
                needDel = true
            } else if lineText.range(of: "#import") != nil && lineText.range(of: "<") != nil {
                /* 查找到#import <> 行*/
                importFrameworks.append(lineText)
                needDel = true
            }
            
            if needDel, let delIndex = lines.index(of: lineText) {
                if importSrartLineNumber == 0 {
                    importSrartLineNumber = delIndex
                }
                lines.remove(at: delIndex)
            }
        }
        
        importFrameworks = importFrameworks.sorted { (left, right) -> Bool in
            let result = left.compare(right)
            if result == ComparisonResult.orderedAscending {
                return true
            } else {
                return false
            }
        }
        
        importFiles = importFiles.sorted(by: { (left, right) -> Bool in
            let result = left.compare(right)
            if result == ComparisonResult.orderedAscending {
                return true
            } else {
                return false
            }
        })
        
        lines.insert(contentsOf: importFrameworks, at: importSrartLineNumber)
        importSrartLineNumber += importFrameworks.count
        lines.insert("\n", at: importSrartLineNumber)
        importSrartLineNumber += 1
        lines.insert(contentsOf: importFiles, at: importSrartLineNumber)
        print(lines)
        return lines.joined(separator: "")
    }
    
}
