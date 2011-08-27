#lang racket
(require ffi/unsafe)
(provide exec exec-path)

(define execv! (get-ffi-obj "execv"
                            #f
                            (_fun _path (_list i _string) -> _int)))

;; String ... ->
;; this fucntion does not return
(define (exec prog . args)
  (execv! prog (cons prog args)))

;; String ... ->
;; this function only returns if the path is not found in the path-list
(define (exec-path fname . args)
  (if (regexp-match? #rx"/" fname)
      (execv! fname (cons fname args))
      (let ((path? (path-search fname (exec-path-list))))
        (and path?
             (execv! path? (cons path? args))))))

(define (path-search fname path-list)
  (let* ((maybe-path (findf (lambda (path)
                              (member fname (map path->string
                                                 (directory-list path))))
                            path-list)))
    (and maybe-path
         (build-path maybe-path fname))))

(define exec-path-list (make-parameter '()))
