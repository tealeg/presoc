#lang racket/base

(require
 racket/match
 web-server/http/basic-auth
  (prefix-in m:auth:  "../model/auth.rkt"))


(define (req->user req)
  ; extracts the user for this request
  (match (request->basic-credentials req)
    [(cons user pass)   user]
    [else               #f]))


(define (authenticated? conn req)
  ; Check that a request has valid credentials
  (match (request->basic-credentials req)
    [(cons user pass)
     (m:auth:auth-user? conn
                        (bytes->string/utf-8 user)
                        (bytes->string/utf-8 pass))]
    [else #f]))


(provide authenticated? req->user)
