;;; .yas-setup.el --- beancount snippets 的共享辅助函数 -*- lexical-binding: t; -*-
;;
;; yasnippet 加载 beancount-mode 目录下的 snippets 时会自动 load 本文件。
;; 换机注意：本文件在 ~/.doom.d/snippets/beancount-mode/ 下，
;; .gitignore 已放行 snippets/**，会被跟踪。

;; ---- ETF 代码表 ----
;; code -> (基金全称, asset_category, 账户分类段)
(defvar bc-etf-table
  '(("159209" "招商中证全指红利质量 ETF" "红利质量" "DividendQuality")
    ("159307" "红利低波 100ETF" "红利低波" "DividendLowVol")
    ("159501" "嘉实纳斯达克 100ETF(QDII)" "纳指 100" "Nasdaq100")
    ("159659" "招商纳斯达克 100ETF(QDII)" "纳指 100" "Nasdaq100")
    ("159696" "易方达纳斯达克 100ETF(QDII)" "纳指 100" "Nasdaq100")
    ("513100" "国泰纳斯达克 100ETF(QDII)" "纳指 100" "Nasdaq100")
    ("513870" "富国纳斯达克 100ETF(QDII)" "纳指 100" "Nasdaq100")
    ("563510" "易方达中证 A500 红利低波动 ETF" "红利低波" "DividendLowVol")
    ("511880" "银华日利 ETF" "货币" "MoneyMarket"))
  "ETF 代码 -> (基金全称 asset_category 账户分类段)。新增标的时在这里加一行。")

(defun bc-etf (code what)
  "查 ETF 代码表。WHAT 取 'name / 'cat / 'cls，查不到返回空串。"
  (let ((e (assoc (string-trim (or code "")) bc-etf-table)))
    (if e (nth (pcase what ('name 1) ('cat 2) ('cls 3)) e) "")))

;; ---- 招行转出去向表 ----
;; 目标 -> (对方账户, cashflow_type)
;; 注意：信用账户的 cashflow_type 历史上写的是 "转出:股票账户"，与账本保持一致。
(defvar bc-out-table
  '(("股票账户"   "Assets:Investment:Broker:Normal:Cash" "转出:股票账户")
    ("信用账户"   "Assets:Investment:Broker:Margin:Cash" "转出:股票账户")
    ("养老金账户" "Assets:Investment:Pension:Cash"       "转出:养老金账户")
    ("消费"       "Expenses:ExternalOutflow"             "转出:消费"))
  "招行转出去向 -> (对方账户 cashflow_type)。")

(defun bc-out (target what)
  "查招行转出去向表。WHAT 取 'acct / 'type，查不到原样返回 TARGET。"
  (let ((e (assoc (string-trim (or target "")) bc-out-table)))
    (if e (nth (if (eq what 'acct) 1 2) e) (or target ""))))

;; ---- 数值工具 ----
(defun bc-num (s)
  "字符串转数字，失败返回 0。"
  (let ((n (string-to-number (string-trim (or s "")))))
    (if (numberp n) n 0)))

(defun bc-value (shares price)
  "份额 × 单价 = 成交额，2 位小数。"
  (format "%.2f" (* (bc-num shares) (bc-num price))))

(defun bc-fee (value)
  "券商佣金：成交额 × 0.5‱，最低 5 元。VALUE 可为字符串或数字。
实测：2026-06-10 之后 26 笔券商交易 22 笔精确命中，余 4 笔偏差 <0.02 元。
2026-06-09 及更早是纯 0.5‱ 无最低 5 元，别拿本函数校验旧账。"
  (format "%.4f" (max 5.0 (* (bc-num value) 5e-5))))

(defun bc-sub (a b &optional digits)
  "A - B，默认 2 位小数。参数可为字符串或数字。"
  (format (concat "%." (number-to-string (or digits 2)) "f")
          (- (bc-num a) (bc-num b))))

(defun bc-add (&rest nums)
  "多个数相加，2 位小数。参数可为字符串或数字。"
  (format "%.2f" (apply #'+ (mapcar #'bc-num nums))))

(defun bc-shares (amount price fee)
  "基金申购：(申购金额 - 申购费) ÷ 净值 = 份额，2 位小数。"
  (let ((net (- (bc-num amount) (bc-num fee))))
    (format "%.2f" (if (> (bc-num price) 0) (/ net (bc-num price)) 0))))

;; ---- 回查账本 ----
(defun bc-last-buy (what)
  "从光标处向上找最近一笔券商买入/融资买入，返回其字段。
WHAT 取 'date / 'code / 'shares / 'price。找不到时 date 返回今天，其余返回空串。"
  (save-excursion
    (if (not (re-search-backward
              "^\\([0-9]\\{4\\}-[0-9][0-9]-[0-9][0-9]\\) \\* \"\\(融资\\)?买入[^\"]*[(]\\([0-9]\\{6\\}\\)[)]\"" nil t))
        (pcase what ('date (format-time-string "%Y-%m-%d")) (_ ""))
      (let ((date (match-string-no-properties 1))
            (code (match-string-no-properties 3))
            ;; 交易块到下一条空行为止
            (end (save-excursion (if (re-search-forward "^$" nil t) (point) (point-max)))))
        (pcase what
          ('date date)
          ('code code)
          ('shares
           (or (save-excursion
                 (when (re-search-forward "^  Assets:Investment:Broker:[^ ]* +\\([0-9.]+\\) ETF" end t)
                   (match-string-no-properties 1)))
               ""))
          ('price
           (or (save-excursion
                 (when (re-search-forward "trade_price: \"\\([0-9.]+\\)" end t)
                   (match-string-no-properties 1)))
               "")))))))

(defun bc-last-balance (account)
  "向上找 ACCOUNT 最近一条 balance 断言，返回其金额绝对值字符串，找不到返回空串。"
  (save-excursion
    (if (re-search-backward
         (concat "^[0-9]\\{4\\}-[0-9][0-9]-[0-9][0-9] balance " (regexp-quote account) " *-\\([0-9.]+\\)")
         nil t)
        (match-string-no-properties 1)
      "")))

(provide '.yas-setup)
;;; .yas-setup.el ends here
