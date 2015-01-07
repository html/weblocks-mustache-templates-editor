(in-package :weblocks-mustache-templates-editor)

(defun keyword-slot-value (object keyword)
  (loop for i in (c2mop:class-slots (class-of object))
        do 
        (when (equal 
                keyword 
                (alexandria:make-keyword (c2mop:slot-definition-name i)))
          (return-from keyword-slot-value (when (slot-boundp object (c2mop:slot-definition-name i))
                                            (slot-value object (c2mop:slot-definition-name i)))))))

(defmethod template-variables ((obj weblocks-cms::template))
  (loop for i in (ppcre:all-matches-as-strings 
                   "{{([^}]+)}}" 
                   (weblocks-cms::template-variables-descriptions obj))
        collect (string-trim "{}" i)))

(defmethod template-variables-descriptions ((obj weblocks-cms::template))
  (let ((result))
    (ppcre:do-register-groups 
      (key value)
      ("{{([^}]+)}}\\s+-\\s+(.*)<" 
       (weblocks-cms::template-variables-descriptions obj))
      (setf result (list* (cons key value) result)))
    result))

(defmethod template-variables-description ((obj weblocks-cms::template) key)
  (let ((descriptions (template-variables-descriptions obj)))
    (cdr (assoc key descriptions :test #'string=))))

(defun make-view-fields-descriptions (fields)
  (loop for j in fields 
        append (weblocks-cms::get-view-fields-for-field-description j nil)))

(defun make-simple-form-view (&key buttons caption persistp fields)
  (eval 
    `(defview nil (:type form 
                   :buttons ',(loop for i in buttons 
                                    collect (if (consp i)
                                              (cons (cdr i) (car i))
                                              i)) 
                   :persistp ,persistp
                   :caption ,(or caption ""))
              ,@fields)))

(defmethod weblocks-cms:get-model-form-view-fields :around ((model (eql :template)))
  (weblocks-utils:require-assets "https://raw.github.com/html/weblocks-assets/master/jquery-sisyphus/1.1.103/")
  (list* 
    (list 
      'preview-template
      :label ""
      :present-as 'html
      :reader (lambda (template)
                (let ((template-variable-names (template-variables template)))
                  (weblocks::capture-weblocks-output 
                    (render-link 
                      (lambda (&rest args)
                        (do-dialog 
                          "Preview template"
                          (make-quickform 
                            (make-simple-form-view 
                              :persistp nil
                              :buttons '(("Refresh" . :submit) 
                                         ("Close" . :cancel))
                              :fields (append 
                                        (make-view-fields-descriptions 
                                          (loop for i in template-variable-names
                                                collect (list 
                                                          :options nil
                                                          :name (alexandria:make-keyword (string-upcase i))
                                                          :type :string 
                                                          :title (format nil "{{<b style=\"white-space:nowrap\">~A</b>}}" i))))
                                        (list 
                                          (list 'preview 
                                                :present-as 'html
                                                :reader (lambda (variables-object)
                                                          (yaclml->string 
                                                            (<iframe 
                                                              :style "width:100%;"
                                                              :id "preview-iframe" )
                                                            (<script :type "text/javascript"
                                                                     (<:as-is 
                                                                       (ps:ps 

                                                                         (defun change-preview-modal-width ()
                                                                           (ps:chain (j-query ".modal")
                                                                                     (css 
                                                                                       (ps:create 
                                                                                         "margin-left" "-45%"
                                                                                         :width "90%"))))

                                                                         (defun init-preview-modal-sisyphus ()
                                                                           (weblocks-utils:ps-with-scripts 
                                                                             ("/pub/scripts/jquery-sisyphus/sisyphus.js")
                                                                             (ps:chain 
                                                                               (j-query ".modal-body form input")
                                                                               (each 
                                                                                 (lambda ()
                                                                                   (ps:chain (j-query this)
                                                                                             (attr "id" 
                                                                                                   (concatenate 'string 
                                                                                                                (ps:LISP (weblocks-cms::template-name template))
                                                                                                                (ps:@ this name)))))))
                                                                             (ps:chain 
                                                                               (j-query ".modal-body form")
                                                                               (sisyphus (ps:create "autoRelease" nil)))))

                                                                         (defun put-preview-html-into-iframe()
                                                                           (ps:chain 
                                                                             document 
                                                                             (get-element-by-id "preview-iframe")
                                                                             content-document 
                                                                             (write 
                                                                               (ps:LISP 
                                                                                 (if (find-package :weblocks-cms-pages)
                                                                                   (apply 
                                                                                     (intern "RENDER-USER-TEMPLATE" "WEBLOCKS-CMS-PAGES")
                                                                                     (list* 
                                                                                       (alexandria:make-keyword 
                                                                                         (string-upcase (weblocks-cms::template-name template)))
                                                                                       (loop for i in template-variable-names 
                                                                                             append (list 
                                                                                                      (alexandria:make-keyword (string-upcase i))
                                                                                                      (cons (keyword-slot-value variables-object 
                                                                                                                                (alexandria:make-keyword (string-upcase i)))
                                                                                                            (template-variables-description template i))))))
                                                                                   ":weblocks-cms-pages package is required for functionality")))))

                                                                         (j-query 
                                                                           (lambda ()

                                                                             (ps:chain 
                                                                               (j-query "#preview-iframe")
                                                                               (on-available 
                                                                                 (lambda ()
                                                                                   (change-preview-modal-width)

                                                                                   (init-preview-modal-sisyphus)

                                                                                   (put-preview-html-into-iframe)
                                                                                   ))))))))))))))
                            :on-cancel (lambda (form)
                                         (answer form nil))
                            :answerp nil
                            )))
                      (weblocks-util:translate "Preview template"))))))
    (call-next-method)))
