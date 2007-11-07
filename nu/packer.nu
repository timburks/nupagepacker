(global kPDFDisplaySinglePage 0)

(class CatalogController is NSWindowController 
     (ivar (id) pdfView
           (id) pageSlider
           (id) pageField
           (int) currentPageIndex)
     
     (- init is
        (super initWithWindowNibName:"CatalogController")
        (unless $sharedCatalogController
                (set $sharedCatalogController self))
        (set @currentPageIndex 0)
        self)
     
     (set $sharedCatalogController nil)     
     (+ sharedCatalogController is $sharedCatalogController)
     
     (- windowDidLoad is
        (set path ((NSBundle mainBundle) pathForResource:"diyp3h_core_1up" ofType:@"pdf"))
        (unless path (NSLog "No path for pdf"))
        (set url (NSURL fileURLWithPath:path))
        (set pdfDoc ((PDFDocument alloc) initWithURL:url))
        (set pageCount (pdfDoc pageCount))
        (@pageSlider set:
             (numberOfTickMarks:(- pageCount 2)
              minValue:0
              maxValue:(- pageCount 1)))
        (@pdfView setBounds:'(65 90 260 380))
        (@pdfView setDocument:pdfDoc)
        (@pdfView setDisplayMode:kPDFDisplaySinglePage)
        (set w (@pdfView window))
        (w setBecomesKeyOnlyIfNeeded:YES)
        (w setNextResponder:self))
     
     (- (void)changeToPage:(int)i is
        (unless (eq @currentPageIndex i) 
                (set doc (@pdfView document))
                (unless (>= i (doc pageCount)) 
                        (set @currentPageIndex i)
                        (@pdfView goToPage:(doc pageAtIndex:@currentPageIndex))
                        (@pageField setIntValue:(+ @currentPageIndex 1)))))
     
     (- (void)changePage:(id)sender is
        (self changeToPage:(@pageSlider intValue)))
     
     (- (void)scrollWheel:(id)theEvent is
        (set deltaY (theEvent deltaY))
        (if (> deltaY 0.1) 
            (self changeToPage:(+ @currentPageIndex 1))
            (@pageSlider setIntValue:@currentPageIndex))           
        (if (< deltaY -0.1) 
            (self changeToPage:(- @currentPageIndex 1))
            (@pageSlider setIntValue:@currentPageIndex)))
     
     (- (void)moveLeft:(id)sender is
        (self changeToPage:(- @currentPageIndex 1))
        (@pageSlider setIntValue:@currentPageIndex))
     
     (- (void)moveRight:(id)sender is
        (self changeToPage:(+ @currentPageIndex 1))
        (@pageSlider setIntValue:@currentPageIndex))
     
     (- (void)moveUp:(id)sender is
        (self changeToPage:(+ @currentPageIndex 1))
        (@pageSlider setIntValue:@currentPageIndex))
     
     (- (void)moveDown:(id)sender is
        (self changeToPage:(- @currentPageIndex 1))
        (@pageSlider setIntValue:@currentPageIndex)))

(puts "ok")


