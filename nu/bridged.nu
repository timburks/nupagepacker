;; @file bridged.nu
;; @discussion Declarations of bridged constants and functions.
;; We can eliminate the need for them by enhancing Nu to read the Apple BridgeSupport files.
;; Project idea, anyone?
;;
;; @copyright Copyright (c) 2007 Tim Burks, Neon Design Technology, Inc.

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
(global NSSquareLineCapStyle 2)