#lang racket/base

(require rackunit
         db
         sha
         "auth.rkt")
(require rackunit/text-ui)

(require/expose "auth.rkt" (session-expired?))

(define (make-test-connection)
  (sqlite3-connect #:database 'memory))

(define (destroy-test-connection conn)
  (disconnect conn))

(define auth-tests
  (test-suite
   "Tests for auth.rkt"
              
   (test-case "make-user-table creates a user table"
     (define test-connection (make-test-connection))
     (make-user-table! test-connection)
     (query-exec test-connection "INSERT INTO user VALUES (?, ?, NULL, NULL)" "tealeg" "hashed")
     (define result (query-maybe-row test-connection "SELECT * FROM user WHERE username = ?" "tealeg"))
     (check-not-false result "query returned zero rows")
     (check-equal? "tealeg" (vector-ref result 0))
     (check-equal? "hashed" (vector-ref result 1))
     (disconnect test-connection)
     )

   (test-case "add-user! creates a user record"
     (define test-connection (make-test-connection))
     (make-user-table! test-connection)
     (add-user! test-connection "bob" "unhashed")
     (define result (query-maybe-row test-connection "SELECT * FROM user WHERE username =?" "bob"))
     (check-not-false result "No user was created")
     (check-equal? "bob" (vector-ref result 0))
     (check-equal? (sha512 (string->bytes/utf-8 "unhashed")) (vector-ref result 1))
     (disconnect test-connection)
     )

   (test-case "session-expired? returns #t when the session date is more than 20 minutes old"
     (check-true (session-expired? 0))
     (check-true (session-expired? (- (current-seconds) 1200))))

   (test-case "auth-user"
     (define test-connection (make-test-connection))
     (make-user-table! test-connection)
     (add-user! test-connection "bob" "unhashed")
     (check-true (auth-user? test-connection "bob" "unhashed"))
     (check-false (auth-user? test-connection "dave" "unhashed"))
     (check-false (auth-user? test-connection "bob" "somethingelse"))     
     (disconnect test-connection))
   )
  )

 
(run-tests auth-tests)

