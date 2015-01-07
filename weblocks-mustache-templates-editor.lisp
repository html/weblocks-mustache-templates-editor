;;;; weblocks-mustache-templates-editor.lisp

(in-package #:weblocks-mustache-templates-editor)

;;; "weblocks-mustache-templates-editor" goes here. Hacks and glory await!
(weblocks-cms:def-additional-schema 
  :template
  '((:TITLE "Шаблон" :NAME :TEMPLATE :FIELDS
     ((:TITLE "Значения переменных" :NAME :VARIABLES-DESCRIPTIONS :TYPE
       :CUSTOM :OPTIONS "WEBLOCKS-MUSTACHE-TEMPLATES-EDITOR::DISPLAY-VARIABLES-HTML")
      (:TITLE "Время последнего использования" :NAME :LAST-USED-TIME :TYPE
       :DATETIME :OPTIONS NIL)
      (:TITLE "Текст шаблона" :NAME :TEXT :TYPE :EDITOR-TEXTAREA :OPTIONS NIL)
      (:TITLE "Основная модель шаблона" :NAME :MODEL :TYPE :SINGLE-CHOICE :OPTIONS
       NIL)
      (:TITLE "Имя (для программиста)" :NAME :NAME :TYPE :STRING :OPTIONS NIL)
      (:TITLE "Название" :NAME :TITLE :TYPE :STRING :OPTIONS NIL)))))

(defmacro yaclml->string (&body body)
  `(yaclml:with-yaclml-output-to-string ,@body))

(defun display-variables-html (type description model-description-list)
  (case type
    (:table 
      (list 
        (list 
          (weblocks-cms::keyword->symbol (getf description :name))
          :label (getf description :title)
          :present-as 'html 
          :reader (lambda (item)
                    (yaclml->string 
                      (<:span :style "height:40px;width:300px;overflow:hidden;display:block;"
                              (<:as-is (slot-value item 'weblocks-cms::variables-descriptions))))))))
    (:form 
      (list 
        (list 
          (weblocks-cms::keyword->symbol (getf description :name))
          :label (getf description :title)
          :present-as 'html)))))

(defmethod weblocks-cms-import-export-data::serialization-link-to-data-object ((obj weblocks-cms::template))
  `(:eval 
     (weblocks-utils:first-by-values ',(type-of obj)
                                     :name ,(weblocks-cms::template-name obj))))
