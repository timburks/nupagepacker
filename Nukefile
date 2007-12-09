;; Nukefile for NuPagePacker

;; source files
(set @c_files     (filelist "^objc/.*.c$"))
(set @m_files     (filelist "^objc/.*.m$"))
(set @nu_files 	  (filelist "^nu/.*nu$"))
(set @frameworks  '("Cocoa" "Nu" "Quartz"))
(set @icon_files  (filelist "^resources/.*icns$"))
(set @resources   (filelist "^resources/English\.lproj/[^/]*$"))
(@resources << "resources/diyp3h_core_1up.pdf")
(@resources << "resources/PagePacker.sdef")

;; application description
(set @application "NuPagePacker")
(set @application_identifier   "nu.programming.NuPagePacker")
(set @application_icon_file "NuPPApp.icns")
(set @application_help_folder "PagePackerHelp")

;; specify the entire Info.plist here:
(set @info
     (dict "CFBundleDevelopmentRegion" "English"
           "CFBundleDocumentTypes"  
           (array (dict "CFBundleTypeExtensions" (array "pp")
                        "CFBundleTypeIconFile" "NuPPApp.icns"
                        "CFBundleTypeName" "DocumentType"
                        "CFBundleTypeRole" "Editor"
                        "NSDocumentClass" "MyDocument"))
           "CFBundleExecutable" "NuPagePacker"
           "CFBundleHelpBookFolder" "PagePackerHelp"
           "CFBundleHelpBookName" "PagePacker Help"
           "CFBundleIconFile" "NuPPApp"
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

;; build tasks
(compilation-tasks)
(application-tasks)
(task "default" => "application")

;; this copies the Nu.framework into the application so that it can be run on systems without Nu.
(task "finalize" => "application" is
      (SH "mkdir -p '#{@application_dir}/Contents/Frameworks'")
      (SH "ditto /Library/Frameworks/Nu.framework '#{@application_dir}/Contents/Frameworks/Nu.framework'")
      (SH "install_name_tool -change 'Nu.framework/Versions/A/Nu' '@executable_path/../Frameworks/Nu.framework/Versions/A/Nu'  '#{@application_dir}/Contents/MacOS/#{@application}'"))
