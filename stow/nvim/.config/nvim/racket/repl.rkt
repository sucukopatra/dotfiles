#lang racket/base
(require racket/class racket/runtime-path)
(provide prepare)

(define-runtime-path image-window "image-window.rkt")

(define (prepare path)
  (define mod `(file ,path))
  (define (run-sub name)
    (define m `(submod ,mod ,name))
    (when (module-declared? m #t)
      (dynamic-require m #f)))
  (run-sub 'configure-runtime)
  (current-print
   (λ (v)
     (unless (void? v)
       (print v)
       (newline)
       (when (and (object? v) ((dynamic-require '2htdp/image 'image?) v))
         ((dynamic-require image-window 'show-image) v)))))
  (dynamic-require mod #f)
  (run-sub 'main)
  (run-sub 'test))
