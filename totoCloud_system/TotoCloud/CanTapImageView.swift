//
//  CanTapImageView.swift
//  totoCloud
//
//  Created by 黄龙 on 2023/3/21.
//  Copyright © 2023 ParadiseDuo. All rights reserved.
//

import Cocoa

//MARK: 使用NSImageView鼠标按下也能拖动窗体
class CanTapImageView: NSImageView {
    override var mouseDownCanMoveWindow:Bool {
        return true
    }
}

class CancelTapView: NSView {
    override func mouseDown(with event: NSEvent) {
        
    }
    override func mouseUp(with event: NSEvent) {
        
    }
}

//MARK: 使用NSScrollViews鼠标按下也能拖动窗体
class CanTapScrollview: NSScrollView {
    override var mouseDownCanMoveWindow:Bool {
        return true
    }
}

//MARK: 自定义NSTableRowView选中背景
class YQTableRowView : NSTableRowView {
    override func drawSelection(in dirtyRect: NSRect) {
        if self.selectionHighlightStyle != .none {
            let selectionRect = bounds.insetBy(dx: 25, dy: 0)
            NSColor("#CADEFA").setFill()
            let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 3, yRadius: 3)
            selectionPath.fill()
        }
    }
}


//MARK: 自定义NSTextField的光标颜色
class YQTextField: NSTextField {
    var insertColor: NSColor!
    override func becomeFirstResponder() -> Bool {
        let success = super.becomeFirstResponder()
        if success{//setInsertionPointColor
            let textfield = self.currentEditor()!
            self.cell?.setInsertionColor(textfield,insertColor)
        }
        return success
    }
}

extension NSCell {
    func setInsertionColor(_ textObj: NSText,_ color: NSColor){
        let text = self.setUpFieldEditorAttributes(textObj) as! NSTextView
        text.insertionPointColor = color
    }
}

//MARK: NSTextField只能输入数字
class OnlyIntegerValueFormatter: NumberFormatter {
    override func isPartialStringValid(_ partialStringPtr: AutoreleasingUnsafeMutablePointer<NSString>, proposedSelectedRange proposedSelRangePtr: NSRangePointer?, originalString origString: String, originalSelectedRange origSelRange: NSRange, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
         if  0 == partialStringPtr.pointee.length {
            return true
        }
        let scanner = Scanner(string: partialStringPtr.pointee as String)
        if !(scanner.scanInt(UnsafeMutablePointer(bitPattern: 0)) && scanner.isAtEnd){
            return false
        }
        return true
    }
    
}
