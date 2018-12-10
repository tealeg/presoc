#lang racket/base

(require rackunit
         rackunit/text-ui
         web-server/http/request-structs
         net/url
         net/base64
         racket/promise
         "auth.rkt"
         (prefix-in m:auth: "../model/auth.rkt")
         )

(require/expose "auth.rkt" (authenticated?))
(require/expose "../model/auth-test.rkt" (make-test-connection destroy-test-connection))

(define (basic-auth-header uid pass)
  (header #"Authorization"
          (bytes-append #"Basic "
                        (base64-encode (bytes-append uid #":" pass)))))

(define (make-test-request method uri headers uid pass)
  (let ([headers (cons (basic-auth-header uid pass) headers)])
    (make-request
     method            ;;method
     (string->url uri) ;; uri
     headers           ;; Headers
     (delay '())       ;; bindings/raw-promise
     #f                ;;  post-data/raw
     "127.0.0.1"       ;; host-ip
     80                ;;	host-port
     "127.0.0.1")))    ;; client-ip

  

(define auth-tests
  (test-suite "Tests for view/auth.rkt"

              (test-case "authenticated?"
)
                
              (let ([test-connection (make-test-connection)]
                    [request (make-test-request #"GET" "/" '() #"bob" #"bobbit")])
                (m:auth:make-user-table! test-connection)
                (m:auth:add-user! test-connection "bob" "bobbit")
                (check-true (authenticated? test-connection request))
                ;; build a request and test it
                
                (destroy-test-connection test-connection))))

(run-tests auth-tests)



