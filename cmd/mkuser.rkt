#lang racket/base

(require
 (prefix-in m:persist: "../model/persist.rkt"))



(define (usage)
  (display "
mkuser <user-name> <password>
")
  (exit 1))

(define user-conn (m:persist:connect!))
(m:persist:make-user-table! user-conn)
(define args (current-command-line-arguments))
(display args)
(when (not (=  (vector-length args) 2))
    (usage))
(define user (vector-ref args 0))
(define password (vector-ref args 1))

(m:persist:add-user! user-conn user password)

(m:persist:disconnect! user-conn)

;; Don't include in test runs
(module test racket/base)
