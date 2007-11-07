/*
 Copyright (c) 2007, Big Nerd Ranch, Inc.
 
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, 
 are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this 
 list of conditions and the following disclaimer.
 
 Redistributions in binary form must reproduce the above copyright notice, this 
 list of conditions and the following disclaimer in the documentation and/or 
 other materials provided with the distribution.
 
 Neither the name of the Big Nerd Ranch, Inc. nor the names of its contributors may 
 be used to endorse or promote products derived from this software without 
 specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. 
 
 IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
                                                           PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
                                                           PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
                                                            NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE
 */

#import "DraggingSourcePDFView.h"
#import "GeometryUtilities.h"

NSImage *dragImage;

@implementation DraggingSourcePDFView

+ (void)initialize
{
    dragImage = [NSImage imageNamed:@"Generic"];
}

- (NSView *)hitTest:(NSPoint)aPoint
{
    if (NSPointInRect(aPoint,[self frame])) {
        return self;
    } else {
        return nil;
    }
}

- (BOOL)shouldDelayWindowOrderingForEvent:(NSEvent *)theEvent; 
{
    return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)flag
{
    return NSDragOperationCopy;
}

- (NSMenu *)menuForEvent:(NSEvent *)e
{
    return nil;
}

- (void)mouseDown:(NSEvent *)e
{
    [NSApp preventWindowOrdering]; 

    [e retain];
    [mouseDownEvent release];
    mouseDownEvent = e;
}

- (void)mouseDragged:(NSEvent *)e
{
    NSPoint start = [mouseDownEvent locationInWindow];
    NSPoint current = [e locationInWindow];
    
    // Is this an insignificant distance from the mouseDown?
    if (distanceSquaredBetweenPoints(start,current) < 52.0) {
        return;
    }
    NSPoint dragStart = [self convertPoint:start 
                                  fromView:nil];
    NSSize imageSize = [dragImage size];
    
    dragStart.x -= imageSize.width / 3.0;
    dragStart.y -= imageSize.height / 3.0;
    
    PDFPage *page = [self currentPage];
    NSData *d = [page dataRepresentation];
    NSPasteboard *dPboard = [NSPasteboard pasteboardWithName:NSDragPboard];
    [dPboard declareTypes:[NSArray arrayWithObject:NSPDFPboardType]
                    owner:self];
    [dPboard setData:d forType:NSPDFPboardType];
    [self dragImage:dragImage
                 at:dragStart
             offset:NSMakeSize(0,0)
              event:mouseDownEvent
         pasteboard:dPboard
             source:self
          slideBack:YES];
    [mouseDownEvent release];
    mouseDownEvent = nil;

}

- (void)mouseUp:(NSEvent *)e
{
    [mouseDownEvent release];
    mouseDownEvent = nil;
}

@end
