#lang racket

(require fontconfig
         rackunit)


;; todo
;; + how to export FcValue-type
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

(define (path->fontset bytepath)
  ((cond
     [(fc-file-is-dir bytepath) fc-dir-scan]
     [else fc-file-scan]) bytepath #t))

(define fontsets
  (time (map path->fontset '(#"/Library/Fonts" #"/Users/MB/Library/Fonts"))))

(when (ormap values fontsets)
  (define query-pattern (fc-name-parse #"Valkyrie T3"))
  (define result-pattern (fc-font-set-match fontsets query-pattern))
  (and result-pattern (fc-pattern-get-string result-pattern #"file" 0)))
