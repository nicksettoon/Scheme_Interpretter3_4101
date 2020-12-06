(define b< s48b<)
(define b= s48b=)
(define b/ s48b/)
(define b- s48b-)
; check helper function ids case of binary operation
(define int-int 1)
(define int-rat 2)
(define rat-int 3)
(define rat-rat 4)
(define undef 5)

(define (check x y)
    (cond
        ((integer? x)
            (cond
                ((integer? y) int-int)
                ((rational? y) int-rat)
                (else undef)))
        ((rational? x)
            (cond
                ((integer? y) rat-int)
                ((rational? y) rat-rat)
                (else undef)))
         (else undef)
    )
)

; rational
(define (rational n d) (list 'rational n d))

; integer?
(define (integer? x)
    (if (boolean? x) #f
        (if (symbol? x) #f
            (if (char? x) #f
                (if (vector? x) #f
                    (if (procedure? x) #f
                        (if (pair? x) #f
                            (if (string? x) #f
                                    (if (= x (round x)) #t #f)
                            )
                        )
                    )
                )
            )
        )
    )
)

; rational?
(define (rational? rat)
    (if (integer? rat) #t
        (if (pair? rat)
            (if (eq? 'rational (car rat))
                (if (pair? (cdr rat))
                    (if (pair? (cddr rat))
                        (if (null? (cdddr rat))
                            (let ((num (cadr rat))
                                (den (caddr rat)))
                                (if (integer? num)
                                    (if (integer? den) #t #f)
                                    #f))
                        #f)
                    #f)
                #f)
            #f)
        #f)
    )
)

; number?
(define number? rational?)

; numerator?
(define (numerator rat) (let ((result (simplify rat)))
    (if (integer? result) result (cadr result))))

; denominator?
(define (denominator rat) (let ((result (simplify rat)))
    (if (integer? result) 1 (caddr result))))

; quotient
(define (quotient a b) (let ()
    (define (getq a b q)
            (let ((diff (b- a b)))
                (cond
                    ((< diff 0) q)
                    ((= diff 0) (b+ q 1))
                    (else (getq diff b (b+ q 1)))
                )
            ))
    (if (b= 0 b) (display "Don't divide by zero.") (getq a b 0)))
)

; remainder
(define (remainder a b)
    (let ((q (quotient a b)))
        (- a (* b q))
    )
)

; bgcd
(define (bgcd a b) 
    (let
        ((a (abs a))
        (b (abs b)))
        (cond 
            ((b= 0 a) b)
            ((b= 0 b) a)
            ((b= 0 (remainder a b)) b)
            (else (bgcd b (remainder a b)))
        )
    )
)
; simplify
(define (simplify rat) 
    (cond
        ((integer? rat) rat)
        ((rational? rat)
            (let* ((num (cadr rat))
                (den (caddr rat))
                (ratgcd (bgcd num den))
                (newnum (b/ num ratgcd))
                (newden (b/ den ratgcd)))
                (if (= 1 newden) newnum (rational newnum newden))))
        (else rat))
)

; negative?
(define (negative? x)
    (cond
        ((integer? x)
            (b< x 0))
        ((rational? x)
            (if (b< (numerator x) 0) #t
                (if (b< (denominator x) 0) #t #f)))
        (else (b< x 0))
    )
)

; positive?
(define (positive? x)
    (cond
        ((integer? x)
            (b< 0 x))
        ((rational? x)
            (if (b< 0 (numerator x))
                (if (b< 0 (denominator x)) #t #f)
                #f))
        (else (b< 0 x))
    )
)

; abs
(define (abs x)
    (if (negative? x)
        (cond
            ((integer? x) (b* -1 x))
            ((rational? x)
                (rational (abs (numerator x)) (abs(denominator x))))
        )
    x)
)

; zero
(define (zero? x) 
    (cond
        ((integer? x) (b= 0 x))
        ((rational? x) (b= 0 (numerator x)))
        (else (b= 0 x))
    )
)
; helper functions for getting un-simplified num and den of rational
(define (num x) (cadr x))
(define (den x) (caddr x))
(define (mkrat num rat)
    (rational (b* num (den rat)) (den rat))
)

; b+
(define (b+ x y)
    (let ((case (check x y)))
        (cond
            ((s48b= case int-int) ; TODO change to b=
                (s48b+ x y)
            )
            ((s48b= case int-rat); TODO change to b=
                (let
                    ((ratx (mkrat x y)))
                    (b+ ratx y))
            )
            ((s48b= case rat-int); TODO change to b=
                (b+ y x)
            )
            ((s48b= case rat-rat); TODO change to b=
                (let* ((n1 (num x))
                       (d1 (den x))
                       (n2 (num y))
                       (d2 (den y)))
                    (if (s48b= d1 d2) ; TODO change to b=
                        (let ()
                            (simplify (rational (b+ n1 n2) d1)))
                        (let ((newd (b* d1 d2))
                              (newn1 (b* n1 d2))
                              (newn2 (b* n2 d1)))
                            (b+ (rational newn1 newd) (rational newn2 newd))
                        )
                    )
                )
            )
            (else (s48b+ x y))
        )
    )
)

; b*
(define (b* x y)
    (let ((case (check x y)))
        (cond
            ((s48b= case int-int); TODO change to b=
                (s48b* x y)
            )
            ((s48b= case int-rat); TODO change to b=
                (simplify (rational (b* x (num y)) (den y)))
            )
            ((s48b= case rat-int); TODO change to b=
                (b* y x)
            )
            ((s48b= case rat-rat); TODO change to b=
                (let* ((n1 (num x))
                      (d1 (den x))
                      (n2 (num y))
                      (d2 (den y))
                      (newn (b* n1 n2))
                      (newd (b* d1 d2)))
                    (simplify (rational newn newd))
                )
            )
            (else (s48b* x y))
        )
    )
)

; ; b-
; (define (b- x y)
;     (cond
;         ((integer? x) (b= 0 x))
;         ((rational? x) (b= 0 (numerator x)))
;         (else (b= 0 x))
;     )
; )
; 
; ; b*
; (define (b* x y)
;     (cond
;         ((integer? x) (b= 0 x))
;         ((rational? x) (b= 0 (numerator x)))
;         (else (b= 0 x))
;     )
; )
; 
; ; b/
; (define (b/ x y)
;     (cond
;         ((integer? x) (b= 0 x))
;         ((rational? x) (b= 0 (numerator x)))
;         (else (b= 0 x))
;     )
; )
; 
; ; b=
; (define (b= x y)
;     (cond
;         ((integer? x) (b= 0 x))
;         ((rational? x) (b= 0 (numerator x)))
;         (else (b= 0 x))
;     )
; )
; 
; ; b<
; (define (b< x y)
;     (cond
;         ((integer? x) (b= 0 x))
;         ((rational? x) (b= 0 (numerator x)))
;         (else (b= 0 x))
;     )
; )

; check test cases
; (check 1 2)
; (check 1 (rational 3 2))
; (check (rational 1 2) 3)
; (check (rational 1 2) (rational 4 6))
; (check 2 "asdf")
; (check (rational 2 3) "asdf")
; (check "asdf" 45)