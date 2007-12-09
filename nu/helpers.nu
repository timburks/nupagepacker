;; @file helpers.nu
;; @discussion Here we define some helper functions for working with points and rectangles.
;; C versions would be faster, but in practice, these seem fast enough.
;;
;; @copyright Copyright (c) 2007 Tim Burks, Neon Design Technology, Inc.
;; Substantially derived from original Objective-C source code by Aaron Hillegass.
;; See objc/PagePacker.m for the copyright notice for the original code.

(function PointInRect (point rect)
     (and (>= (point first) (rect first))
          (>= (point second) (rect second))
          (<= (point first) (+ (rect first) (rect third)))
          (<= (point second) (+ (rect second) (rect fourth)))))

(function distanceSquaredBetweenPoints (p1 p2)
     (set deltax (- (p1 first) (p2 first)))
     (set deltay (- (p1 second) (p2 second)))
     (+ (* deltax deltax) (* deltay deltay)))

(function insetRect (rect x y)
     (list (+ (rect first) x) 
           (+ (rect second) y)
           (- (rect third) x x) 
           (- (rect fourth) y y)))

(function NSMinX (rect) 
     (set x1 (rect first))
     (set x2 (+ (rect first) (rect third)))
     (if (< x1 x2) (then x1) (else x2)))

(function NSMaxX (rect) 
     (set x1 (rect first))
     (set x2 (+ (rect first) (rect third)))
     (if (> x1 x2) (then x1) (else x2)))

(function NSMinY (rect) 
     (set y1 (rect second))
     (set y2 (+ (rect second) (rect fourth)))
     (if (< y1 y2) (then y1) (else y2)))

(function NSMaxY (rect) 
     (set y1 (rect second))
     (set y2 (+ (rect second) (rect fourth)))
     (if (> y1 y2) (then y1) (else y2)))

;; find relative positions within a rectangle
(function HalfX (r) (+ (r first) (* 0.5 (r third))))
(function QuarterY (r) (+ (r second) (* 0.25 (r fourth))))
(function HalfY (r) (+ (r second) (* 0.5 (r fourth))))
(function ThreeQuarterY (r) (+ (r second) (* 0.75 (r fourth))))
