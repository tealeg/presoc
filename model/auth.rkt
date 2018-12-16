#lang racket/base
(require db
         sha
         (prefix-in m:hash: "hash.rkt"))

(struct user (user-id hashed-password is-admin))



;; (define (get-user)
;;   )

(define (auth-user? conn user-id password)
  (let ([result
         (query-maybe-row conn
                                 "
SELECT is_admin
FROM user
WHERE username =?
AND hashed_password =?"
                                 user-id
                                 (m:hash:one-way-hash password))])
    (if result
        (cons #t  (= (vector-ref result 0) 1))
        ;; auth failed
        (cons  #f #f))))

(provide auth-user?) 

