;; @file scripting.nu
;; @discussion PagePacker scripting support in Nu.
;;
;; @copyright Copyright (c) 2007 Tim Burks, Neon Design Technology, Inc.

(class NSObject
     
     (- (void) returnError:(int)n string:(id)s is        
        (set c (NSScriptCommand currentCommand))
        (c setScriptErrorNumber:n)
        (if s (c setScriptErrorString:s))))

(class CatalogController 
     
     (- (id) pdfView is @pdfView))

(class AppController
     
     (- (BOOL)application:(id)sender delegateHandlesKey:(id)key is        
        (if (eq key "pageSizePref") (then YES) (else NO)))
     
     (set sizeEnumeration (array 'psLt' 'psA4'))
     
     (- (int)pageSizePref is
        (set sz ((PreferenceController sharedPreferenceController) paperSizeID))
        (sizeEnumeration objectAtIndex:sz))
     
     (- (void)setPageSizePref:(int)sz is
        (sizeEnumeration eachWithIndex:
             (do (size i)
                 (if (eq size sz)
                     ((PreferenceController sharedPreferenceController) setPaperSizeID:i))))))

(class MyDocument
     
     (- (id) packModel is @packModel)
     
     (- (int) countOfPagesArray is 8)
     
     (- (id)objectInPagesArrayAtIndex:(int)i is
        (if (> i 7) 
            (then 
                  (self returnError:errOSACantAccess string:"No such document page.")
                  nil)
            (else 
                  (set p ((MNDocPage alloc) init))
                  (p setIndex:i)
                  (p setDocument: self)
                  p)))
     
     (- (void) insertInPagesArray: (id) obj is
        (self returnError:errOSACantAssign string:"Can't create additional document pages."))
     
     (- (void) removeObjectFromPagesArrayAtIndex:(int)ix is
        (self returnError:errOSACantAssign string:"Can't delete document pages.")))

(class MNDocPage is NSObject
     (ivar (int) index (id) document)
     
     (- (void)handleClearScriptCommand:(id)sender is
        ((document packModel) removeImageRepAtPage:index))
     
     (- (id)objectSpecifier is
        (set spec ((NSIndexSpecifier alloc) initWithContainerClassDescription:(@document classDescription)
                   containerSpecifier:(@document objectSpecifier)
                   key:"PagesArray"
                   index:@index))
        spec)
     
     (- (void) setCatalogSourcePage:(int)p is
        (set pp (- p 1))
        (set doc (((CatalogController sharedCatalogController) pdfView) document))
        (if (>= pp (doc pageCount))
            (then 
                  (self returnError:errOSACantAccess string:"No such catalog page."))
            (else
                 (set page (doc pageAtIndex:pp))
                 (set d (page dataRepresentation))
                 ((@document packModel) putPDFData:d startingOnPage:@index))))
     
     (- (int) catalogSourcePage is
        (self returnError:errOSACantAccess string:"This property is write-only.")
        0)
     
     (- (void) setFileSource:(id)url is
        (set arr (array (url path)))
        ((@document packModel) putFiles:arr startingOnPage:@index))
     
     (- (id) fileSource is
        (self returnError:errOSACantAccess string:"This property is write-only.")
        nil))