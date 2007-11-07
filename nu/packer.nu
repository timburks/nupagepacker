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


(class MyDocument
     
     (- (id)init is
        (super init)
        (set @packModel ((PackModel alloc) init))
        (@packModel setUndoManager:(self undoManager))
        self)
     
     (- (id)windowNibName is "MyDocument")
     
     (- (void)updateUI is
        (@packerView setPackModel:@packModel)
        ((@packerView window) setNextResponder:(CatalogController sharedCatalogController)))
     
     (- (void)windowControllerDidLoadNib:(id) aController is
        (super windowControllerDidLoadNib:aController)
        (self updateUI))
     
     (- (id)dataRepresentationOfType:(id)aType is
        (NSKeyedArchiver archivedDataWithRootObject:@packModel))
     
     (- (BOOL)loadDataRepresentation:(id)data ofType:(id)aType is
        (@packModel release)
        (set @packModel (NSKeyedUnarchiver unarchiveObjectWithData:data))
        (@packModel setUndoManager:(self undoManager))
        (if @packerView (self updateUI))
        YES))

(global NSDragOperationCopy 1)
(global NSPDFPboardType "Apple PDF pasteboard type")
(global NSDragPboard "Apple CFPasteboard drag")

(function PointInRect (point rect)
     (and
         (>= (point first) (rect first))
         (>= (point second) (rect second))
         (<= (point first) (+ (rect first) (rect third)))
         (<= (point second) (+ (rect second) (rect fourth)))))

(function distanceSquaredBetweenPoints (p1 p2)
     (set deltax (- (p1 first) (p2 first)))
     (set deltay (- (p1 second) (p2 second)))
     (+ (* deltax deltax) (* deltay deltay)))

(class DraggingSourcePDFView is PDFView 
     (ivar (id) mouseDownEvent)
     
     (+ (void) initialize is
        (NSLog "initialize is not getting called... or is it?")
        (set $dragImage (NSImage imageNamed:"Generic")))
     
     (- (id)hitTest:(NSPoint) aPoint is
        (if (PointInRect aPoint (self frame)) 
            (then self)
            (else nil)))
     
     (- (BOOL) shouldDelayWindowOrderingForEvent:(id) theEvent is YES)
     
     (- (BOOL) acceptsFirstMouse:(id) theEvent is YES)
     
     (- (int) draggingSourceOperationMaskForLocal:(BOOL) flag is NSDragOperationCopy)
     
     (- (id) menuForEvent:(id) e is NULL)
     
     (- (void) mouseDown:(id) e is
        (NSApp preventWindowOrdering)
        (set @mouseDownEvent e))
     
     (- (void) mouseDragged:(id) e is
        (unless $dragImage (set $dragImage (NSImage imageNamed:"Generic")))
     
        (set start (@mouseDownEvent locationInWindow))
        (set current (e locationInWindow))
        
        ;; Is this a significant distance from the mouseDown?
        (unless (< (distanceSquaredBetweenPoints start current) 52.0)              
                (set dragStart (self convertPoint:start fromView:NULL))
                (set imageSize ($dragImage size))
                (set dragStart (list (- (dragStart first) (/ (imageSize first) 3.0))
                                     (- (dragStart second) (/ (imageSize second) 3.0))))
                (set page (self currentPage))
                (set d (page dataRepresentation))
                (set dPboard (NSPasteboard pasteboardWithName:NSDragPboard))
                (dPboard declareTypes:(NSArray arrayWithObject:NSPDFPboardType) owner:self)
                (dPboard setData:d forType:NSPDFPboardType)
                (self dragImage:$dragImage
                      at:dragStart
                      offset:'(0 0)
                      event:@mouseDownEvent
                      pasteboard:dPboard
                      source:self
                      slideBack:YES)
                (set @mouseDownEvent nil)))
     
     (- (void) mouseUp:(id) e is
        (set @mouseDownEvent nil)))


(puts "ok")


