;; @file bridged.nu
;; @discussion Declarations of bridged constants and functions.
;;
;; @copyright Copyright (c) 2007 Tim Burks, Neon Design Technology, Inc.

(if nil ;; don't load BridgeSupport files, all the constants that we need are defined below.	
    ;; Switch on OS release.
    ;;(>= 9 ((((NSString stringWithShellCommand:"uname -r") componentsSeparatedByString:".") objectAtIndex:0) intValue))
    (then ;; Use Leopard BridgeSupport files
          (load "bridgesupport")
          (import AppKit)
          (import Quartz))
    (else ;; declare constants manually
          (global kPDFDisplaySinglePage 0)
          (global NSDragOperationCopy 1)
          (global NSPDFPboardType "Apple PDF pasteboard type")
          (global NSDragPboard "Apple CFPasteboard drag")
          (global NSRectClip (NuBridgedFunction functionWithName:"NSRectClip" signature:"v{_NSRect}"))
          (global NSIntersectionRect (NuBridgedFunction functionWithName:"NSIntersectionRect" signature:"{_NSRect}{_NSRect}{_NSRect}"))
          (global NSPointInRect (NuBridgedFunction functionWithName:"NSPointInRect" signature:"i{_NSPoint}{_NSRect}"))
          (global NSFilenamesPboardType "NSFilenamesPboardType")
          (global NSIntersectsRect (NuBridgedFunction functionWithName:"NSIntersectsRect" signature:"i{_NSRect}{_NSRect}"))
          (global NSInsetRect (NuBridgedFunction functionWithName:"NSInsetRect" signature:"{_NSRect}{_NSRect}ff"))
          (global NSSquareLineCapStyle 2)))