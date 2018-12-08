#lang racket/base
(require db)
(require sha)


(define user-db-connection (sqlite3-connect #:database "./user.db" #:mode 'create))

(define (make-user-table! conn)
  (start-transaction conn)
  (query-exec conn "CREATE TABLE IF NOT EXISTS user (username VARCHAR PRIMARY KEY, hashed_password VARCHAR, session_id VARCHAR, session_date INTEGER)")
  (commit-transaction conn)
  )


(define (one-way-hash password)
  (sha512 (string->bytes/utf-8 password)))

(define (add-user! conn user-id password)
  (start-transaction conn)
  (query-exec conn "INSERT INTO user VALUES (?, ?, NULL, NULL)" user-id (one-way-hash password))
  (commit-transaction conn))


(define (session-expired? session_date)
  ;; session-seconds defines how many seconds can pass before a session is concidered to have expired.
  (define session-seconds 1200) ;; 1200 ÷ 60 = 20 (20 minutes)
  (if (null? session_date)
      #t
      (<= session-seconds (- (current-seconds) session_date))))

(define (new-session! conn user-id)
  #t
  )

(define (auth-user? conn user-id password)
  (let ([result (query-maybe-row conn "SELECT session_id, session_date FROM user WHERE username =? AND hashed_password =?" user-id (one-way-hash password))])
    (if result
        ;; auth succeeded
        (let ([session-date (vector-ref result 1)])
          (if (or (sql-null? session-date)
                  (session-expired? session-date))
              ;; session expired, make a new one
              (new-session! conn user-id)
              ;; session is still good
              #t))
        ;; auth failed
        #f)))

(provide make-user-table! add-user! auth-user?) 

