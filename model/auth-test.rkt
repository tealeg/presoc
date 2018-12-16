#lang racket/base

(require rackunit
         db
         sha
         "auth.rkt"
         (prefix-in m:persist: "persist.rkt"))
(require rackunit/text-ui)

(define (make-test-connection)
  (sqlite3-connect #:database 'memory))

(define (destroy-test-connection conn)
  (disconnect conn))


(define auth-tests
  (test-suite
   "Tests for auth.rkt"

   (test-case "auth-user? checks credentials"
     (define test-connection (make-test-connection))
     (m:persist:make-user-table! test-connection)
     (m:persist:add-user! test-connection "bob" "unhashed")
     (check-true (car (auth-user? test-connection "bob" "unhashed")))
     (check-false (car (auth-user? test-connection "dave" "unhashed")))
     (check-false (car (auth-user? test-connection "bob" "somethingelse")))     
     (disconnect test-connection))

   (test-case "auth-user? indicates if user is-admin"
     (define test-connection (make-test-connection))
     (m:persist:make-user-table! test-connection)
     (m:persist:add-user! test-connection "bob" "unhashed")
     (m:persist:add-user! test-connection "dave" "doozy" #t)
     (check-false (cdr (auth-user? test-connection "bob" "unhashed")))
     (check-true (cdr (auth-user? test-connection "dave" "doozy")))
     )
   
   )
  )

 
(run-tests auth-tests)

