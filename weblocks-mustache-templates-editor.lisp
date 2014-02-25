;;;; weblocks-mustache-templates-editor.lisp

(in-package #:weblocks-mustache-templates-editor)

;;; "weblocks-mustache-templates-editor" goes here. Hacks and glory await!
(weblocks-cms:def-additional-schema 
  :template
  '((:TITLE "Шаблон" :NAME :TEMPLATE :FIELDS
     ((:TITLE "Значения переменных" :NAME :VARIABLES-DESCRIPTIONS :TYPE
       :EDITOR-TEXTAREA :OPTIONS NIL)
      (:TITLE "Время последнего использования" :NAME :LAST-USED-TIME :TYPE
       :DATETIME :OPTIONS NIL)
      (:TITLE "Текст шаблона" :NAME :TEXT :TYPE :EDITOR-TEXTAREA :OPTIONS NIL)
      (:TITLE "Основная модель шаблона" :NAME :MODEL :TYPE :SINGLE-CHOICE :OPTIONS
       NIL)
      (:TITLE "Имя (для программиста)" :NAME :NAME :TYPE :STRING :OPTIONS NIL)
      (:TITLE "Название" :NAME :TITLE :TYPE :STRING :OPTIONS NIL)))))
