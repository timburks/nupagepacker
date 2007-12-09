;; @file main.nu
;; @discussion Entry point for a Nu program.
;;
;; @copyright Copyright (c) 2007 Tim Burks, Neon Design Technology, Inc.

(load "nu")      	;; essentials
(load "cocoa")		;; wrapped frameworks
(load "console")	;; interactive console
(load "packer")		;; application code

;; unfortunately, these initialize methods aren't called automatically, so we call them here.
(PackerView initialize) 
(PreferenceController initialize)
(DraggingSourcePDFView initialize)

(set SHOW_CONSOLE_AT_STARTUP nil)

(class AppController is NSObject
     (imethod (void) applicationDidFinishLaunching: (id) sender is
          (set $console ((NuConsoleWindowController alloc) init))
          (if SHOW_CONSOLE_AT_STARTUP ($console toggleConsole:self))
          ((CatalogController sharedCatalogController) showWindow:nil)))

(load "scripting")  ;; scripting support, must be loaded after AppControler is defined

(set NSApp (NSApplication sharedApplication))

;; this makes the application window take focus when we've started it from the terminal
(NSApp activateIgnoringOtherApps:YES)

;; run the main Cocoa event loop
(NSApplicationMain 0 nil)
