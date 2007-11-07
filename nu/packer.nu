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
        (NSLog "MyDocument init")
        (set @packModel ((PackModel alloc) init))
        (@packModel setUndoManager:(self undoManager))
        (NSLog "ending")
        self)
     
     (- (id)windowNibName is "MyDocument")
     
     (- (void)updateUI is
        (@packerView setPackModel:@packModel)
        ((@packerView window) setNextResponder:(CatalogController sharedCatalogController)))
     
     (- (void)windowControllerDidLoadNib:(id) aController is
        (super windowControllerDidLoadNib:aController)
        (NSLog "updating UI")
        (self updateUI)
        (NSLog "update done"))
     
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
                (NSLog "geting size of image")
                (set imageSize ($dragImage size))
                (NSLog "ok")
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

(function pdfFromAttributedStringOfSize (attStr sz)
     (set v ((TextDisplayView alloc) initWithPageSize:sz attributedString:attStr))
     (v dataWithPDFInsideRect:(v bounds)))

(class PackModel is NSObject
     (ivar (id) pageInfos (id) undoManager)
     
     (set BLOCK_COUNT 8)
     
     (- (id) init is
        (super init)
        (NSLog "PackModel init")
        (set @pageInfos ((NSMutableArray alloc) init))
        (BLOCK_COUNT times:
             (do (i) 
                 (@pageInfos addObject:nil)))
        self)
     
     (- (id) preparedImageRepForPage:(int) pageNum is        
        (NSLog "preparedImageRepForPage")
        (set obj (@pageInfos objectAtIndex:pageNum))
        (if obj
            (then 
                  (NSLog "getting prepared imagerep")(obj preparedImageRep))
            (else nil)))
     
     (- (void) replacePageInfoAt:(int) i withPageInfo:(id) pi is
        (NSLog "replacePageInfoAt")
        (set oldInfo (@pageInfos objectAtIndex:i))
        (unless (eq pi oldInfo)
                ;; invocation-based undo is broken
                ;((@undoManager prepareWithInvocationTarget:self) replacePageInfoAt:i withPageInfo:oldInfo)
                (@pageInfos replaceObjectAtIndex:i withObject:pi)
                (NSLog "posting notification")
                ((NSNotificationCenter defaultCenter) postNotificationName:"PackModelChangedNotification" object:self userInfo:NULL)))
     
     (- (void) setImageRep:(id) r pageOfRep:(int) repPage forPage:(int) viewPage is
        (NSLog "setImageRep")
        (set pi ((PageInfo alloc) init))
        (pi setImageRep:r)
        (pi setPageOfRep:repPage)
        (self replacePageInfoAt:viewPage withPageInfo:pi))
     
     (- (id)initWithCoder:(id) c is		
        (NSLog "initWithCoder")
        (super init)
        (set @pageInfos (c decodeObjectForKey:"pageInfos"))
        self)
     
     (- (void)encodeWithCoder:(id) c is
        (c encodeObject:@pageInfos forKey:"pageInfos"))
     
     (- (void) setUndoManager:(id) undo is
        (set @undoManager undo))
     
     (- (id) undoManager is @undoManager)
     
     (- (void) removeAllImageReps is
        (NSLog "removeAllImageReps")
        (BLOCK_COUNT times:
             (do (i)
                 (self replacePageInfoAt:i withPageInfo:nil))))
     
     (- (void) removeImageRepAtPage:(int) i is
        (self replacePageInfoAt:i withPageInfo:nil))
     
     (- (void) swapImageRepAt:(int) i withRepAt:(int) j is
        (NSLog "swapImageRepAt")
        (set pii (@pageInfos objectAtIndex:i))
        (set pij (@pageInfos objectAtIndex:j))
        (self replacePageInfoAt:i  withPageInfo:pij)
        (self replacePageInfoAt:j  withPageInfo:pii))
     
     (- (void) copyImageRepAt:(int) i toRepAt:(int) j is
        (NSLog "copyImageRepAt")
        (set pii (@pageInfos objectAtIndex:i))
        (set pij ((PageInfo alloc) init))
        (pij setImageRep:(pii imageRep))
        (pij setPageOfRep:(pii pageOfRep))
        (self replacePageInfoAt:j withPageInfo:pij))
     
     (- (BOOL)pageIsFilled:(int) i is
        (NSLog "pageIsFilled #{i}")
        (if (@pageInfos objectAtIndex:i) (then 1) (else 0))
        )  
     
     (- (id) textAttributes is
        (NSLog "textAttributes")
        (NSDictionary dictionaryWithObject:((PreferenceController sharedPreferenceController) textFont)
             forKey:NSFontAttributeName))
     
     (- (int) putAttributedString:(id) attStr  startingOnPage:(int) i is
        (NSLog "putAttributedString")
        (set pdf (pdfFromAttributedStringOfSize attStr '(200 300)))
        (self putPDFData:pdf startingOnPage:i)) 
     
     (- (int) putPDF:(id) pdf startingOnPage:(int) i is
        (NSLog "putPDF")
        (set pageCount (pdf pageCount))
        (for ((set j 0)
              (and (< j pageCount) (< (+ j i) BLOCK_COUNT))
              (set j (+ j 1)))
             (self setImageRep:pdf pageOfRep:j forPage:(+ i j)))
        (+ i j))
     
     (- (int) putFile:(id) currentPath startingOnPage:(int) i is
        (NSLog "putFile")
        (set imageRep (NSImageRep imageRepWithContentsOfFile:currentPath))       
        (if (not imageRep)
            (then
                 (set str (NSString stringWithContentsOfFile:currentPath
                               encoding:NSUTF8StringEncoding
                               error:NULL))
                 (if str
                     (then
                          (set atts (self textAttributes))              
                          (set attStr ((NSAttributedString alloc) initWithString:str attributes:atts))
                          (self putAttributedString:attStr startingOnPage:i))
                     (else i)))
            (else
                 (if (imageRep isKindOfClass:NSPDFImageRep)
                     (then 
                           (self putPDF:imageRep startingOnPage:i))
                     (else 
                           (self setImageRep:imageRep
                                 pageOfRep:-1
                                 forPage:i)
                           (+ 1 i))))))
     
     (- (int) putFiles:(id) filenames startingOnPage:(int) i is
        (NSLog "putFiles")
        (set currentStart i)
        (set fileCount (filenames count))
        (for ((set currentFileIndex  0)
              (< currentFileIndex fileCount)
              (set currentFileIndex (+ currentFileIndex 1)))
             (set currentStart (self putFile:(filenames objectAtIndex:currentFileIndex) startingOnPage:currentStart)))
        currentStart)
     
     (- (int) putPDFData:(id) d startingOnPage:(int) i is
        (NSLog "putPDFData")
        (set ir ((NSPDFImageRep alloc) initWithData:d))
        (set pageCount (ir pageCount))        
        (for ((set j 0)
              (and (< j pageCount) (< (+ j i) BLOCK_COUNT))
              (set j (+ j 1)))             
             (self setImageRep:ir
                   pageOfRep:j
                   forPage:(+ i j)))
        (+ i j)))

(puts "ok")
