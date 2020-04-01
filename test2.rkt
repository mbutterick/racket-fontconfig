#lang debug racket

(require fontconfig
         rackunit)


;; todo
;; + call config substitute & default substitute before match

;; earlier considerations
;; https://github.com/racket/racket/issues/1348

;; following c sample
;; https://gist.github.com/CallumDev/7c66b3f9cf7a876ef75f

;; this sample works on a machine that has a system-level fontconfig
#;(begin
    (define pat (fc-name-parse #"Valkyrie T4"))
    #;(fc-pattern-print pat)
    (define cfg (fc-config-get-current))
    (define font-set (fc-config-get-fonts cfg 'fc-set-system))
    (define-values (res fontpat) (fc-font-set-match cfg (list font-set) pat))
    (when (eq? res 'fc-result-match)
      (define val (fc-pattern-get fontpat #"file" 0))
      (when (eq? (FcValue-type val) 'fc-type-bytes)
        (union-ref (FcValue-u val) 0))))



;; this sample is for a racket-provided fontconfig
;; there is no existing config file so we just work from first principles

;; create a configuration & invoke it
(fc-config-set-current (fc-config-create))

(define (path->fontset path-string)
  (define bytepath (string->bytes/utf-8 path-string))
  ((cond
     [(fc-file-is-dir bytepath) fc-dir-scan]
     [else fc-file-scan]) bytepath))

;; todo: default font directories per platform
(define fontsets
  (time (map path->fontset '("/Library/Fonts" "/Users/MB/Library/Fonts"))))

(define (font->path family-name #:bold [bold? #f] #:italic [italic? #f])
  (when (ormap values fontsets)
    ;; query pattern syntax
    ;; https://www.freedesktop.org/software/fontconfig/fontconfig-user.html#AEN36
    (define query-pattern (fc-name-parse (string->bytes/utf-8 (format "~a:weight=~a:slant=~a" family-name (if bold? 200 80) (if italic? 100 0)))))
    (fc-config-substitute query-pattern 'FcMatchPattern)
    (fc-default-substitute query-pattern)
    (define result-pattern (fc-font-set-match fontsets query-pattern))
    (and result-pattern (bytes->path (fc-pattern-get-string result-pattern #"file" 0)))))

;; next: how to incl bold / italic in query pattern


(font->path "Meta Serif OT")
(font->path "Meta Serif OT" #:italic #t)
(font->path "Meta Serif OT" #:bold #t)
(font->path "Meta Serif OT" #:bold #t #:italic #t)
(font->path "Equity Text A")
(font->path "Equity Text A" #:italic #t)
(font->path "Equity Text A" #:bold #t)
(font->path "Equity Text A" #:italic #t #:bold #t)