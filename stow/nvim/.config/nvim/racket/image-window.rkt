#lang racket/base
(require racket/class racket/gui/base (only-in 2htdp/image image-width image-height))
(provide show-image)

(define eventspace (make-eventspace))
(define-values (frame text)
  (parameterize ([current-eventspace eventspace])
    (define frame (new frame% [label "Racket image"]))
    (define text (new text%))
    (new editor-canvas% [parent frame] [editor text])
    (values frame text)))

(define (show-image img)
  (parameterize ([current-eventspace eventspace])
    (queue-callback
     (λ ()
       (send* text (lock #f) (erase) (insert (send img copy)) (lock #t))
       (send frame resize (max 200 (+ 40 (image-width img))) (max 100 (+ 60 (image-height img))))
       (send frame show #t)))))
