#lang racket/base
(require db
         (prefix-in m:hash: "hash.rkt"))

(define db-name "presoc.db")

(define (db-path)
  (build-path (current-directory) db-name))

(define (connect!)
  (sqlite3-connect #:database (db-path) #:mode 'create))

(define (disconnect! conn)
  (disconnect conn))

(define (make-user-table! conn)
  (query-exec conn "
CREATE TABLE IF NOT EXISTS user (
    username TEXT PRIMARY KEY,
    hashed_password TEXT,
    is_admin BOOLEAN
)
"))

(define (add-user! conn user-id password [is-admin #f])
  (start-transaction conn)
  (let ([admin (if is-admin 1 0)])
    (query-exec conn "
INSERT INTO user 
VALUES (?, ?, ?)"
                user-id (m:hash:one-way-hash password) admin))
  (commit-transaction conn))


(define (init-db! conn)
  (start-transaction conn)
  (make-user-table! conn)
  (commit-transaction conn)
  )

(provide connect! disconnect! init-db! make-user-table! add-user! )
