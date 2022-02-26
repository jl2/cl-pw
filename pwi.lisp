;; pwi.lisp
;; Copyright (c) 2021 Jeremiah LaRocco <jeremiah_larocco@fastmail.com>

;; Permission to use, copy, modify, and/or distribute this software for any
;; purpose with or without fee is hereby granted, provided that the above
;; copyright notice and this permission notice appear in all copies.

;; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
;; WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
;; MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
;; ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
;; WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
;; ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
;; OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

;; The pwi package contains the low level C wrapper library.
;; For now it's auto-generated with autowrap, but I'll look at a minimal CFFI
;; if autowrap becomes unwieldy or has too much overhead.

(defpackage :pwi
  (:nicknames)
  (:use #:cl #:j-utils #:alexandria)
  (:import-from :cffi :null-pointer)
  (:export #:null-pointer))

(in-package :pwi)


(cffi:define-foreign-library pipe-wire-lib
    (:darwin (error "No pipe-wire on OSX!"))
    (:unix (:or "libpipe-wire-0.3" "libpipe-wire-0.3.so.0" "/usr/lib/x86_64-linux-gnu/libpipewire-0.3.so.0"))
    (t (:default "libpipe-wire")))
(cffi:use-foreign-library pipe-wire-lib)


(cffi:defcfun ("read" posix-read) :unsigned-long
  "Posix read function."
  (fd :int)
  (buffer :pointer)
  (length :unsigned-long))

(cffi:defcfun ("write" posix-write) :unsigned-long
  "Posix read function."
  (fd :int)
  (buffer :pointer)
  (length :unsigned-long))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun pw-renamer (string matches regex)
    (declare (ignorable string matches regex))
    (if (= 0 (length matches))
        (error "matches is of length 0~%~a ~a ~a" string matches regex)
        (aref matches 0))))

(autowrap:c-include
 "/usr/include/pipewire-0.3/pipewire/pipewire.h"
 :sysincludes (list "/usr/include/spa-0.2/"
                    "/usr/include/pipewire-0.3/"
                    #+linux"/usr/local/include/"
                    #+linux"/usr/include/"
                    #+linux"/usr/include/linux/"
                    #+linux"/usr/include/x86_64-linux-gnu/"
                    #+linux"/usr/include/x86_64-linux-gnu/sys/")
 :spec-path '(pwi specs)
 :trace-c2ffi t
 :symbol-regex (("^pw_(.*)" (:case-insensitive-mode t) #'pw-renamer))
 :symbol-exceptions (("t" . "pwt")
                     ("pw_strerror" . "strerror")
                     ("pw_make_stream" . "pw-make-stream")
                     ("pw_stream" . "pw-stream")
                     ("pw_loop" . "pw-loop")
                     ("pw_time" . "pw-time")
                     ("FILE" . "pw-file")
                     )
 :exclude-arch ("i686-pc-linux-gnu"
                "i686-pc-windows-msvc"
                "x86_64-pc-windows-msvc"
                "i686-apple-darwin9"
                "x86_64-apple-darwin9"
                "i386-unknown-freebsd"
                "x86_64-unknown-freebsd"
                "i386-unknown-openbsd"
                "x86_64-unknown-openbsd"
                "arm-pc-linux-gnu"
                "arm-unknown-linux-androideabi"
                "aarch64-unknown-linux-android"
                "i686-unknown-linux-android"
                "x86_64-unknown-linux-android")
 :exclude-definitions ("^va_list$"
                       "^__PTHREAD.*"
                       "^pthread_attr_t$"
                       "^sigevent$"
                       "^sigevent_t$"
                       "Random" "Signal" "long-double"
                       "^acos$" "^asin$" "^atan$" "^cos$" "^sin$" "^tan$" "^div$" "^ldiv$" "^lldiv$"
                       "^log$" "^exp$" "^acosh$" "^cosh$" "^asinh$" "^sinh$"
                       "^tanh$" "^atanh$"  "^sqrt$" "^floor$" "^round$"
                       "^time$" "^close$" "^open$" "^write$" "^read$"
                       "^sleep$" "^truncate$" "^ceil$"
                       "^abs$" "^abort$" "^random$" "^remove$" "^signal$"
                       "^t$"))
