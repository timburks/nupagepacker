;; @file main.nu
;; @discussion Entry point for a Nu program.
;;
;; @copyright Copyright (c) 2007 Tim Burks, Neon Design Technology, Inc.

(load "nu")      	;; essentials
(load "cocoa")		;; wrapped frameworks
(load "console")	;; interactive console
(load "packer")		;; application code

(set SHOW_CONSOLE_AT_STARTUP nil)

(class AppController is NSObject
     (imethod (void) applicationDidFinishLaunching: (id) sender is
          (set $console ((NuConsoleWindowController alloc) init))
          (if SHOW_CONSOLE_AT_STARTUP ($console toggleConsole:self))
          ((CatalogController sharedCatalogController) showWindow:nil)))

;; this makes the application window take focus when we've started it from the terminal
((NSApplication sharedApplication) activateIgnoringOtherApps:YES)

;; run the main Cocoa event loop
(NSApplicationMain 0 nil)
