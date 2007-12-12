;; @file packer.nu
;; @discussion PagePacker in Nu.
;;
;; @copyright Copyright (c) 2007 Tim Burks, Neon Design Technology, Inc.
;; Substantially derived from original Objective-C source code by Aaron Hillegass.
;; See objc/PagePacker.m for the copyright notice for the original code.

(global BLOCK_COUNT 8) ;; We display 8 pages in a PagePacker document.  There is no easy way to change this.

;; @class CatalogController
;; @discussion This class controls the display of the PDF source document.
;; Pages can be dragged from this document into the PagePacker document view. 
(class CatalogController is NSWindowController
     (ivar (id) pdfView
           (id) pageSlider
           (id) pageField
           (int) currentPageIndex)
     
     (set sharedCatalogController nil) ;; Since the assignment is made inside the class declaration, Nu closures make this a class variable.
     
     (+ sharedCatalogController is sharedCatalogController)
     
     (- init is
        (super initWithWindowNibName:"CatalogController")
        (unless sharedCatalogController
                (set sharedCatalogController self))
        (set @currentPageIndex 0)
        self)
     
     (- windowDidLoad is
        (set path ((NSBundle mainBundle) pathForResource:"diyp3h_core_1up" ofType:@"pdf"))
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
        (set w (self window))
        (w setBecomesKeyOnlyIfNeeded:YES)
        (w setNextResponder:self))
     
     (- (void)changeToPage:(int)i is
        (unless (eq @currentPageIndex i) 
                (set doc (@pdfView document))
                (unless (or (< i 0) (>= i (doc pageCount)))
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

;; @class MyDocument
;; @discussion This is the main PagePacker document.
(class MyDocument is NSDocument
     (ivar (id) packModel (id) packerView)
     
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
        (set @packModel (NSKeyedUnarchiver unarchiveObjectWithData:data))
        (@packModel setUndoManager:(self undoManager))
        (if @packerView (self updateUI))
        YES)
     
     (- (id) printOperationWithSettings:(id)printSettings error:(id *)errorReference is
        (NSPrintOperation printOperationWithView:@packerView printInfo:(self printInfo))))

;; @class DragingSourcePDFView
;; @discussion This class controls the view of the source document.
(class DraggingSourcePDFView is PDFView 
     (ivar (id) mouseDownEvent)
     
     (+ (void) initialize is
        (set $dragImage (NSImage imageNamed:"Generic")))
     
     (- (id) hitTest:(NSPoint) aPoint is
        (if (PointInRect aPoint (self frame)) 
            (then self)
            (else nil)))
     
     (- (BOOL) shouldDelayWindowOrderingForEvent:(id) theEvent is YES)
     
     (- (BOOL) acceptsFirstMouse:(id) theEvent is YES)
     
     (- (int) draggingSourceOperationMaskForLocal:(BOOL) flag is NSDragOperationCopy)
     
     (- (id) menuForEvent:(id) e is nil)
     
     (- (void) mouseDown:(id) e is
        (NSApp preventWindowOrdering)
        (set @mouseDownEvent e))
     
     (- (void) mouseDragged:(id) e is
        (set start (@mouseDownEvent locationInWindow))
        (set current (e locationInWindow))
        
        ;; Is this a significant distance from the mouseDown?
        (unless (< (distanceSquaredBetweenPoints start current) 52.0)              
                (set dragStart (self convertPoint:start fromView:nil))
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

;; @class PackModel
;; @discussion This class describes the PagePacker document.
(class PackModel is NSObject
     (ivar (id) pageInfos (id) undoManager)
     
     (- (id) init is
        (super init)
        (set @pageInfos ((NSMutableArray alloc) init))
        (BLOCK_COUNT times: (do (i) (@pageInfos addObject:nil)))
        self)
     
     (- (id) preparedImageRepForPage:(int) pageNum is   
        (set obj (@pageInfos objectAtIndex:pageNum))
        (if obj
            (then (obj preparedImageRep))
            (else nil)))
     
     (- (void) replacePageInfoAt:(int) i withPageInfo:(id) pi is
        (set oldInfo (@pageInfos objectAtIndex:i))
        (unless (eq pi oldInfo)
                ((@undoManager prepareWithInvocationTarget:self) replacePageInfoAt:i withPageInfo:oldInfo)
                (@pageInfos replaceObjectAtIndex:i withObject:pi)
                ((NSNotificationCenter defaultCenter) postNotificationName:"PackModelChangedNotification" object:self userInfo:nil)))
     
     (- (void) setImageRep:(id) r pageOfRep:(int) repPage forPage:(int) viewPage is
        (set pi ((PageInfo alloc) init))
        (pi setImageRep:r)
        (pi setPageOfRep:repPage)
        (self replacePageInfoAt:viewPage withPageInfo:pi))
     
     (- (id)initWithCoder:(id) c is		
        (super init)
        (set @pageInfos (c decodeObjectForKey:"pageInfos"))
        self)
     
     (- (void)encodeWithCoder:(id) c is
        (c encodeObject:@pageInfos forKey:"pageInfos"))
     
     (- (void) setUndoManager:(id) undo is
        (set @undoManager undo))
     
     (- (id) undoManager is @undoManager)
     
     (- (void) removeAllImageReps is
        (BLOCK_COUNT times:
             (do (i)
                 (self replacePageInfoAt:i withPageInfo:nil))))
     
     (- (void) removeImageRepAtPage:(int) i is
        (self replacePageInfoAt:i withPageInfo:nil))
     
     (- (void) swapImageRepAt:(int) i withRepAt:(int) j is
        (set pii (@pageInfos objectAtIndex:i))
        (set pij (@pageInfos objectAtIndex:j))
        (self replacePageInfoAt:i  withPageInfo:pij)
        (self replacePageInfoAt:j  withPageInfo:pii))
     
     (- (void) copyImageRepAt:(int) i toRepAt:(int) j is
        (set pii (@pageInfos objectAtIndex:i))
        (set pij ((PageInfo alloc) init))
        (pij setImageRep:(pii imageRep))
        (pij setPageOfRep:(pii pageOfRep))
        (self replacePageInfoAt:j withPageInfo:pij))
     
     (- (BOOL)pageIsFilled:(int) i is
        (if (@pageInfos objectAtIndex:i) (then 1) (else 0)))  
     
     (- (id) textAttributes is
        (NSDictionary dictionaryWithObject:((PreferenceController sharedPreferenceController) textFont)
             forKey:NSFontAttributeName))
     
     (- (int) putAttributedString:(id) attStr  startingOnPage:(int) i is
        (set pdf (pdfFromAttributedStringOfSize attStr '(200 300)))
        (self putPDFData:pdf startingOnPage:i)) 
     
     (- (int) putPDF:(id) pdf startingOnPage:(int) i is
        (set pageCount (pdf pageCount))
        (for ((set j 0)
              (and (< j pageCount) (< (+ j i) BLOCK_COUNT))
              (set j (+ j 1)))
             (self setImageRep:pdf pageOfRep:j forPage:(+ i j)))
        (+ i j))
     
     (- (int) putFile:(id) currentPath startingOnPage:(int) i is
        (set imageRep (NSImageRep imageRepWithContentsOfFile:currentPath))       
        (if (not imageRep)
            (then
                 (set str (NSString stringWithContentsOfFile:currentPath
                               encoding:NSUTF8StringEncoding
                               error:nil))
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
        (set currentStart i)
        (set fileCount (filenames count))
        (for ((set currentFileIndex  0)
              (< currentFileIndex fileCount)
              (set currentFileIndex (+ currentFileIndex 1)))
             (set currentStart (self putFile:(filenames objectAtIndex:currentFileIndex) startingOnPage:currentStart)))
        currentStart)
     
     (- (int) putPDFData:(id) d startingOnPage:(int) i is
        (set ir ((NSPDFImageRep alloc) initWithData:d))
        (set pageCount (ir pageCount))        
        (for ((set j 0)
              (and (< j pageCount) (< (+ j i) BLOCK_COUNT))
              (set j (+ j 1)))             
             (self setImageRep:ir
                   pageOfRep:j
                   forPage:(+ i j)))
        (+ i j)))

;; @class PageInfo
;; @discussion This class describes an individual page in a PagePacker document.
(class PageInfo is NSObject 
     (ivar (id) imageRep (int) pageOfRep)
     
     (- (void) encodeWithCoder:(id) c is
        (c encodeObject:@imageRep forKey:@"imageRep")
        (c encodeInt:@pageOfRep forKey:@"pageOfRep"))
     
     (- (id) initWithCoder:(id) c is
        (super init)
        (set @imageRep (c decodeObjectForKey:@"imageRep"))
        (set @pageOfRep (c decodeIntForKey:@"pageOfRep"))
        self)
     
     (- (id) preparedImageRep is
        (if (>= @pageOfRep 0) 
            (@imageRep setCurrentPage:@pageOfRep))
        @imageRep)
     
     (- (void) setImageRep:(id) r is
        (set @imageRep r))
     
     (- (id) imageRep is @imageRep)   
     
     (- (void)setPageOfRep:(int)i is
        (set @pageOfRep i))
     
     (- (int)pageOfRep is @pageOfRep)
     
     (- (id)description is
        "<PageInfo: #{(@imageRep description)}, #{@pageOfRep}>"))

;; @class RoundCloseButtonCell
;; @discussion This class provides a custom button cell for use in the PackerView display.
(class RoundCloseButtonCell is NSButtonCell 
     (- (void)drawWithFrame:(NSRect)cellFrame inView:(id)controlView is        
        (if (NSGraphicsContext currentContextDrawingToScreen) 
            (if (self isHighlighted) 
                (then ((NSColor orangeColor) set))
                (else ((NSColor blueColor) set)))
            (NSBezierPath fillRect:cellFrame)
            (NSBezierPath setDefaultLineWidth:3)
            ((NSColor whiteColor) set)
            (NSBezierPath strokeRect:cellFrame)
            (set p ((NSBezierPath alloc) init))
            (p setLineWidth:3.0)
            (p setLineCapStyle:NSSquareLineCapStyle)
            (set xRect (NSInsetRect cellFrame 9 7))
            (p moveToPoint:(list (xRect first) (xRect second)))
            (p lineToPoint:(list (+ (xRect first) (xRect third)) (+ (xRect second) (xRect fourth))))
            (p moveToPoint:(list (xRect first)  (+ (xRect second) (xRect fourth))))
            (p lineToPoint:(list (+ (xRect first) (xRect third)) (xRect second)))
            ((NSColor whiteColor) set)
            (p stroke))))

;; @class PackerView
;; @discussion This class provides a view of a PagePacker document.
(class PackerView
     (ivar (id) packModel
           (id) foldLines
           (id) cutLine
           (NSRect) imageablePageRect
           (BOOL) showsImageableRect
           (int) dropPage
           (int) dragStart)
     
     (set numberAttributes nil) ;; a class variable to hold the attribute dictionary for displayed numbers.
     (set buttonMargin 4.0)     ;; a class variable that specifies the position of our custom close buttons.
     
     ;; determine whether a page is on the left or right side of the PageView display.
     ;; Because this function is defined in the class declaration, it is effectively local (private) to this class.
     (function isLeftSide (pageNum) (or (eq pageNum 0) (> pageNum 4)))
     
     (+ (void) initialize is
        (set numberAttributes ((NSMutableDictionary alloc) init))
        (numberAttributes setObject:(NSFont fontWithName:"Helvetica" size:40.0) forKey:NSFontAttributeName)
        (numberAttributes setObject:(NSColor blueColor) forKey:NSForegroundColorAttributeName))      
     
     (- (id) initWithFrame:(NSRect) frameRect is
        (super initWithFrame:frameRect)       
        (set @imageablePageRect (NSInsetRect (self bounds) 15.0 15.0))
        (self registerForDraggedTypes:(array NSPDFPboardType NSFilenamesPboardType))
        (set @dropPage -1)
        (set @dragStart -1)
        ((NSNotificationCenter defaultCenter) addObserver:self
         selector:"paperSizeChanged:"
         name:"PaperSizeChangedNotification"
         object:nil)
        (self prepareBezierPaths)
        (set b ((NSButton alloc) initWithFrame:'(0 0 20 20)))
        (b setCell:((RoundCloseButtonCell alloc) init))
        (self addSubview:b)
        self)
     
     (- (void) correctWindowForChangeFromSize:(NSSize) oldSize toSize:(NSSize) newSize is
        (set oldFrame ((self window) frame))
        (set frame (list
                        (oldFrame first)
                        (oldFrame second)
                        (newSize first)
                        (newSize second)))
        ((self window) setFrame:frame display:YES))
     
     (- (void) updateSize is
        (set oldSize (list ((self frame) third) ((self frame) fourth)))
        (set newSize ((PreferenceController sharedPreferenceController) paperSize))
        (self setFrameSize:newSize)
        (self correctWindowForChangeFromSize:oldSize toSize:newSize)
        (set @imageablePageRect (NSInsetRect (self bounds) 15.0 15.0))
        (self prepareBezierPaths)
        ((self superview) setNeedsDisplay:YES))
     
     (- (void) awakeFromNib is
        (self updateSize))
     
     (- (void) setPackModel:(id) pm is
        (if @packModel
            ((NSNotificationCenter defaultCenter) removeObserver:self
             name:"PackModelChangedNotification"
             object:packModel))
        (set @packModel pm)
        ((NSNotificationCenter defaultCenter) addObserver:self
         selector:"modelChanged:"
         name:"PackModelChangedNotification"
         object:@packModel)     
        (self placeButtons)
        (self setNeedsDisplay:YES))
     
     (- (id) packModel is @packModel)
     
     (- (void)changeImageableRectDisplay:(id) sender is	
        (set @showsImageableRect (sender state))
        (self setNeedsDisplay:YES))
     
     (- (void) modelChanged:(id) note is
        (self placeButtons)
        (self setNeedsDisplay:YES))
     
     (- (void) paperSizeChanged:(id) n is
        (self updateSize)
        (self placeButtons))
     
     (- (void) prepareBezierPaths is
        (set bounds (self bounds))
        (set left (NSMinX bounds))
        (set right (NSMaxX bounds))
        (set top (NSMaxY bounds))
        (set bottom (NSMinY bounds))
        (set lowerH (QuarterY bounds))
        (set midH (HalfY bounds))
        (set upperH (ThreeQuarterY bounds))
        (set midV (HalfX bounds))
        
        (set @foldLines (NSBezierPath bezierPath))
        
        (@foldLines setLineWidth:1.0)
        
        (@foldLines moveToPoint:(list left lowerH))
        (@foldLines lineToPoint:(list right lowerH))
        
        (@foldLines moveToPoint:(list left midH))
        (@foldLines lineToPoint:(list right midH))
        
        (@foldLines moveToPoint:(list left upperH))
        (@foldLines lineToPoint:(list right upperH))
        
        ;; Vertical fold lines
        (@foldLines moveToPoint:(list midV top))
        (@foldLines lineToPoint:(list midV upperH))
        
        (@foldLines moveToPoint:(list midV lowerH))
        (@foldLines lineToPoint:(list midV bottom))
        
        (set @cutLine (self cutlineFromPoint:(list midV upperH) toPoint:(list midV lowerH))))
     
     (- (void)drawImageRep:(id)rep inRect:(NSRect)rect isLeft:(BOOL)isLeft is
        (set imageSize (rep size))        
        (set isPortrait (> (imageSize second) (imageSize first)))
        
        ;; Figure out the rotation (as a multiple of 90 degrees)
        (set rotation (if isLeft (then 1) (else -1)))
        (unless isPortrait (set rotation (+ rotation 1)))
        
        ;; Figure out the scale
        (if (% rotation 2) ;; Is it rotated +/- 90 degrees?
            (then 
                  (set scaleVertical (/ (rect third) (imageSize second)))
                  (set scaleHorizontal (/ (rect fourth) (imageSize first))))
            (else 
                  (set scaleVertical (/ (rect third) (imageSize first)))
                  (set scaleHorizontal (/ (rect fourth) (imageSize second)))))
        
        ;; scale     How much the image will be scaled
        ;; widthGap  How much it will need to be nudged to center horizontally
        ;; heightGap How much it will need to be nudged to center vertically
        (if (> scaleHorizontal scaleVertical) 
            (then 
                  (set scale scaleVertical)
                  (set heightGap 0)
                  (set widthGap (* 0.5 (rect third) (/ (- scaleHorizontal scaleVertical) scaleHorizontal)))) 
            (else 
                  (set scale scaleHorizontal)
                  (set widthGap 0)
                  (set heightGap (* 0.5 (rect fourth) (/ (- scaleVertical scaleHorizontal) scaleVertical)))))
        
        (case rotation
              (-1 (set origin (list (+ (rect first) widthGap)
                                    (- (+ (rect second) (rect fourth)) heightGap))))
              (0 (set origin (list (+ (rect first) widthGap)
                                   (+ (rect second) heightGap))))
              (1 (set origin (list (- (+ (rect first) (rect third)) widthGap)
                                   (+ (rect second) heightGap))))
              (2 (set origin (list (- (+ (rect first) (rect third)) widthGap)
                                   (- (+ (rect second) (rect fourth)) heightGap))))
              (else 
                    (NSException raise:@"Rotation" format:"Rotation = #{rotation}?")))
        
        ; Create the affine transform
        (set transform ((NSAffineTransform alloc) init))
        (transform translateXBy:(origin first) yBy:(origin second))
        (transform rotateByDegrees:(* rotation 90.0))
        (transform scaleBy:scale)
        (NSGraphicsContext saveGraphicsState)
        (NSRectClip rect)
        (transform concat)
        (rep draw)
        (NSGraphicsContext restoreGraphicsState))
     
     (- (NSRect) fullRectForPage:(int) pageNum is        
        (set bounds (self bounds))
        (if (isLeftSide pageNum) 
            (then (set x (NSMinX bounds)))
            (else (set x (HalfX bounds))))        
        (case pageNum
              (0 (set y (ThreeQuarterY bounds)))
              (1 (set y (ThreeQuarterY bounds)))
              (7 (set y (HalfY bounds)))
              (2 (set y (HalfY bounds)))
              (6 (set y (QuarterY bounds)))
              (3 (set y (QuarterY bounds)))
              (else (set y (NSMinY bounds))))        
        (list x y (* 0.5 (bounds third)) (* 0.25 (bounds fourth))))
     
     (- (NSRect) imageableRectForPage:(int) pageNum is
        (NSIntersectionRect (self fullRectForPage:pageNum) @imageablePageRect))
     
     (- (void) setImageablePageRect:(NSRect) r is
        (set @imageablePageRect r)
        (self setNeedsDisplay:YES))
     
     ;;;; Dragging    
     (- (void) setDragStart:(int) i is
        (if (!= @dragStart i) 
            (if (!= @dragStart -1) 
                (set oldRect (self fullRectForPage:@dragStart))
                (self setNeedsDisplayInRect:oldRect))
            (set @dragStart i)
            (if (!= @dragStart -1) 
                (set oldRect (self fullRectForPage:@dragStart))
                (self setNeedsDisplayInRect:oldRect))))
     
     (- (void) mouseDown:(id) e is
        (set i (self pageForPointInWindow:(e locationInWindow)))
        (if (@packModel pageIsFilled:i) 
            (self setDragStart:i)))
     
     (- (void) mouseDragged:(id) e is
        (if (!= @dragStart -1) 
            (set i (self pageForPointInWindow:(e locationInWindow)))
            (if (!= i @dragStart) 
                (self setDropPage:i))))
     
     (- (void) mouseUp:(id) e is
        (if (and (!= @dragStart -1)
                 (!= @dropPage -1)
                 (!= @dragStart @dropPage))
            (if (& (e modifierFlags) NSAlternateKeyMask) 
                (then (@packModel copyImageRepAt:@dragStart toRepAt:@dropPage))
                (else (@packModel swapImageRepAt:@dragStart withRepAt:@dropPage))))
        (self setDragStart:-1)
        (self setDropPage:-1))
     
     ;;;; Drag and Drop Destination
     
     (- (void) setDropPage:(int) i is
        (if (!= i @dropPage) 
            (if (!= @dropPage -1) 
                (self setNeedsDisplayInRect: (self fullRectForPage:@dropPage)))
            (set @dropPage i)
            (if (!= @dropPage -1)
                (self setNeedsDisplayInRect:(self fullRectForPage:@dropPage)))))
     
     (- (int) pageForPoint:(NSPoint) p is
        (set bounds (self bounds))
        (unless (NSPointInRect p  bounds) 
                (then -1)
                (else (set page -1)
                      (BLOCK_COUNT times:
                           (do (i)
                               (if (NSPointInRect p (self fullRectForPage:i))
                                   (set page i))))
                      page)))
     
     (- (int) pageForPointInWindow:(NSPoint) p is
        (set x (self convertPoint:p fromView:nil))
        (self pageForPoint:x))
     
     (- (int) draggingEntered:(id) sender is
        (set p (sender draggingLocation))
        (self setDropPage:(self pageForPointInWindow:p))
        NSDragOperationCopy)		
     
     (- (int) draggingUpdated:(id) sender is
        (self setDropPage:(self pageForPointInWindow:(sender draggingLocation)))
        NSDragOperationCopy)
     
     (- (void) draggingExited:(id) sender is (self setDropPage:-1))
     
     (- (BOOL) prepareForDragOperation:(id) sender is YES)
     
     (- (BOOL) performDragOperation:(id) sender is
        (set pasteboard (sender draggingPasteboard))
        (set favoriteTypes (array NSPDFPboardType NSFilenamesPboardType))
        (set matchingType (pasteboard availableTypeFromArray:favoriteTypes))
        (if matchingType
            (else NO)
            (then (set undo (@packModel undoManager))        
                  (set groupingLevel (undo groupingLevel))
                  ;; This is an odd little hack.  Seems undo groups are not properly closed after drag 
                  ;; from the finder.
                  (if (> groupingLevel 0) 
                      (undo endUndoGrouping)
                      (undo beginUndoGrouping))
                  (if (matchingType isEqual:NSPDFPboardType) 
                      (@packModel putPDFData:(pasteboard dataForType:NSPDFPboardType) startingOnPage:@dropPage))
                  (if (matchingType isEqual:NSFilenamesPboardType) 
                      (@packModel putFiles:(pasteboard propertyListForType:NSFilenamesPboardType) startingOnPage:@dropPage))
                  YES)))
     
     (- (void) concludeDragOperation:(id)sender is
        (self setDropPage:-1))
     
     ;;;; Pagination
     
     (- (NSRect) rectForPage:(int) i is (self bounds))
     
     ;;;; For Debugging Purposes
     
     (- (id) description is "<PackerView: #{(@packModel description)}>")
     
     (- acceptsFirstMouse:theEvent is YES)
     
     (- (void) placeButtons is
        ;; copy the array before enumerating to be safe
        ((NSArray arrayWithArray:(self subviews)) each:
         (do (subview)
             (subview removeFromSuperviewWithoutNeedingDisplay)))
        (BLOCK_COUNT times:	
             (do (i)
                 (if (@packModel pageIsFilled:i)                      
                     (set fullRect (self fullRectForPage:i))
                     (set buttonRect (list (- (NSMaxX fullRect) (+ 30 buttonMargin))
                                           (+ (NSMinY fullRect) buttonMargin)
                                           30 25))
                     (set button ((NSButton alloc) initWithFrame:buttonRect))
                     (button setCell:((RoundCloseButtonCell alloc) init))
                     (button setTag:i)
                     (button setTarget:self)
                     (button setAction:"clearPage:")
                     (self addSubview:button)))))
     
     (- (void)clearPage:(id)sender is
        (@packModel removeImageRepAtPage:(sender tag)))
     
     (- (void) drawNumber:(int) x centeredInRect:(NSRect) r is
        (set str (x stringValue))
        (set attString ((NSAttributedString alloc) initWithString:str attributes:numberAttributes))
        (set drawingRect (list (+ (r first) (* 0.5 (- (r third) ((attString size) first))))
                               (+ (r second) (* 0.5 (- (r fourth) ((attString size) second))))
                               ((attString size) first)
                               ((attString size) second)))                                     
        (attString drawInRect:drawingRect))
     
     (- (void)drawRect:(NSRect)rect is
        (set isScreen (NSGraphicsContext currentContextDrawingToScreen))
        
        ; Draw a nice white background on the screen
        (if (isScreen) 
            ((NSColor whiteColor) set) 
            (NSBezierPath fillRect:rect))
        (BLOCK_COUNT times:
             (do (i)
                 (set imageDest (self imageableRectForPage:i))
                 ; Does this need redrawing?
                 (if (NSIntersectsRect imageDest rect)
                     ; Get the image (will setCurrentPage: if necessary)
                     (set imageRep (@packModel preparedImageRepForPage:i))   
                     (if imageRep ; Draw image
                         (self drawImageRep:imageRep
                               inRect:imageDest
                               isLeft:(isLeftSide i)))
                     ; Number the rectangles
                     (if isScreen             
                         (if (eq i @dragStart)
                             (set highlightRect (NSInsetRect imageDest 20 20))
                             (set c (NSColor colorWithCalibratedRed:1
                                             green:1
                                             blue:0.5
                                             alpha:0.5))
                             (c set)
                             (NSBezierPath fillRect:highlightRect))                  
                         (self drawNumber:(+ i 1) centeredInRect:imageDest)))))
        
        ; Draw folding lines
        ((NSColor lightGrayColor) set)
        (@foldLines stroke)
        
        ; Draw the cutting line
        ((NSColor blackColor) set)
        (@cutLine stroke)
        
        ; If drawing to screen, draw imageable Rect
        (if (isScreen)  
            (if @showsImageableRect 
                ((NSColor blueColor) set)
                (NSBezierPath setDefaultLineWidth:1.0)
                (NSBezierPath strokeRect:@imageablePageRect))            
            (if (>= @dropPage 0) 
                ((NSColor colorWithDeviceRed:0.8 green:0.5 blue:0.5 alpha:0.3) set)
                (NSBezierPath fillRect:(self fullRectForPage:@dropPage))))))

;; @class TextDisplayView
;; @discussion This helper class is used to generate PDF representations of strings.
(class TextDisplayView is NSView
     (ivar (id) attString (NSSize) pageSize)
     
     (- (id)initWithPageSize:(NSSize)size attributedString:(id)aString is
        (set frame (list 0 0 (size first) (size second)))
        (self initWithFrame:frame)
        (set @pageSize size)
        (set @attString aString)
        self)
     
     (- (BOOL)isFlipped is YES)
     
     (- (void)drawRect:(NSRect)rect is
        (set bounds (NSInsetRect (self bounds) 3 3))
        (@attString drawInRect:bounds)))

;; use the above class to generate a PDF for an attributed string.
(function pdfFromAttributedStringOfSize (attributedString size)
     (set view ((TextDisplayView alloc) initWithPageSize:size attributedString:attributedString))
     (view dataWithPDFInsideRect:(view bounds)))

;; some internal constants
(global PaperSizeChangedNotification "PaperSizeChangedNotification")
(global PaperSizeKey "PaperSize")
(global FontFamilyKey "FontFamily")
(global FontSizeKey "FontSize")

;; @class PreferenceController
;; @discussion This class controls the application's preference window.
(class PreferenceController is NSWindowController
     (ivar (id) paperPopUp (id) textFontField (id) textFont)
     
     (set sharedPreferenceController nil)
     
     (- (id)init is
        (super initWithWindowNibName:"PreferenceController")
        (set sharedPreferenceController self)
        (set defaults (NSUserDefaults standardUserDefaults))
        (set fontFamily (defaults stringForKey:FontFamilyKey))
        (set fontSize (defaults floatForKey:FontSizeKey))
        (set @textFont (NSFont fontWithName:fontFamily size:fontSize))
        self)
     
     (+ (void)initialize is
        ((NSUserDefaults standardUserDefaults) registerDefaults:(dict PaperSizeKey 0
                                                                      FontFamilyKey "Helvetica"
                                                                      FontSizeKey 8.0)))
     
     (+ (id)sharedPreferenceController is       
        (unless sharedPreferenceController ((PreferenceController alloc) init))	   
        sharedPreferenceController)
     
     (- (int)paperSizeID is
        ((NSUserDefaults standardUserDefaults) integerForKey:PaperSizeKey))
     
     (- (void)setPaperSizeID:(int)i is
        ((NSUserDefaults standardUserDefaults) setInteger:i forKey:PaperSizeKey)
        ((NSNotificationCenter defaultCenter) 
         postNotificationName:PaperSizeChangedNotification
         object:self
         userInfo:(dict PaperSizeKey (NSValue valueWithSize:(self paperSize)))))
     
     (- (NSSize)paperSize is
        (case (self paperSizeID)
              (0 '(612 792))				;; LETTER
              (else '(595 842)))) 			;; assume it's A4
     
     (- (void)windowDidLoad is
        (@paperPopUp selectItemWithTag:(self paperSizeID))
        (@textFontField setStringValue:(self fontDescription)))
     
     (- (void)paperChosen:(id)sender is
        (self setPaperSizeID:(@paperPopUp selectedTag)))
     
     (- (id) textFont is @textFont)
     
     (- (void) setTextFont:(id) f is
        (set @textFont f)
        (set userDefaults (NSUserDefaults standardUserDefaults))
        (userDefaults setObject:(f familyName) forKey:FontFamilyKey)
        (userDefaults setFloat:(f pointSize) forKey:FontSizeKey)
        (@textFontField setStringValue:(self fontDescription)))	
     
     (- (id) fontDescription is
        "#{((self textFont) displayName)} - #{((self textFont) pointSize)}")
     
     (- (void)changeFont:(id)sender is
        (self setTextFont:(sender convertFont:@textFont)))
     
     (- (void)chooseFont:(id)sender is
        ((NSFontManager sharedFontManager) setSelectedFont:@textFont isMultiple:NO)
        ((NSFontPanel sharedFontPanel) makeKeyAndOrderFront:nil)))