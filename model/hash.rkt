#lang racket/base
(require sha)

(define (one-way-hash password)
  (sha512 (string->bytes/utf-8 password)))


(provide one-way-hash)
