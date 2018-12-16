#lang racket/base

(require rackunit
         rackunit/text-ui
         db
         sha
         "persist.rkt")

(define (make-test-connection)
  (sqlite3-connect #:database 'memory))

(define (destroy-test-connection conn)
  (disconnect conn))

(define persist-tests
  (test-suite
   "Tests for persist.rkt"
              
   (test-case "make-user-table! creates a user table"
     (define test-connection (make-test-connection))
     (make-user-table! test-connection)
     (query-exec test-connection "INSERT INTO user VALUES (?, ?, ?)" "tealeg" "hashed" 0)
     (define result (query-maybe-row test-connection "SELECT * FROM user WHERE username = ?" "tealeg"))
     (check-not-false result "query returned zero rows")
     (check-equal? "tealeg" (vector-ref result 0))
     (check-equal? "hashed" (vector-ref result 1))
     (check-equal? 0 (vector-ref result 2))
     (disconnect test-connection))

   (test-case "add-user! creates a user record"
     (define test-connection (make-test-connection))
     (make-user-table! test-connection)
     (add-user! test-connection "bob" "unhashed")
     (define result (query-maybe-row test-connection "SELECT * FROM user WHERE username =?" "bob"))
     (check-not-false result "No user was created")
     (check-equal? "bob" (vector-ref result 0))
     (check-equal? (sha512 (string->bytes/utf-8 "unhashed")) (vector-ref result 1))
     (disconnect test-connection))
   )
  )

(run-tests persist-tests)
