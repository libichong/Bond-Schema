;;; bond-mode.el --- major mode for editing bond schema buffers.

;; Author: Bichong Li <bichongl@microsoft.com>
;; Created: 29-Nov-2016
;; Version: 0.1
;; Keywords: Microsoft bond schema definition languages

;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions are
;; met:
;;
;;     * Redistributions of source code must retain the above copyright
;; notice, this list of conditions and the following disclaimer.
;;     * Redistributions in binary form must reproduce the above
;; copyright notice, this list of conditions and the following disclaimer
;; in the documentation and/or other materials provided with the
;; distribution.
;;     * Neither the name of Microsoft Inc. nor the names of its
;; contributors may be used to endorse or promote products derived from
;; this software without specific prior written permission.
;;
;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;; LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;; A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
;; OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;; SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
;; LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
;; DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
;; THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;; OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

;;; Commentary:

;; Installation:
;;   - Put `bond-mode.el' in your Emacs load-path.
;;   - Add this line to your .emacs file:
;;       (require 'bond-mode)
;;
;; You can customize this mode just like any mode derived from CC Mode.  If
;; you want to add customizations specific to bond-mode, you can use the
;; `bond-mode-hook'. For example, the following would make bond-mode
;; use 4-space indentation:
;;
;;   (defconst my-bond-style
;;     '((c-basic-offset . 4)
;;       (indent-tabs-mode . nil)))
;;
;;   (add-hook 'bond-mode-hook
;;     (lambda () (c-add-style "my-style" my-bond-style t)))
;;
;; Refer to the documentation of CC Mode for more information about
;; customization details and how to use this mode.


(require 'cc-mode)
(require 'cl)

(eval-when-compile
  (require 'cc-langs)
  (require 'cc-fonts))

;; This mode does not inherit properties from other modes. So, we do not use
;; the usual `c-add-language' function.
(eval-and-compile
  (put 'bond-mode 'c-mode-prefix "bond-"))

;; The following code uses of the `c-lang-defconst' macro define syntactic
;; features of bond buffer language.  Refer to the documentation in the
;; cc-langs.el file for information about the meaning of the -kwds variables.

(c-lang-defconst c-primitive-type-kwds
  bond '("bool" "vector" "uint8" "uint16" "double" "float" "int32" "int64" "uint32" "uint64" "string" "blob" "map"))

(c-lang-defconst c-modifier-kwds
  bond '("required" "optional"))

(c-lang-defconst c-class-decl-kwds
  bond '("struct" "enum" "namespace"))

(c-lang-defconst c-constant-kwds
  bond '("true" "false"))

(c-lang-defconst c-other-decl-kwds
  bond '("import"))

(c-lang-defconst c-other-kwds
  bond '("default" "max"))

(c-lang-defconst c-identifier-ops
  ;; Handle extended identifiers like Multimedia.HashMap.bond
  bond '((left-assoc ".")))

;; The following keywords do not fit well in keyword classes defined by
;; cc-mode.  So, we approximate as best we can.


(c-lang-defconst c-brace-list-decl-kwds
  ;; Remove syntax for C-style enumerations.
  bond nil)

(c-lang-defconst c-block-stmt-1-kwds
  ;; Remove syntax for "do" and "else" keywords.
  bond nil)

(c-lang-defconst c-block-stmt-2-kwds
  ;; Remove syntax for "for", "if", "switch" and "while" keywords.
  bond nil)

(c-lang-defconst c-simple-stmt-kwds
  ;; Remove syntax for "break", "continue", "goto" and "return" keywords.
  bond nil)

(c-lang-defconst c-paren-stmt-kwds
  ;; Remove special case for the "(;;)" in for-loops.
  bond nil)

(c-lang-defconst c-label-kwds
  ;; Remove case label syntax for the "case" and "default" keywords.
  bond nil)

(c-lang-defconst c-before-label-kwds
  ;; Remove special case for the label in a goto statement.
  bond nil)

(c-lang-defconst c-cpp-matchers
  ;; Disable all the C preprocessor syntax.
  bond nil)

(c-lang-defconst c-decl-prefix-re
  ;; Same as for C, except it does not match "(". This is needed for disabling
  ;; the syntax for casts.
  bond "\\([\{\};,]+\\)")

(defconst bond-font-lock-keywords-1 (c-lang-const c-matchers-1 bond)
  "Minimal highlighting for bond-mode.")

(defconst bond-font-lock-keywords-2 (c-lang-const c-matchers-2 bond)
  "Fast normal highlighting for bond-mode.")

(defconst bond-font-lock-keywords-3 (c-lang-const c-matchers-3 bond)
  "Accurate normal highlighting for bond-mode.")

(defvar bond-font-lock-keywords bond-font-lock-keywords-3
  "Default expressions to highlight in bond-mode.")

;; Our syntax table is auto-generated from the keyword classes we defined
;; previously with the `c-lang-const' macro.
(defvar bond-mode-syntax-table nil
  "Syntax table used in bond-mode buffers.")
(or bond-mode-syntax-table
    (setq bond-mode-syntax-table
          (funcall (c-lang-const c-make-mode-syntax-table bond))))

(defvar bond-mode-abbrev-table nil
  "Abbreviation table used in bond-mode buffers.")

(defvar bond-mode-map nil
  "Keymap used in bond-mode buffers.")
(or bond-mode-map
    (setq bond-mode-map (c-make-inherited-keymap)))

(easy-menu-define bond-menu bond-mode-map
  "Bond Buffers Mode Commands"
  (cons "Bond Buffers" (c-lang-const c-mode-menu bond)))

(add-to-list 'auto-mode-alist '("\\.bond\\'" . bond-mode))

;;;###autoload
(defun bond-mode ()
  "Major mode for editing Bond Schema description language.
The hook `c-mode-common-hook' is run with no argument at mode
initialization, then `bond-mode-hook'.
Key bindings:
\\{bond-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (set-syntax-table bond-mode-syntax-table)
  (setq major-mode 'bond-mode
        mode-name "Bond-Schema"
        local-abbrev-table bond-mode-abbrev-table
        abbrev-mode t)
  (use-local-map bond-mode-map)
  (c-initialize-cc-mode t)
  (if (fboundp 'c-make-emacs-variables-local)
      (c-make-emacs-variables-local))
  (c-init-language-vars bond-mode)
  (c-common-init 'bond-mode)
  (easy-menu-add bond-menu)
  (c-run-mode-hooks 'c-mode-common-hook 'bond-mode-hook)
  (c-update-modeline))

(provide 'bond-mode)
