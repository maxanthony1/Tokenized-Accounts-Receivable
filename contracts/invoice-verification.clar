;; Invoice Verification Contract
;; This contract validates the legitimacy of business receivables

(define-data-var admin principal tx-sender)

;; Data structure for invoices
(define-map invoices
  { invoice-id: (string-ascii 32) }
  {
    issuer: principal,
    recipient: principal,
    amount: uint,
    due-date: uint,
    verified: bool,
    timestamp: uint
  }
)

;; Public function to register a new invoice
(define-public (register-invoice
    (invoice-id (string-ascii 32))
    (recipient principal)
    (amount uint)
    (due-date uint))
  (let ((issuer tx-sender)
        (block-time (unwrap-panic (get-block-info? time (- block-height u1)))))
    (if (map-insert invoices
        { invoice-id: invoice-id }
        {
          issuer: issuer,
          recipient: recipient,
          amount: amount,
          due-date: due-date,
          verified: false,
          timestamp: block-time
        })
      (ok true)
      (err u1))))

;; Public function to verify an invoice
(define-public (verify-invoice (invoice-id (string-ascii 32)))
  (let ((invoice-data (unwrap! (map-get? invoices { invoice-id: invoice-id }) (err u2))))
    (if (is-eq tx-sender (var-get admin))
      (begin
        (map-set invoices
          { invoice-id: invoice-id }
          (merge invoice-data { verified: true }))
        (ok true))
      (err u3))))

;; Read-only function to check if an invoice is verified
(define-read-only (is-invoice-verified (invoice-id (string-ascii 32)))
  (default-to false (get verified (map-get? invoices { invoice-id: invoice-id }))))

;; Read-only function to get invoice details
(define-read-only (get-invoice-details (invoice-id (string-ascii 32)))
  (map-get? invoices { invoice-id: invoice-id }))

;; Function to change admin
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u4))
    (var-set admin new-admin)
    (ok true)))

