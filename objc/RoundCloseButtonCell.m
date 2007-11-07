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

#import "RoundCloseButtonCell.h"


@implementation RoundCloseButtonCell


- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    
    if ([NSGraphicsContext currentContextDrawingToScreen]) {
        if ([self isHighlighted]) {
            [[NSColor orangeColor] set];
        } else {
            [[NSColor blueColor] set];
        }
        [NSBezierPath fillRect:cellFrame];
        [NSBezierPath setDefaultLineWidth:3];
        [[NSColor whiteColor] set];
        [NSBezierPath strokeRect:cellFrame];
        NSBezierPath *p = [[NSBezierPath alloc] init];
        [p setLineWidth:3.0];
        [p setLineCapStyle:NSSquareLineCapStyle];
        
        NSRect xRect = NSInsetRect(cellFrame, 9,7);
        [p moveToPoint:xRect.origin];
        [p lineToPoint:NSMakePoint(xRect.origin.x + xRect.size.width, xRect.origin.y + xRect.size.height)];
        
        [p moveToPoint:NSMakePoint(xRect.origin.x, xRect.origin.y + xRect.size.height)];
        [p lineToPoint:NSMakePoint(xRect.origin.x + xRect.size.width, xRect.origin.y)];
        
        [[NSColor whiteColor] set];
        [p stroke];
        
    }
     
}

@end
