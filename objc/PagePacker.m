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

#import <Cocoa/Cocoa.h>

// The code below is what remains of Aaron's original Objective-C source.
// All comments are mine (Tim Burks).

// We leave these class and method definitions in Objective-C.
// For various reasons, each is currently not representable in Nu.

@interface MyDocument : NSDocument
{
    // since we use these two ivars in Objective-C, keep their declarations here.
    // all other ivars are declared in Nu.
    id packModel;
    id packerView;
}

@end

@implementation MyDocument
// We can't declare a method in Nu with an argument that's an (NSError **)
- (id) printOperationWithSettings:(id)printSettings error:(NSError **)outError
{
    [NSPrintOperation printOperationWithView:packerView printInfo:[self printInfo]];
}

@end

@interface PackerView : NSView
{
    // all ivars are declared in Nu.
}

@end

@interface PackerView (Nu)
- (void) setImageablePageRect:(NSRect) r;
@end

@implementation PackerView

// I don't like writing dealloc methods in Nu.
// It's not clear to me that they would get called at the right time
// in the deallocation process.
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

// Nu can't declare methods with arguments that are pointers to NSRanges
- (BOOL)knowsPageRange:(NSRange *)rptr
{
    // As a sort of odd side-effect,  I'm also informing the view
    // of how much of the page the printer can actually draw.
    // I waited until now so that I could use the printer that the
    // user actually selected.
    id op = [NSPrintOperation currentOperation];
    id pi = [op printInfo];
    if (pi)
        [self setImageablePageRect:[pi imageablePageBounds]];

    // It is a one-page document
    rptr->location = 1;
    rptr->length = 1;
    return YES;
}

- (NSBezierPath *) cutlineFromPoint:(NSPoint) p1 toPoint:(NSPoint) p2
{
    float dashes[2] = {7.0, 3.0};
    NSBezierPath *cutLine = [NSBezierPath bezierPath];
    // We can't pass this C array of floats to a Nu method (yet).
    [cutLine setLineDash:dashes
        count:2
        phase:0];
    [cutLine moveToPoint:p1];
    [cutLine lineToPoint:p2];
    [cutLine setLineWidth:1.0];
    return cutLine;
}

@end
