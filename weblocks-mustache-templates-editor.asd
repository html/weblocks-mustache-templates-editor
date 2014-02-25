;;;; weblocks-mustache-templates-editor.asd

(asdf:defsystem #:weblocks-mustache-templates-editor
  :serial t
  :description "A piece of Weblocks ui for editing mustache templates"
  :author "Olexiy Zamkoviy <olexiy.z@gmail.com>"
  :version "0.1.0"
  :license "LLGPL"
  :depends-on (#:weblocks
               #:weblocks-cms)
  :components ((:file "package")
               (:file "weblocks-mustache-templates-editor")
               (:file "import-export-templates")))
