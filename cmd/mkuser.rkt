#lang racket/base

(require
 (prefix-in m:auth: "../model/auth.rkt"))


(define (usage)
  (display "
mkuser <user-name> <password>
")
  (exit 1))

(define user-conn (m:auth:connect!))
(m:auth:make-user-table! user-conn)
(define args (current-command-line-arguments))
(display args)
(when (not (=  (vector-length args) 2))
    (usage))
(define user (vector-ref args 0))
(define password (vector-ref args 1))

(m:auth:add-user! user-conn user password)

(m:auth:disconnect! user-conn)
