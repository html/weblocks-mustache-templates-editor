;;;; weblocks-mustache-templates-editor.asd

(asdf:defsystem #:weblocks-mustache-templates-editor
  :serial t
  :description "A piece of Weblocks ui for editing mustache templates"
  :author "Olexiy Zamkoviy <olexiy.z@gmail.com>"
  :version "0.2.4"
  :license "LLGPL"
  :depends-on (#:weblocks
               #:weblocks-cms 
               #:weblocks-cms-import-export-data 
               #:weblocks-utils)
  :components ((:file "package")
               (:file "weblocks-mustache-templates-editor")
               (:file "import-export-templates")
               (:file "preview-template")))

