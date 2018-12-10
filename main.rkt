#lang racket/base

(require web-server/servlet
         web-server/servlet-env
         (prefix-in m:auth: "./model/auth.rkt")
         (prefix-in v:auth: "./view/auth.rkt"))

(define (make-presoc-servlet user-conn)
  (lambda (req)
    (cond
      [(not (v:auth:authenticated? user-conn req))
       (response 401 #"Unauthorized"
                 (current-seconds)
                 TEXT/HTML-MIME-TYPE
                 (list
                  (make-basic-auth-header "Authentication required"))
                 void)]
      
    [else (response/xexpr
           #:preamble #"<!DOCTYPE html>"
           `(html
             (head)
             (body
              (p "Hello, " ,(bytes->string/utf-8 (v:auth:req->user req)) "!"))))])))

(define user-conn (m:auth:connect!))
(m:auth:make-user-table! user-conn)

(define presoc-servlet (make-presoc-servlet user-conn))


(serve/servlet presoc-servlet
                #:servlet-regexp #rx"")
