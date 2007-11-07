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

#import "CatalogController.h"
CatalogController *sharedCatalogController;

@implementation CatalogController

- (id)init
{
    [super initWithWindowNibName:@"CatalogController"];
    if (!sharedCatalogController) {
        sharedCatalogController = self;
    }
    currentPageIndex = 0;
    return self;
}
+ (CatalogController *)sharedCatalogController
{
    return sharedCatalogController;
}

- (void)windowDidLoad
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"diyp3h_core_1up"
                                                     ofType:@"pdf"];
    if (!path) {
        NSLog(@"No path for pdf");
    }
    
    NSURL *url = [NSURL fileURLWithPath:path];
    
    PDFDocument *pdfDoc = [[PDFDocument alloc] initWithURL:url];
    int pageCount = [pdfDoc pageCount];
    [pageSlider setNumberOfTickMarks:(pageCount - 2)];
    [pageSlider setMinValue:0];
    [pageSlider setMaxValue:pageCount - 1];
    NSRect newBounds = NSMakeRect(65,90, 260, 380);
    [pdfView setBounds:newBounds];
    [pdfView setDocument:pdfDoc];
    [pdfDoc release];
    [pdfView setDisplayMode:kPDFDisplaySinglePage];
    NSPanel *w = (NSPanel *)[pdfView window];
    [w setBecomesKeyOnlyIfNeeded:YES];
    [w setNextResponder:self];
}

- (void)changeToPage:(int)i
{
    if (currentPageIndex == i) {
        return;
    }
    
    PDFDocument *doc = [pdfView document];
    if (i >= [doc pageCount]) {
        return;
    }
    currentPageIndex = i;
    PDFPage *page = [doc pageAtIndex:currentPageIndex];
    [pdfView goToPage:page];
    [pageField setIntValue:currentPageIndex + 1];
}

- (void)changePage:(id)sender
{
    int newPage = [pageSlider intValue];
    [self changeToPage:newPage];
}

- (void)scrollWheel:(NSEvent *)theEvent
{
    float deltaY = [theEvent deltaY];
    if (deltaY > 0.1) {
        [self changeToPage:currentPageIndex + 1];
        [pageSlider setIntValue:currentPageIndex];
    } 
    if (deltaY < -0.1) {
        [self changeToPage:currentPageIndex - 1];
        [pageSlider setIntValue:currentPageIndex];

    }
}
- (void)moveLeft:(id)sender
{
    [self changeToPage:currentPageIndex - 1];
    [pageSlider setIntValue:currentPageIndex];
}

- (void)moveRight:(id)sender
{
    [self changeToPage:currentPageIndex + 1];
    [pageSlider setIntValue:currentPageIndex];

}

- (void)moveUp:(id)sender
{
    [self changeToPage:currentPageIndex + 1];
    [pageSlider setIntValue:currentPageIndex];
}
- (void)moveDown:(id)sender
{
    [self changeToPage:currentPageIndex - 1];
    [pageSlider setIntValue:currentPageIndex];
}



/*
- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
    int children = [outline numberOfChildren];
    NSLog(@"%@, children = %d", outline, children);
    return children;
}
- (id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn 
            row:(int)row
{
    PDFOutline *child = [outline childAtIndex:row];
    return [child label];
}
*/
@end
