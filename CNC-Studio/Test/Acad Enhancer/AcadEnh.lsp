; AcadEnh.lsp    Link to external Utility AcadEnhancer.EXE
; (c) avril 2000, 2004 , O. Baumgartner, CH-1345 Le lieu

; (QuoteStr Str)          return quoted Str
; (EnhStr Str)            return quoted Str, with /File="..." formating
; (GetTempDir)            return defined temporary dir
; (AcadEnhOpenTemp Mode)  open temporary file
; (AcadEnhClose)          close the opened AcadEnhancer Session
; (AcadEnhInit)           Start a AcadEnhancer Session (Automatic)
; #AcadEnhTempFileName    Name of temporary file

(prompt "\nLoading AcadEnh...")


(unit "AcadEnh" (Uses '()))

;***************************************************************

(defun QuoteStr(Str)
;  (prompt "\nQuoteStr")
  (strcat "\"" Str "\"")
)

; QuoteStr if it's not done
; allow special form like /FILE="..."
(defun EnhStr(s); / Len)
  (setq Len (strlen s))
  (if (zerop Len)
    ""
    (cond
      ((and (= (substr s 1 1) "/")  (= (substr s Len 1) "\"")) s)
      (T (strcat "\"" s "\"")))
  ) ; if
)

(defun list2str(x)
   (prompt "\nlist2str")
   (print x)
   (apply 'strcat
      (mapcar '(lambda (Arg) 
        (print Arg)
        (strcat ; translate to strings
        (cond
          ((= (type Arg) 'INT) (itoa Arg))
          ((= (type Arg) 'REAL) (rtos Arg 2))
          ((= (type Arg) 'STR) (EnhStr Arg))
          (T "*ErreurArg*")
        ) ; cond
        " ")) x) ; on a une liste de cha�nes
    ) ; Uniq string

)

(defun GetTempDir(/ tmp)
  (setq tmp (cond
    ((/= "" (getenv "TEMP")) (getenv "TEMP"))
    (T (getvar "TEMPPREFIX"))))
  (If (and (/= "" tmp) (/= "\\" (substr tmp (strlen tmp))))
    (strcat tmp "\\")
    tmp)
)

(defun AcadEnhOpenTemp(Mode)
  (open #AcadEnhTempFileName Mode)
)


(defun AcadEnhClose()
  (AcadEnh "/CLOSE" nil nil))


(Cond
  ((wcmatch (GetAcadVersion) "R*")
      (xload "DDELISP")
      (defun AcadEnhInit()
        (setq #AcadEnhChnl
              (appinit "AcadEnh" "System" (findfile "AcadEnh.EXE")))
        (if (zerop #AcadEnhChnl)
          (alert (strcat
            "Erreur localisation AcadEnh.EXE"
            "\n\nEffacer le fichier\n\n"
            (QuoteStr #AcadEnhTempFileName)))
          (AcadEnh "/INIT" (list #AcadEnhTempFileName (GetAcadVersion) (ver)) T)
        )
      ) ; defun AcadEnhInit

      (defun AcadEnh(Cmd Args ReturnFlg / f str busy)
      ; Cmd       = command for AcadEnhancer
      ; Args      = arguments list
      ; ReturnFlg = need to read returned data
        (execute #AcadEnhChnl
          (apply 'strcat
            (mapcar '(lambda (Arg) (strcat ; translate to strings
              (cond
                ((= (type Arg) 'INT) (itoa Arg))
                ((= (type Arg) 'REAL) (rtos Arg 2))
                ((= (type Arg) 'STR) (EnhStr Arg))
                (T "*ErreurArg*")
              ) ; cond
              " ")) (cons (getpid) (cons cmd Args))) ; on a une liste de cha�nes
          ) ; Uniq string
        ) ; execute
        (setq busy T) ; Wait for execution
        (while busy
          (setq busy (= (strcase (substr (request #AcadEnhChnl "Status") 1 4))
                        "BUSY"))
        )
        (if ReturnFlg ; read returned Data
;          (progn
;            (setq f (AcadEnhOpenTemp "r")
;                  str (read-line f))
;            (close f)
;          )
;          (setq str "nil"))
;        (eval (read str))
          (load #AcadEnhTempFileName))
      )
  )    ; AutoCAD Full
  ((wcmatch (GetAcadVersion) "LT*")
       (defun AcadEnhInit(/ f)
         (setq #PathDDE4LT (findfile "DDE4LT.EXE"))
         (setq f (AcadEnhOpenTemp "w"))
         (princ "(alert (strcat " f)
         (prin1 "Erreur localisation DDE4LT.EXE ou AcadEnh.EXE" f) (princ " " f)
         (prin1 "\n\nEffacer le fichier \n\n" f) (princ " " f)
         (princ "(QuoteStr #AcadEnhTempFileName)" f) (write-line "))" f)
         (princ "; " f) (prin1 #PathDDE4LT f) (write-line "" f)
         (close f)
;         (AcadEnh "/INIT" (list #AcadEnhTempFileName (GetAcadVersion) (ver)) T)
         (AcadEnh "/INIT" (list #AcadEnhTempFileName (GetAcadVersion) "LT2005") T)
       )

       (defun AcadEnh(Cmd Args ReturnFlg / f str)
       ; Cmd       = command for AcadEnhancer
       ; Args      = arguments list
       ; ReturnFlg = need to read returned data
         (prompt (strcat "\nAcadEnh " Cmd))
         (print (list2str (cons (getpid) (cons Cmd Args)))) 
         (prompt "\nTry Startapp-And-Wait")       
         (Startapp-And-Wait #PathDDE4LT
           (apply 'strcat
             (mapcar '(lambda (Arg) (strcat ; translate to string
               (cond
                 ((= (type Arg) 'INT) (itoa Arg))
                 ((= (type Arg) 'REAL) (rtos Arg 2))
                 ((= (type Arg) 'STR) (EnhStr Arg))
                 (T "*ErreurArg*")
               ) ; cond
               " ")) (cons (getpid) (cons Cmd Args))) ; string list
           ) ; single string
         ) ; Startapp-And-Wait
         (prompt "\nStartapp-And-Wait Done")
         (if ReturnFlg
;           (progn
;             (setq f (AcadEnhOpenTemp "r")
;                   str (read-line f))
;             (close f)
;           )
;           (setq str "nil"))
;         (eval (read str))
          (load #AcadEnhTempFileName))
       ))
  (T (alert "Check for your current AutoCAD version"))  ; else alert
) ; cond acadver

;**************************************************************************************

(setq #AcadEnhTempFileName (strcat (gettempdir) "~AcEnh" (itoa (getpid)) ".TMP"))
(AcadEnhInit) ; Open a new AcadEnhancer Session (protocol is depending AcadVersion)

(prompt "\nAcadEnh loaded")
