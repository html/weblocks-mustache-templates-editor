(in-package :weblocks-mustache-templates-editor)

(defun get-templates-directory ()
  (merge-pathnames 
    (make-pathname :directory '(:relative "mustache-templates"))
    *default-pathname-defaults*))

(defmethod export-template ((obj weblocks-cms::template))
  (let ((file-name (merge-pathnames 
                     (make-pathname :name (weblocks-cms::template-name obj) :type "mu") 
                     (get-templates-directory))))
    (ensure-directories-exist file-name)
    (with-open-file (out file-name :direction :output :if-does-not-exist :create :if-exists :supersede)
      (format out "{{! ~A }}~%" (prin1-to-string (list :title (weblocks-cms::template-title obj))))
      (when (stringp (weblocks-cms::template-text obj))
        (write-string (remove #\Return (weblocks-cms::template-text obj)) out)))))

(defun export-templates ()
  (mapcar #'export-template (all-of 'weblocks-cms::template)))

(defun import-template (file)
  (with-open-file (in file :direction :input)
    (let* ((first-line (read-line in))
           (extracted-meta (read-from-string (subseq first-line 3 (- (length first-line) 2))))
           (title)
           (text))

      (setf text 
            (with-output-to-string (s)
              (if (consp extracted-meta)
                (setf title (getf extracted-meta :title))
                (progn 
                  (write-string first-line s)
                  (write-char #\Newline s)))

              (loop for line = (read-line in nil) while line do 
                    (write-string line s)
                    (write-char #\Newline s)
                    )))

      (persist-object weblocks-stores:*default-store* 
                      (make-instance 'weblocks-cms::template 
                                     :name (pathname-name file)
                                     :title title 
                                     :text text)))))

(defun import-templates ()
  (weblocks-utils:delete-all 'weblocks-cms::template)
  (mapcar #'import-template (cl-fad:list-directory (get-templates-directory))))

(defmethod weblocks-cms::make-widget-for-model-description ((name (eql :template)) description)
  (let ((widget (call-next-method))
        (fields (list 'weblocks-cms::title 'weblocks-cms::name))
        )
    (setf (weblocks::table-view-field-sorter (dataseq-view widget))
          (lambda (field-1 field-2)

            (let ((pos-1 (or 
                           (position (weblocks::view-field-slot-name (weblocks::field-info-field field-1)) fields)
                           (1+ (length fields))))
                  (pos-2 (or 
                           (position (weblocks::view-field-slot-name (weblocks::field-info-field field-2)) fields)
                           (1+ (length fields)))))
              (cond 
                ((subtypep (type-of (weblocks::field-info-field field-1)) 'weblocks::datagrid-select-field) t)
                ((subtypep (type-of (weblocks::field-info-field field-2)) 'weblocks::datagrid-select-field) nil)
                (t (< pos-1 pos-2))))))
    widget))

(defmethod dataedit-update-operations ((obj gridedit) &key (delete-fn #'dataedit-delete-items-flow) (add-fn #'dataedit-add-items-flow))
  (when (equal 'weblocks-cms::template (dataseq-data-class obj))

    (setf (dataseq-common-ops obj)
          (remove 'export (dataseq-common-ops obj)
                  :key #'car :test #'string-equal))

    (setf (dataseq-common-ops obj)
          (remove 'import (dataseq-common-ops obj)
                  :key #'car :test #'string-equal))

    (pushnew (cons 'export 
                   (lambda (&rest args)
                     (export-templates)
                     (do-information (format nil "Templates exported to <b>~A</b>" (get-templates-directory)))))
             (dataseq-common-ops obj) :key #'car)
    (pushnew (cons 'import 
                   (lambda (&rest args)
                     (import-templates)
                     (do-information (format nil "Templates imported from <b>~A</b>" (get-templates-directory)))))
             (dataseq-common-ops obj) :key #'car))

  (call-next-method))
