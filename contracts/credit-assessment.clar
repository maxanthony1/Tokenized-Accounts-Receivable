;; Credit Assessment Contract
;; This contract evaluates payment likelihood and timeframes

(define-data-var admin principal tx-sender)

;; Data structure for credit scores
(define-map credit-scores
  { entity: principal }
  {
    score: uint,
    payment-history: uint,
    debt-ratio: uint,
    last-updated: uint
  }
)

;; Data structure for invoice risk assessments
(define-map invoice-assessments
  { invoice-id: (string-ascii 32) }
  {
    risk-score: uint,
    expected-days-to-payment: uint,
    confidence: uint,
    assessor: principal
  }
)

;; Public function to update credit score
(define-public (update-credit-score
    (entity principal)
    (score uint)
    (payment-history uint)
    (debt-ratio uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (let ((block-time (unwrap-panic (get-block-info? time (- block-height u1)))))
      (map-set credit-scores
        { entity: entity }
        {
          score: score,
          payment-history: payment-history,
          debt-ratio: debt-ratio,
          last-updated: block-time
        })
      (ok true))))

;; Public function to assess invoice risk
(define-public (assess-invoice-risk
    (invoice-id (string-ascii 32))
    (risk-score uint)
    (expected-days-to-payment uint)
    (confidence uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u2))
    (map-set invoice-assessments
      { invoice-id: invoice-id }
      {
        risk-score: risk-score,
        expected-days-to-payment: expected-days-to-payment,
        confidence: confidence,
        assessor: tx-sender
      })
    (ok true)))

;; Read-only function to get credit score
(define-read-only (get-credit-score (entity principal))
  (map-get? credit-scores { entity: entity }))

;; Read-only function to get invoice risk assessment
(define-read-only (get-invoice-risk (invoice-id (string-ascii 32)))
  (map-get? invoice-assessments { invoice-id: invoice-id }))

;; Function to change admin
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u3))
    (var-set admin new-admin)
    (ok true)))

