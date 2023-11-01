((c-mode
   (indent-tabs-mode . nil)
   (c-file-style . "bsd")
   (c-basic-offset . 2)
   (eval . (eglot-ensure))
   (eval . (add-hook 'before-save-hook #'eglot-format-buffer nil t))))
