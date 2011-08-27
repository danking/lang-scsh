#lang scheme
(provide (all-defined-out))
(require "exec.rkt")

(define-syntax exec-epf
  (syntax-rules ()
    ((_ pf redir ...)
     (list (process-form pf)
           (redirects redir ...)))))

(define-syntax process-form
  (syntax-rules ()
    ((_ begin scheme-code ...)
     (& scheme-code ...))
    ((_ pipe pfs ...)
     (pipe-combine (process-form pfs) ...))
    ((_ pipe+ connect-list pfs ...)
     (pipe-combine+ connect-list (process-form pfs) ...))
    ((_ epf pf redirs ...)
     (exec-epf pf redirs ...))
    ((_ prog args ...)
     (process-form begin (apply exec-path `(prog args ...))))))

(define-syntax &
  (syntax-rules ()
    ((& . epf)
     (fork (lambda () (exec-epf . epf))))))

(define-syntax run
  (syntax-rules ()
    ((run . epf)
     (wait (& . epf)))))
