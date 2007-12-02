;; Nukefile for PagePacker

;; source files
(set @c_files     (filelist "^objc/.*.c$"))
(set @m_files     (filelist "^objc/.*.m$"))
(set @nu_files 	  (filelist "^nu/.*nu$"))
(set @frameworks  '("Cocoa" "Nu" "Quartz"))
(set @icon_files  (filelist "^resources/.*icns$"))
(set @resources   (filelist "^resources/English\.lproj/[^/]*$"))
(@resources << "resources/diyp3h_core_1up.pdf")
(@resources << "resources/PagePacker.sdef")

(set @info
     (dict "CFBundleDevelopmentRegion" "English"
           "CFBundleDocumentTypes"  
           (array (dict "CFBundleTypeExtensions" (array "pp")
                        "CFBundleTypeIconFile" "PPApp.icns"
                        "CFBundleTypeName" "DocumentType"
                        "CFBundleTypeRole" "Editor"
                        "NSDocumentClass" "MyDocument"))
           "CFBundleExecutable" "NuPagePacker"
           "CFBundleHelpBookFolder" "PagePackerHelp"
           "CFBundleHelpBookName" "PagePacker Help"
           "CFBundleIconFile" "PPApp"
           "CFBundleIdentifier" "nu.programming.NuPagePacker"
           "CFBundleInfoDictionaryVersion" "6.0"
           "CFBundleName" "NuPagePacker"
           "CFBundlePackageType" "APPL"
           "CFBundleSignature" "????"
           "CFBundleVersion" "1.2"
           "NSAppleScriptEnabled" "YES"
           "NSMainNibFile" "MainMenu"
           "NSPrincipalClass" "NSApplication"
           "OSAScriptingDefinition" "PagePacker.sdef"))

;; application description
(set @application "NuPagePacker")
(set @application_identifier   "nu.programming.nupagepacker")
(set @application_icon_file "PPApp.icns")
(set @application_help_folder "PagePackerHelp")

;; build configuration
(set @cc "gcc")
(set @cflags "-g -O3 -DMACOSX ")
(set @mflags "-fobjc-exceptions")

(compilation-tasks)
(application-tasks)

(task "default" => "application")

