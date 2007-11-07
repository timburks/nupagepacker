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
           "CFBundleExecutable" "PagePacker"
           "CFBundleHelpBookFolder" "PagePackerHelp"
           "CFBundleHelpBookName" "PagePacker Help"
           "CFBundleIconFile" "PPApp"
           "CFBundleIdentifier" "nu.programming.PagePacker"
           "CFBundleInfoDictionaryVersion" "6.0"
           "CFBundleName" "PagePacker"
           "CFBundlePackageType" "APPL"
           "CFBundleSignature" "????"
           "CFBundleVersion" "1.2"
           "NSAppleScriptEnabled" "YES"
           "NSMainNibFile" "MainMenu"
           "NSPrincipalClass" "NSApplication"
           "OSAScriptingDefinition" "PagePacker.sdef"))

;; application description
(set @application "PagePacker")
(set @application_identifier   "nu.programming.pagepacker")
(set @application_icon_file "PPApp.icns")
(set @application_help_folder "PagePackerHelp")

;; build configuration
(set @cc "gcc")
(set @cflags "-g -O3 -DMACOSX ")
(set @mflags "-fobjc-exceptions")

(set notldflags
     ((list
           ((@frameworks map: (do (framework) " -framework #{framework}")) join)
           ((@libs map: (do (lib) " -l#{lib}")) join)
           ((@lib_dirs map: (do (libdir) " -L#{libdir}")) join))
      join))

(compilation-tasks)
(application-tasks)

(task "default" => "application")

