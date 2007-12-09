;; @file main.nu
;; @discussion Entry point for a Nu program.
;;
;; @copyright Copyright (c) 2007 Tim Burks, Neon Design Technology, Inc.

(load "Nu:nu")      ;; essentials
(load "Nu:cocoa")	;; wrapped frameworks
(load "Nu:console")	;; interactive console
(load "bridged")    ;; more bridged declarations
(load "helpers")	;; some helper functions
(load "packer")		;; the main application code

;; Initialize methods for Nu classes aren't (yet) called automatically, so we call them here.
(PackerView initialize) 
(PreferenceController initialize)
(DraggingSourcePDFView initialize)

;; The console is too much fun to omit.
(set SHOW_CONSOLE_AT_STARTUP nil)

;; The main application controller.
(class AppController is NSObject
     (imethod (void) applicationDidFinishLaunching: (id) sender is
          (set $console ((NuConsoleWindowController alloc) init))
          (if SHOW_CONSOLE_AT_STARTUP ($console toggleConsole:self))
          ((CatalogController sharedCatalogController) showWindow:nil)))

(load "scripting")   ;; scripting support must be loaded after AppControler is defined

(set NSApp (NSApplication sharedApplication))

;; this makes the application window take focus when we've started it from the terminal (like when we type "nuke run")
(NSApp activateIgnoringOtherApps:YES)

;; run the main Cocoa event loop
(NSApplicationMain 0 nil)
