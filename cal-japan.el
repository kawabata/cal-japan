;;; cal-japan.el --- Japanese Calendar                -*- lexical-binding: t; -*-

;; Copyright (C) 2020 Taichi Kawabata

;; Keywords: calendar

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Japanese Calendar
;; based on https://github.com/suchowan/when_exe/blob/master/lib/when_exe/region/japanese/

;;; Basic Constants & Variables:

(require 'calendar)
(require 'seq)

(defvar calendar-japanese-celestial-stem
  ["甲" "乙" "丙" "丁" "戊" "己" "庚" "辛" "壬" "癸"])

(defvar calendar-japanese-celestial-stem-on
  ["コウ" "オツ" "ヘイ" "テイ" "ボ" "キ" "コウ" "シン" "ジン" "キ"])

(defvar calendar-japanese-celestial-stem-kun
  ["きのえ" "きのと" "ひのえ" "ひのと" "つちのえ" "つちのと" "かのえ" "かのと" "みずのえ" "みずのと"])

(defvar calendar-japanese-terrestrial-branch
  ["子" "丑" "寅" "卯" "辰" "巳" "午" "未" "申" "酉" "戌" "亥"])

(defvar calendar-japanese-terrestrial-branch-on
  ["シ" "チュウ" "イン" "ボウ" "シン" "シ" "ゴ" "ビ" "シン" "ユウ" "ジュツ" "ガイ"])

(defvar calendar-japanese-terrestrial-branch-kun
  ["ね" "うし" "とら" "う" "たつ" "み" "うま" "ひつじ" "さる" "とり" "いぬ" "い"])

(defvar calendar-japanese-sexagenary-form '("（" stem branch "・" stem-kun stem-no branch-kun "）")
  "Format for Japanese Sexagenary.
`stem-no' denotes `の' character that is only used when stem is odd number.")

(defconst calendar-japanese-year-index 454)

(defsubst calendar-japanese-year-index (year)
  "Japanese YEAR index."
  (- year calendar-japanese-year-index))

(defconst calendar-japanese-absolute-start 165501)
;; 2/15/454 ... 165501
;; 1/25/445 ... 162193

(defconst calendar-japanese-1/1/1873-absolute 683734)

(defconst calendar-japanese-year-months
  '[;; AbCdEeFgHiJkL ;; 1/25/445 允恭天皇34年
    ;; AbCdEfGhIjKl AbCDeFgHiJkL aBbCdEfGHiJkL aBcDeFgHiJkL AbCdEfGhIjJkL
    ;; aBCdEfGhIjKl AbCdEfGHiJkL aBcDeFfGhIjKL
    aBcDeFgHiJkL  aBCdEfGhIjKl ;; 2/15/454 安康天皇1年
    AbCcDeFGhIjKl AbCdEfGhIjKL  aBcDeFgHiJkLl AbCDeFgHiJkL  aBcDeFGhIjKl
    AbCdEfGhIiJKl AbCdEfGhIjKl  AbCDeFgHiJkL  aBcDeEFgHiJkL aBcDeFgHiJKl
    AbCdEfGhIjKl  AaBCdEfGhIjKl AbCdEFgHiJkL  aBcDeFgHiJKkL aBcDeFgHiJkL
    aBCdEfGhIjKl  AbCdEFgGhIjKl AbCdEfGhIJkL  aBcDeFgHiJkL  aBCcDeFgHiJkL
    aBcDEfGhIjKl  AbCdEfGhIJkLl AbCdEfGhIjKl  ABcDeFgHiJkL  aBcDEfGhIiJkL
    aBcDeFgHIjKl  AbCdEfGhIjKl  ABcDeEfGhIjKl AbCDeFgHiJkL  aBcDeFgHIjKl
    AaBcDeFgHiJkL AbCdEfGhIjKl  AbCDeFgHiJjKl AbCdEfGHiJkL  aBcDeFgHiJkL
    AbCdEfGgHiJkL aBCdEfGhIjKl  AbCdEfGHiJkL  aBcDdEfGhIjKL aBcDeFgHiJkL
    aBCdEfGhIjKlL aBcDeFGhIjKl  AbCdEfGhIjKL  aBcDeFgHhIjKl ABcDeFgHiJkL
    aBcDeFGhIjKl  AbCdEeFgHiJKl AbCdEfGhIjKl  ABcDeFgHiJkL  aBbCdEFgHiJkL
    aBcDeFgHiJKl  AbCdEfGhIjJkL AbCdEfGhIjKl  AbCdEFgHiJkL  aBcDeFfGhIJkL
    aBcDeFgHiJkL  AbCdEfGhIjKl  AbCcDEfGhIjKl AbCdEfGhIJkL  aBcDeFgHiJkLL
    aBcDeFgHiJkL  aBcDEfGhIjKl  AbCdEfGhIIjKl AbCdEfGhIjKl  ABcDeFgHiJkL
    aBcDEeFgHiJkL aBcDeFgHIjKl  AbCdEfGhIjKl  ABbCdEfGhIjKl AbCDeFgHiJkL
    aBcDeFgHIjKkL aBcDeFgHiJkL  AbCdEfGhIjKl  AbCDeFgGhIjKl AbCdEfGHiJkL
    aBcDeFgHiJkL  AbCcDeFgHiJkL aBCdEfGhIjKl  AbCdEfGHiJkLl AbCdEfGhIjKL
    aBcDeFgHiJkL  aBCdEfGhIiJkL aBcDeFGhIjKl  AbCdEfGhIjKL  aBcDeEfGhIjKl
    ABcDeFgHiJkL  aBcDeFGhIjKl  AaBcDeFgHiJKl AbCdEfGhIjKl  ABcDeFgHiJjKl
    AbCdEFgHiJkL  aBcDeFgHiJKl  AbCdEfGgHiJkL AbCdEfGhIjKl  AbCdEFgHiJkL
    aBcDdEfGhIJkL aBcDeFgHiJkL  AbCdEfGhIjKlL aBcDEfGhIjKl  AbCdEfGhIJkL
    aBcDeFgHhIjKL aBcDeFgHiJkL  aBcDEfGhIjKl  AbCdEeFgHIjKl AbCdEfGhIjKL
    aBcDeFgHiJkL  aBbCDeFgHiJkL aBcDeFgHIjKl  AbCdEfGhIjJKl AbCdEfGhIjKl
    AbCDeFgHiJkL  aBcDeFfGHiJkL aBcDeFgHiJKl  AbCdEfGhIjKl  AbCDdEfGhIjKl
    AbCdEfGHiJkL  aBcDeFgHiJKlL aBcDeFgHiJkL  aBCdEfGhIjKl  AbCdEfGHhIjKl
    AbCdEfGhIJkL  aBcDeFgHiJkL  aBCdEeFgHiJkL aBcDeFGhIjKl  AbCdEfGhIjKL
    aBbCdEfGhIjKl ABcDeFgHiJkL  aBcDeFGhIjKkL aBcDeFgHiJKl  AbCdEfGhIjKl
    ABcDeFgGhIjKl AbCdEFgHiJkL  aBcDeFgHiJKl  AbCcDeFgHiJkL AbCdEfGhIjKl
    AbCdEFgHiJkLl AbCdEfGhIJkL  aBcDeFgHiJkL  AbCdEfGhIiJkL aBcDEfGhIjKl
    AbCdEfGhIJkL  aBcDeEfGhIjKL aBcDeFgHiJkL  aBcDEfGhIjKl  AaBcDeFgHIjKl
    AbCdEfGhIjKL  aBcDeFgHiJjKl AbCDeFgHiJkL  aBcDeFgHIjKl  AbCdEfGgHiJKl
    AbCdEfGhIjKl  AbCDeFgHiJkL  aBcCdEfGHiJkL aBcDeFgHiJKl  AbCdEfGhIjKkL
    aBCdEfGhIjKl  AbCdEfGHiJkL  aBcDeFgHhIJkL aBcDeFgHiJkL  aBCdEfGhIjKl
    AbCdEeFGhIjKl AbCdEfGhIJkL  aBcDeFgHiJkL  aBBcDeFgHiJkL aBcDeFGhIjKl
    AbCdEfGhIJjKl AbCdEfGhIjKl  ABcDeFgHiJkL  aBcDeFGgHiJkL aBcDeFgHIjKl
    AbCdEfGhIjKl  ABcDdEfGhIjKl AbCdEFgHiJkL  aBcDeFgHIjKlL aBcDeFgHiJkL
    AbCdEfGhIjKl  AbCdEFgHhIjKl AbCdEfGHiJkL  aBcDeFgHiJkL  AbCdEeFgHiJkL
    aBcDEfGhIjKl  AbCdEfGHiJkL  aBbCdEfGhIjKL aBcDeFgHiJkL  aBcDEfGhIjKkL
    aBcDeFgHIjKl  AbCdEfGhIjKL  aBcDeFgGhIjKl AbCDeFgHiJkL  aBcDeFgHIjKl
    AbCcDeFgHiJKl AbCdEfGhIjKl  AbCDeFgHiJkLl AbCdEfGHiJkL  aBcDeFgHiJKl
    AbCdEfGhIiJkL aBCdEfGhIjKl  AbCdEfGHiJkL  aBcDeEfGhIJkL aBcDeFgHiJkL
    aBCdEfGhIjKl  AaBcDeFGhIjKl AbCdEfGhIJkL  aBcDeFgHiJjKl ABcDeFgHiJkL
    aBcDeFGhIjKl  AbCdEfGgHIjKl AbCdEfGhIjKl  ABcDeFgHiJkL  aBcCdEFgHiJkL
    aBcDeFgHIjKl  AbCdEfGhIjKkL AbCdEfGhIjKl  AbCdEFgHiJkL  aBcDeFgHIiJkL
    aBcDeFgHiJkL  AbCdEfGhIjKl  AbCdEFfGhIjKl AbCdEfGHiJkL  aBcDeFgHiJkL
    AbBcDeFgHiJkL aBcDEfGhIjKl  AbCdEfGHiJjKl AbCdEfGhIjKL  aBcDeFgHiJkL
    aBcDEfGgHiJkL aBcDeFGhIjKl  AbCdEfGhIjKL  aBcDdEfGhIjKl AbCDeFgHiJkL
    aBcDeFGhIjKlL aBcDeFgHiJKl  AbCdEfGhIjKl  AbCDeFgHhIjKl AbCdEFgHiJkL
    aBcDeFgHiJKl  AbCdEeFgHijKL aBCdEfGhIjKl  AbCdEFgHiJkL  aBbCdEfGhIJkL
    aBcDeFgHiJKl  aBcDEfgHIjKLl AbcDeFgHIjKL  aBcdEfgHIjKL  AbCdeFggHiJKL
    aBCdeFghIjKL  aBCdEfGhIjkL  AbCdDEfGhIjkL aBCdEfGHiJkL  abCdEfGHiJKl
    AabCdEfGHiJKl AbcDefGHiJKL  aBcdEfgHhIJKl ABcdEfgHiJKl  ABcDeFghIjKl
    ABCdEfFgHijKl ABcDEfGhIjkL  aBcDEfGhIJkL  abBcDeFGhIJkL abCdEfGhIJKl
    AbcDefGhIJKkL AbcDefGhIJkL  ABcdEfgHiJkL  ABcDeFggHiJkL AbCDeFghIjKl
    AbCDeFgHIjkL  aBcDdEFgHIjKl aBcDeFgHIjKL  abCdeFgHIJkL  AabCdeFgHIjKL
    AbcDefGHijKL  AbCdEfgHiIjKL aBCdEfgHiJkL  AbCdEFghIjKl  AbCDeFfGhIjKl
    AbCdEfGHiJkL  aBcdEFgHIjKL  aBccdEfGHiJKl AbCdeFgHiJKL  aBcDefGhIjKKl
    ABcDefGhIjKl  ABCdEfgHiJkL  aBCdEfGgHiJkL aBcDEfGhIjKl  AbCdEfGHiJkL
    aBccDeFGhIJkL aBcdEfGhIJKl  AbCdeFgHiJKL  aAbCdeFghIJkL ABcDefGhiJKl
    ABcDEfgHiIjKl AbCDeFgHiJkL  aBcDeFGhIjKl  AbcDEeFgHIjKl AbcDeFgHIJkL
    aBcdEfGhIJkL  AbCcdEfgHIjKL AbCdeFghIJkL  ABcDefGhiJjKL AbCdEfGhiJkL
    AbCDeFgHiJkL  aBcDeFGhHiJkL abCdEFgHIjKl  AbcDeFgHIjKL  aBcdDefGHiJKL
    aBcdEfGhIjKl  ABCdeFghIjKLl ABCdeFghIjKL  aBCdEfGhiJkL  aBCdEFgHiJjkL
    aBCdEfGHiJkL  abCdEfGHiJKl  AbcDeFfGhIJKl AbcDefGhIJKL  aBcdEfgHiJKL
    aBCcdEfgHiJKl ABcDeFghIjKL  aBcDEfGhIjkKL aBcDeFGhIjkL  aBcDEfGHiJkL
    abCdEfGHhIJkL aBcdEfgHIJkL  AbCDefghIJKl  ABcDeefGhIJKL aBcdEfgHiJKL
    aBcDeFghIjKl  AAbCDeFghIjKl ABcDeFGhIjkL  aBcDeFGhIiJKl aBcDeFgHIJkL
    abCdEfgHIjKL  AbCdeeFgHiJKL aBcDefGhIjKL  AbCdEfgHiJkL  ABcCdEfGhiJkL
    aBCDeFghIjKl  ABcdEFgHIjKkl AbCdEfGHiJkL  aBcdEfGHiJKL  abCdeFgGHiJKL
    abCdeFgHiJKL  aBcDefGhIjKL  AbCdEefGhiJKL aBCdEfgHiJkL  aBCdEfGhIjKl
    AaBcDeFGhIjKl AbcDEfGHiJkL  aBcdEfGHiJJkL aBcdEfGhIJKl  AbCdeFghIJKL
    aBcDefFghIJKL aBcDefGhIjKl  ABcDEfgHijKL  aBbCDeFgHiJkL aBcDeFGhIJkl
    AbcDeFGhIJkLl AbcDeFgHIJkL  aBcdEfGhIJkL  AbCdeFggHIjKL AbCdeFghIjKL
    AbCDefGhiJKl  AbCDdEfGhIjkL AbCDeFgHiJkL  aBcDeFgHIjKl  AAbcdEFgHIjKl
    AbcDeFgHIjKL  AbcdEfgHIiJKL aBcdEfgHIjKL  aBCdeFghIjKL  AbCdEfGghIjKl
    ABCdEfGhiJkL  aBCdEfGHiJkL  AbccDEfGHiJkL abCdEfGHiJKl  AbcDEfgHiJKLl
    AbcDefGHiJKL  AbcdEfgHiJKL  aBCdeFggHiJKl ABcDeFghIjKL  aBcDEfGhiJkL
    aBcDEeFGhIjkL aBcDeFGhIJkL  abCdEfGHiJKl  AabCdeFGhIJKl AbcDefGhIJKl
    ABcdEfgHiIJkL ABcdEfgHiJKl  ABcDeFghIjKl  ABcDEfGgHijKl AbCDeFgHIjKl
    aBcDeFGhIJkL  abCcDeFgHIJkL abCdeFgHIJkL  AbcDefGhIJkLL AbcDefGhIjKL
    AbCdEfgHiJkL  AbCDeFghHiJkL aBCdEFghIjKl  AbCdEFgHiJKL  abcDdEfGHiJKl
    aBcdEfGHIjKL  abCdeFgHIjKL  AbbCdeFgHiJKL aBcDefGhIjKL  AbCdEfgHiJJkL
    aBCdEfgHiJkL  AbCdEFgHijKl  AbCDeFfGhIJkl AbCdEfGHiJKl  AbcDeFgHIjKL
    aBccdEfGHiJKL aBcdeFgHiJKL  aBCdefGhIjKLl ABcDeFghIjKL  aBCdEfGhiJkL
    aBCdEfGhHiJkL aBcDEfGhIjKL  abCdEfGHiJKL  abcDdeFGhIJkL AbcdEfGhIJKl
    ABcdeFgHiJKl  ABbCdeFgHiJkL ABcDefGhIjKl  ABcDEfgHiJjKl AbCDeFgHiJkL
    aBcDeFGhIjKl  AbCdEfGgHIjKl AbCdeFgHIJkL  aBcdEfGhIJkL  AbCcDefGhIjKL
    AbCdEfghIJkL  ABcDefGhIjKkL AbCdEfGhIjKl  AbCdEFgHiJkL  aBcDeFgHIiJkl
    ABcdEfGHIjKL  abCdeFgHIjKL  aBcDeeFgHiJKL aBcdEfgHIjKL  AbCdEfghIjKL
    AaBCdeFgHijKL aBCdEfGhIjKl  AbCdEFgHiJjKl AbCdEfGHiJkL  abCdEfGHiJKl
    AbCdeFfGhIJKl AbCdefGHiJKL  aBcDefgHiJKL  aBCcDefgHiJKl ABcDeFgHijKL
    aBcDEfGhIjkLl ABcDeFGhIjKl  aBcDeFGhIJkL  abCdEfGhHIJkL aBcdEfGhIJKl
    AbCdefGhIJKl  ABcDeefGhIJkL ABcdEfgHiJkL  ABcDeFgHijKl  ABbCDeFgHijKl
    AbCDeFgHIjKl  aBcDeFGhIJjKl aBcDeFgHIjKL  aBcdeFgHIJkL  AbCdefFgHIjKL
    AbCdefGhIjKL  AbCdEfgHiJkL  AbCDdEfgHiJkL aBCdEFghIjKl  AbCdEFgHiJKll
    AbCdEfGHiJKl  aBcDefGHIjKL  aBcdeFgHHiJKL aBcdeFgHiJKL  aBcDefGhIjKL
    aBCdEefGhIjKl ABCdEfgHiJkL  aBCdEfGhIjKl  AaBcDEfGhIjKl AbCdEfGHiJkL
    aBcdEfGHiJKkl ABcdEfGhIJkl  ABCdeFgHiJKl  ABcDefGgHiJkL ABcDefGhIjKl
    ABcDEfgHiJkL  aBcCDeFgHijKL aBcDeFGhIjKl  AbCdeFGhIJkLl AbcDeFgHIJkL
    aBcdEfGhIJkL  AbCdeFggHIjKL AbCdeFghIJkL  AbCDefGhiJKl  AbCDeEfGhIjKl
    AbCDeFgHiJkL  aBcDeFgHIjKl  AabCdEfGHIjKl AbcDeFgHIjKL  aBcdEfgHIiJKL
    aBcdEfgHIjKL  AbCdeFghIjKL  AbCdEfGghIjKL aBCdEfGhIjkL  AbCdEFgHiJkL
    abCcDEfGHiJkL abCdEfGHiJKl  AbcDeFgHiJKLl AbcDefGhIJKl  ABcdEfgHiJKL
    aBCdeFghHiJKl ABcDeFghIjKL  aBcDEfGhIjkL  aBCdEeFGhIjKl aBcDeFGhIJkL
    abCdEfGhIJKl  AbbCdeFGhIJKl AbcDefGhIJKl  ABcdEfgHiJJkL AbCdEfghIJkL
    ABcDeFghIjKl  ABcDEfGghIjKl AbCDeFgHIjKl  aBcDeFGhIJkL  abCcDeFgHIjKL
    abCdeFgHIJkL  AbcDefGhIJkLL aBcDefGhIjKL  AbCdEfgHiJkL  AbCDeFghHiJkL
    aBCdEfGhIjKl  AbCdEFgHiJkL  aBcDeEfGHiJKl aBcdEfGHIjKL  abCdeFgHIjKL
    AbbCdeFgHiJKL aBcDefGhIjKL  aBCdEfgHiJjKl ABcDeFgHiJkL  aBCdEfGhIjKl
    AbCdEfGGhIjKl AbcDeFGHiJkL  aBcdEfGHiJKl  AbCcdEfGhIJKl AbCdeFgHiJKl
    ABcDefGhiJKLl ABcDefGhiJKl  ABcDeFgHiJkL  aBcDEfGhIiJkL aBcDeFGhIjKl
    AbcDeFGhIJkL  aBcdEeFgHIJkL aBcdEfGhIJkL  AbCdeFghIJkL  ABbCdeFghIJkL
    AbCDefGhiJKl  AbCDeFgHiJjKl AbCdEFgHiJkL  abCDeFgHIjKl  AbcDeFfGHIjKl
    AbcDeFgHIjKL  aBcdEfgHIjKL  AbCddEfgHIjKL AbCdeFghIjKL  AbCdEfGhiJkLL
    aBCdEfGhIjkL  AbCdEFgHiJkL  abCdEFgHIiJkL abCdEfGHiJKl  AbcDeFgHiJKL
    aBcdEefGHiJKL aBcdEfgHiJKL  aBCdeFghIjKL  aBBcDeFghIjKL aBcDEfGhIjkL
    aBCdEfGHiJjKl aBcDeFGhIJkL  abCdEfGhIJKl  AbcDefFGhIJKl AbcDefGhIJKl
    ABcdEfgHiJKl  ABCddEfgHiJkL ABcDeFghIjKl  ABcDeFGhiJkLl AbCDeFgHIjKl
    aBcDeFGhIjKL  abCdEfGhIIjKL abCdeFgHIJkL  AbcDefGhIJkL  AbCdEefGhIjKL
    AbCdEfgHiJkL  AbCDeFghIjKl  AaBCdEfGhIjKl AbCdEFgHiJkL  aBcDeFgHIjjKL
    aBcdEfGHIjKL  abCdeFgHIjKL  aBcDefGgHiJKL aBcDefGhIjKL  aBCdEfgHiJkL
    aBCcDEfgHiJkL aBCdEfGhIjKl  AbCdEfGHiJkLl AbCdEfGHiJkL  aBcdEfGHiJKl
    AbCdeFgHhIJKl AbCdeFgHiJKl  ABcDefGhIjKl  ABCdEefGhiJKl ABcDeFgHiJkL
    aBcDEfGhIjKl  AaBcDeFGhIjKl AbcDeFGhIJkL  aBcdEfGhIJjKL aBcdEfGhIJkL
    AbCdeFghIJkL  ABcDefGghIJkL AbCDefGhiJKl  AbCDeFgHiJkL  aBcDdEFgHiJkL
    abCDeFgHIjKl  AbcDeFgHIJkLl AbcDeFgHIjKL  aBcdEfgHIjKL  AbCdeFghHiJKL
    aBCdeFghIjKL  AbCDefGhiJkL  AbCDeFfGhIjkL aBCdEfGHiJkL  abCdEFgHIjKl
    AbbCdEfGHiJKl AbcDefGHiJKL  aBcdEfgHiJJKl ABcdEfgHiJKL  aBCdeFghIjKL
    aBCdEfGghIjKl ABcDEfGhiJkL  aBcDEfGhIJkl  AbCcDeFGhIJkl AbCdEfGhIJKl
    AbcDefGhIJKl  AAbcDefGhIJKl ABcdEfgHiJKl  ABcDeFghIiJkL ABcDeFghIjKl
    ABcDeFGhiJkL  aBcDEeFgHiJkL aBcDeFGhIjKL  abCdeFGhIJkL  AbbCdeFgHIJkL
    AbcDefGhIJkL  AbCdEfgHiJjKL AbCdEfgHiJkL  AbCDeFghIjKl  AbCDeFgGhIjKl
    AbCdEFgHiJkL  aBcDeFgHIjKL  abCcdEfGHIjKL abCdeFgHiJKL  aBcDefGhIjKL
    AaBcDefGhIjKL aBCdEfgHiJkL  aBCdEfGhIiJkL aBcDEfGhIjKl  AbCdEfGHiJkL
    aBcdEeFGHiJkL aBcdEfGHiJKl  AbCdeFgHiJKL  aBbCdeFghIJKl ABcDefGhiJKl
    ABCdEfgHijJKl ABcDeFgHiJkL  aBcDEfGhIjKl  AbCdEfGgHIjKl AbcDeFGhIJkL
    aBcdEfGhIJKl  AbCddEfgHIJkL AbCdeFghIJkL  ABcDefGhiJKlL AbCdEfGhiJkL
    AbCDeFgHiJkl  ABcDeFGhIiJkl AbCdEFgHIjKl  AbcDeFgHIJkL  aBcdEeFgHIjKL
    aBcdEfgHIjKL  AbCdeFghIjKL  AbBCdeFghIjKL aBCdEfGhiJkL  AbCDeFgHijJkL
    aBCdEfGHiJkl  AbCdEFgHiJKl  AbcDeFfGHiJKl AbcDefGHiJKL  aBcdEfgHiJKL
    aBCddEfgHiJKL aBcDeFghIjKL  aBCdEfGhiJkLl ABcDEfGhiJkL  aBcDEfGhIJkl
    AbCdEfGHiIjKl AbCdEfGhIJKl  AbcDefGhIJKl  ABcdEefGhIJKl ABcdEfgHiJKl
    ABcDeFghIjKl  ABbCDeFghIjKl ABcDeFgHiJkL  aBcDeFGhIjjKL aBcDeFgHIjKL
    abCdeFGhIJkL  AbcDefGgHIJkL AbcDefGhIjKL  AbCdEfgHiJkL  ABcDdEfgHiJkL
    AbCDefGhIjKl  AbCDeFgHiJkLl AbCdEFgHiJkL  aBcDeFgHIjKl  AbCdeFgHIiJKl
    AbCdeFgHiJKL  aBcDefGhIjKL  AbCdEffGhIjKL aBCdEfgHiJkL  aBCdEfGhIjKl
    AbBcDEfGhIjKl AbCdEfGHiJkL  aBcdEfGHiJjKL aBcdEfGHiJKl  AbCdeFgHiJKL
    aBcDefGghIJKl ABcDefgHiJKl  ABCdeFgHijKL  aBCdDeFgHiJkL aBcDEfGhIjKl
    AbcDEfGHiJkLl AbcDeFGhIJkL  aBcdEfGhIJKl  AbCdeFghHIJkL AbCdefGhIJkL
    ABcDefGhiJKl  ABcDeFfGhiJkL AbCDeFgHijKl  ABcDeFGhIjKl  aBbCdEFgHIjKl
    AbcDeFgHIJkL  aBcdEfgHIJjKL aBcdeFgHIjKL  AbCdefGhIjKL  AbCDefGghIjKL
    aBCdEfGhiJkL  AbCDeFgHijKl  AbCDdEfGHiJkl AbCdEfGHiJKl  AbcDeFgHIjKL
    aAbcDefGHiJKL aBcdeFgHiJKL  aBCdeFghIiJKL aBcDeFghIjKL  aBCdEfGhiJkL
    aBCdEFfGhiJkL aBcDEfGhIJkl  AbCdEfGHiJKl  AbbCdeFGhIJKl AbcDefGhIJKl
    ABcdEfgHiJjKL AbCdEfgHiJKl  ABcDeFghIjKl  ABcDEfGghIjKl ABcDeFgHiJkL
    aBcDeFGhIjKl  AbCcDeFgHIjKl AbCdeFgHIJkL  AbcDefGhIJKl  AaBcDefGhIjKL
    AbCdEfgHiJkL  ABcDeFghIiJkL AbCDefGhIjKl  AbCDeFgHiJkL  aBcDeFFgHiJkL
    aBcdEFgHIjKl  AbCdeFgHIjKL  aBbCdeFgHiJKL aBcDefGhIjKL  AbCdEfghIjJKL
    aBCdeFgHijKL  aBCdEfGhIjKl  AbCdEFggHIjKl AbCdEfGHiJkL  aBcdEfGHiJKl
    AbCddEfGhIJKl AbCdeFgHiJKL  aBcDefgHiJKLl ABcDefgHiJKl  ABcDeFgHijKL
    aBCdEfGhIijKL aBcDeFGhIjKl  aBcDEfGhIJkL  aBcdEeFGhIJkL aBcdEfGhIJKl
    AbCdefGhIJKl  ABcCdefGhIJkL ABcDefgHiJKl  ABcDeFgHijjKL AbCDeFgHijKl
    ABcDeFGhIjKl  aBcDeFGgHIjKl aBcDeFgHIJkL  aBcdEfgHIJkL  AbCddeFgHIjKL
    AbCdefGhIjKL  AbCdEfgHiJkL  AaBCdEfGhiJkL AbCdEFgHijKl  AbCDeFgHIijKl
    AbCdEfGHiJKl  aBcDeFgHIjKL  aBcdeEfGHiJKL aBcdeFgHiJKL  aBCdefGhIjKL
    AbCcDefGhIjKL aBCdEfGhiJkL  aBCdEfGhIjjKL aBcDEfGhIjKl  AbCdEfGHiJKl
    aBcDefGGhIJKl AbcdEfGhIJKl  ABcdeFgHiJKL  aBcDdeFgHiJKl ABcDefGhIjKl
    ABcDEfgHiJkLl AbCDeFgHiJkL  aBcDeFGhIjKl  AbCdEfGhIJjKl AbCdeFgHIJkL
    AbcdEfGhIJKl  AbCdeFfGhIjKL AbCdEfghIJkL  ABcDefGhIjKl  ABbCdEfGhIjKl
    AbCDeFgHiJkL  aBcDeFGhIjjKL aBcdEFgHIjKl  AbcDeFgHIjKL  aBcDefGgHiJKL
    aBcDefgHIjKL  AbCdEfghIjKL  AbCDdeFgHijKL aBCdEfGhIjKl  AbCdEFgHiJkLl
    AbCdEfGHiJkL  abCdEfGHiJKl  AbcDeFgHhIjKL AbCdefGHiJKL  aBcDefgHiJKL
    aBCdeFfgHiJKl ABcDeFgHijKL  aBCdEfGhIjkL  aBCcDeFGhIjKl aBcDeFGhIJkL
    abCdEfGHijjKL AbCdEfGhIJKl  AbCdefGhIJKl  ABcDefgGhIJkL ABcdEfgHiJKl
    ABcDeFghIjKl  ABcDEeFgHijKl AbCDeFgHIjKl  aBcDeFGhIJkL  aaBcDeFgHIjKL
    aBcdeFgHIJkL  AbCdefGhIIjKL AbCdefGhIjKL  AbCdEfgHiJkL  AbCDeFfgHiJkL
    AbCdEFgHijKl  AbCdEFgHiJKl  aBbCdEfGHiJKl aBcDeFgHIjKL  aBcdeFgHIjjKL
    AbCdeFgHiJKL  aBcDefGhIjKL  AbCdEfggHIjKL aBCdEfgHiJkL  aBCdEfGhIjKl
    AbCdDEfGhIjKl AbCdEfGHiJKl  aBcdEfGHiJKl  ABbcdEfGhIJKl AbCdeFgHiJKL
    aBcDefGhIiJKl ABcDefGhIjKl  ABcDEfgHiJkL  aBcDEfFgHiJkL aBcDeFGhIjKl
    AbCdeFGhIJkL  aBbcDeFgHIJkL aBcdEfGhIJKl  AbCdeFghIJjKL AbCdeFghIJkL
    ABcDefGhiJKl  ABcDeFggHIjKl AbCDeFgHiJkL  aBcDeFgHIjKl  AbcDdEFgHIjKl
    AbcDeFgHIjKL  aBcdEfGhIjKL  AaBcdEfgHIjKL AbCdeFghIjKL  AbCDefGhiIjKL
    aBCdEfGhIjkL  AbCdEFgHiJkL  abCdEFfGHiJkL abCdEfGHiJKl  AbcDeFgHiJKL
    aBccDefGHiJKL aBcdEfgHiJKL  aBCdeFghIjjKL AbCDeFghIjKL  aBCdEfGhIjkL
    aBCdEfGgHIjKl aBcDeFGhIJkL  abCdEfGHiJKl  AbcDdeFGhIJKl AbcDefGhIJKl
    ABcdEfgHiJKl  AAbCdEfgHiJkL ABcDeFghIjKl  ABcDEfGhIijKl AbCDeFgHIjKl
    aBcDeFGhIJkL  abCdEeFgHIjKL abCdeFgHIJkL  AbCdefGhIJkL  ABccDefGhIjKL
    AbCdEfgHiJkL  AbCDeFghIjjKL aBCdEfGhIjKl  AbCdEFgHiJkL  aBcDeFggHIJkL
    aBcDefGHIjKL  abCdeFgHIjKL  AbcDdeFgHiJKL aBcDefGhIjKL  aBCdEfgHiJkL
    AaBCdEfgHiJkL aBCdEfGhIjKl  AbCdEFgHiJjKl AbCdEfGHiJkL  aBcdEfGHiJKl
    AbCdeFfGhIJKl AbCdeFgHiJKL  aBcDefGhIjKL  aBCcDefGhIjKl ABcDeFgHiJkL
    aBcDEfGhIjjKL aBcDeFGhIjKl  AbcDeFGhIJkL  aBcdEfGgHIJkL aBcdEfGhIJKl
    AbCdeFghIJkL  ABcDeeFghIJkL AbCDefGhiJKl  ABcDeFgHiJkL  aAbCdEFgHiJkL
    aBcDeFgHIjKl  AbcDeFgHIJjKl AbcDeFgHIjKL  aBcdEfgHIjKL  AbCdeFfgHIjKL
    AbCdeFghIjKL  AbCdEfGhiJkL  AbCCdEfGhIjkL AbCdEFgHiJkL  abCdEFgHIjKkL
    abCdEfGHiJKl  AbcDeFgHiJKL  aBcdEfgGhIJKl ABcdEfgHiJKL  aBCdeFghIjKL
    aBCdEeFghIjKL aBcDEfGhIjkL  aBCdEfGHiJkL  aaBcDeFGhIJkL abCdEfGhIJKl
    AbcDefGHiIjKL AbcDefGhIJKl  ABcdEfgHiJKl  ABcDeFfgHiJkL ABcDeFghIjKl
    ABcDEfGhiJkL  aBbCDeFgHIjKl aBcDeFGhIJkL  abCdEfGhIjjKL AbCdeFgHIJkL
    AbcDefGhIJkL  ABcdEfgHhIjKL AbCdEfgHiJkL  AbCDeFghIjKl  AbCDdEfGhIjKl
    AbCdEFgHiJkL  aBcDeFgHIjKL  aaBcdEfGHIjKL abCdeFgHIjKL  AbcDefGhIiJKL
    aBcDefGhIjKL  aBCdEfgHiJkL  aBCDeFfgHiJkL aBCdEfGhIjKl  AbCdEfGHiJkL
    aBbCdEfGHiJkL aBcdEfGHiJKl  AbCdeFgHiJjKL AbCdeFgHiJKL  aBcDefGhiJKl
    ABCdEfgHhiJKl ABcDeFgHiJkL  aBcDEFghIjKl  AbCdEeFGhIjKl AbcDeFGhIJkL
    aBcdEfGhIJKl  AaBcdEfGhIJkL AbCdeFghIJkL  ABcDefGhiIjKL AbCDefGhiJKl
    AbCDeFgHiJkL  aBcDeFGgHiJkL abCDeFgHIjKl  AbcDeFgHIJkL  aBccDeFgHIjKL
    aBcdEfgHIjKL  AbCdeFghIJkKL AbCdeFghIjKL  AbCdEfGhiJkL  AbCDeFgHhIjkL
    AbCdEFgHiJkL  abCdEFgHIjKl  AbcDdEfGHiJKl AbcDefGHiJKL  aBcdEfgHiJKL
    AbBcdEfgHiJKL aBCdeFghIjKL  aBCdEfGhiJjKl ABcDEfGhiJkL  aBCdEfGHiJkl
    AbCdEfFGhIJkL abCdEfGhIJKl  AbcDefGHiJKL  aBccDefGhIJKl ABcdEfgHiJKl
    ABcDeFghIjKkL ABcDeFghIjKl  ABcDeFGhiJkL  aBcDEfGhHiJkL aBcDeFGhIjKL
    abCdeFGhIJkL  AbcDdeFgHIJkL AbcDefGhIJkL  AbCdEfgHiJkL  ABbCdEfgHiJkL
    AbCDeFghIjKl  AbCDeFgHiJjKl AbCdEFgHiJkL  aBcDeFgHIjKL  abCdeFfGHIjKL
    abCdeFgHIjKL  aBcDefGhIjKL  AbCcDefGhIjKL aBCdEfgHiJkL  aBCdEfGhIjKkL
    aBCdEfGhIjKl  AbCdEfGHiJkL  aBcdEFgHIiJkL aBcdEfGHiJKl  AbCdeFgHiJKL
    aBcDeeFgHiJKl ABcDefGhiJKl  ABCdEfgHijKL  aABcDeFgHiJkL aBcDEfGhIjKl
    AbCdEfGHiJjKl AbcDeFGhIJkL  aBcdEfGhIJKl  AbCdeFfGhIJkL AbCdeFghIJkL
    ABcDefGhiJKl  ABcCdEfGhiJKl AbCDeFgHiJkl  ABcDeFGhIjKkL abCdEFgHIjKl
    AbcDeFgHIJkL  aBcdEfGgHIjKL aBcdEfgHIjKL  AbCdeFghIjKL  AbCDeeFghIjKL
    AbCdEfGhiJkL  AbCDeFgHijKl  AaBCdEfGHiJkl AbCdEFgHIjKl  AbcDeFgHIjjKL
    AbcDefGHiJKL  aBcdEfgHiJKL  AbCdeFfgHiJKL aBcDeFghIjKL  aBCdEfGhiJkL
    aBCcDEfGhiJkL aBcDEfGhIJkl  AbCdEfGHiJKlL abCdEfGhIJKl  AbcDefGhIJKL
    aBcdEfgHhIJKl ABcdEfgHiJKl  ABcDeFghIjKl  ABCdEeFghIjKl ABcDeFgHiJkL
    aBcDEfGhIjKl  AaBcDeFGhIjKL abCdeFGhIJkL  AbcDefGhIJKkL AbcDefGhIJkL
    AbCdEfgHiJkL  ABcDeFggHiJkL AbCDeFghIjKl  AbCDeFgHiJkL  aBcCdEFgHiJkL
    aBcDeFgHIjKl  AbCdeFgHIJkL  AabCdeFgHIjKL aBcDefGhIjKL  AbCdEfgHhIjKL
    aBCdEfgHiJkL  aBCdEfGhIjKl  AbCdEEfGhIjKl AbCdEfGHiJkL  aBcdEfGHIjKl
    AaBcdEfGHiJKl AbCdeFgHiJKL  aBcDefGhiIJKl ABcDefGhiJKl  ABCdeFgHijKL
    aBCdEfGgHiJkL aBcDEfGhIjKl  AbCdEfGHiJkL  aBccDeFGhIJkL aBcdEfGhIJKl
    AbCdeFghIJKkL AbCdefGhIJkL  ABcDefGhiJKl  ABcDeFgHhiJkL AbCDeFgHijKl
    ABcDeFGhIjKl  aBcDdEFgHIjKl AbcDeFgHIJkL  aBcdEfGhIJkL  AbBcdeFgHIjKL
    AbCdefGhIjKL  AbCDefGhiJjKL AbCdEfGhiJkL  AbCDeFgHijKl  AbCDeFfGHiJkl
    AbCdEFgHiJKl  AbcDeFgHIjKL  aBccDefGHiJKL aBcdeFgHiJKL  aBCdeFghIjKLL
    aBcDeFghIjKL  aBCdEfGhiJkL  aBCdEFgHhiJkL aBcDEfGhIJkl  AbCdEfGHiJKl
    AbcDdeFGhIJKl AbcDefGhIJKl  ABcdEfgHiJKL  aBbCdEfgHiJKl ABcDeFghIjKl
    ABCdEfGhiJjKl ABcDeFgHiJkL  aBcDeFGhIjKl  AbCdEfGgHIjKL abCdeFGhIJkL
    AbcDefGhIJKl  ABccDefGhIJkL AbCdEfgHiJkL  ABcDeFghIjKkL AbCDefGhIjKl
    AbCDeFgHiJkL  aBcDeFGhIiJkL aBcdEFgHIjKl  AbCdeFgHIJkL  aBcDeeFgHIjKL
    aBcDefGhIjKL  AbCdEfghIJkL  AaBCdeFgHiJkL aBCdEfGhIjKl  AbCdEFgHiJjKl
    AbCdEfGHiJkL  aBcdEfGHiJKl  AbCdeFfGHiJKl AbCdeFgHiJKL  aBcDefgHiJKL
    aBCdDefgHiJKl ABCdeFgHijKL  aBCdEfGhIjkLL aBcDEfGhIjKl  AbcDEfGHiJkL
    aBcdEfGHhIJkL aBcdEfGhIJKl  AbCdefGhIJKl  ABcDeefGhIJkL ABcDefgHiJKl
    ABcDeFgHijKl  ABbCDeFgHijKl ABcDeFGhIjKl  aBcDeFGhIJjKl aBcDeFgHIJkL
    aBcdEfgHIJkL  AbCdefFgHIjKL AbCdefGhIjKL  AbCdEfgHiJkL  AbCDdEfGhiJkL
    AbCDeFgHijKl  AbCDeFgHIjKll AbCdEfGHiJKl  aBcDeFgHIjKL  aBcdeFgHHiJKL
    aBcdeFgHiJKL  aBCdefGhIjKL  AbCdEefGhIjKL aBCdEfGhiJkL  aBcDEfGhIjKl
    AbCcDeFGhIjKl AbcDeFGhIJkL  aBcdEfGhIJKl  AaBcdEfGhIJKl AbCdeFghIJkL
    ABcDefGhhIJkL AbCDefGhiJkL  ABcDeFgHijKl  ABcDEeFgHiJkl AbCDeFgHIjKl
    AbcDeFGhIJkL  aBbcDeFgHIjKL aBcdEfgHIjKL  AbCdeFghIiJKL AbCdeFghIjKL
    AbCdEfGhiJkL  AbCDeFgHhiJkL aBCdEFgHiJkl  AbCdEFgHIjKl  AbcDdEfGHiJKl
    AbcDefGHiJKL  aBcdEfgHiJKL  AaBcdEfgHiJKL aBCdeFghIjKL  aBCdEfGhhIjKl
    ABCdEfGhiJkL  aBCdEfGHiJkl  AbCdEeFGhIJkL abCdEfGHiJKl  AbcDefGHiJKL
    aBbcDefGhIJKl ABcdEfgHiJKl  ABcDeFghIjJkL ABcDeFghIjKl  ABcDEfGhiJkL
    aBcDEfGgHiJkL aBcDeFGhIjKl  AbCdeFGhIJkL  AbcDdeFgHIJkL AbcDefGhIJkL
    AbCdEfgHiJkL  AAbCdEfgHiJkL AbCDeFghIjKl  AbCDeFgHiIjKl AbCdEFgHiJkL
    aBcDeFgHIjKl  AbCdeEfGHIjKl AbCdeFgHIjKL  aBcDefGhIjKL  AbCcDefGhIjKL
    aBCdEfgHijKL  aBCDeFghIjKkL aBCdEfGhIjKl  AbCdEFgHiJkL  aBcdEFgGHiJkL
    aBcdEfGHiJKl  AbCdeFgHiJKL  aBcDdeFghIJKL aBcDefGhiJKl  ABCdEfgHijKLl
    ABcDeFgHijKL  aBcDEfGhIjKl  aBCdEfGHiJjKl AbcDeFGhIJkL  aBcdEfGhIJKl
    AbCdeFfGhIJkL AbCdeFghIJkL  ABcDefGhiJKl  ABbCDefGhiJkL ABcDeFgHijKl
    ABcDeFGhIjKkl AbCDeFgHIjKl  AbcDeFgHIJkL  aBcdEfGgHIjKL aBcdEfgHIjKL
    AbCdeFghIjKL  ABcDdeFghIjKL AbCdEfGhiJkL  AbCDeFgHijKlL aBCdEFgHiJkl
    AbCdEFgHIjKl  aBcDeFgHIiJKl AbcDefGHiJKL  aBcdEfgHiJKL  AbCdeFfgHiJKL
    aBcDeFghIjKL  aBCdEfGhiJkL  aBCcDEfGhiJkL aBCdEfGhIjKl  AbCdEfGHiJKll
    AbCdEfGhIJKl  AbcDefGhIJKl  ABcdEfgGhIJKl ABcdEfgHiJKl  ABcDeFghIjKl
    ABCdEeFghIjKl ABcDeFgHiJkL  aBcDEfGhIjKl  AaBcDeFGhIjKl AbCdeFGhIJkL
    aBcDefGhIJJkL AbcDefGhIJkL  AbCdEfgHiJkL  ABcDeFfgHiJkL AbCDeFghIjKl
    AbCDeFgHiJkL  aBbCdEFgHiJkL aBcDeFgHIjKl  AbCdeFgHIJkKl AbCdeFgHIjKL
    aBcDefGhIjKL  AbCdEfggHiJKL aBCdEfgHijKL  aBCDefGhIjkL  AbCDdEfGhIjKl
    AbCdEfGHiJkL  aBcdEfGHIjKl  AaBcdEfGHiJKl AbCdeFgHiJKL  aBcDefgHhIJKl
    ABcDefgHiJKl  ABCdEfgHijKL  aBCdEfFgHijKl ABcDEfGhIjKl  aBcDEfGHiJkL
    abBcDeFGhIJkL aBcdEfGhIJKl  AbCdefGhIJKkL AbCdefGhIJkL  ABcDefgHiJkL
    ABcDeFgHhiJkL AbCDeFgHijKl  ABcDeFGhIjkL  aBcDdEFgHIjKl aBcDeFgHIJkL
    aBcdEfGhIJkL  AaBcdeFgHIjKL AbCdefGhIjKL  ABcdEfgHhIjKL AbCdEfGhiJkL
    AbCDeFgHijKl  AbCDeFfGHijKl AbCdEFgHiJKl  aBcDeFgHIjKL  abCcDefGHiJKL
    aBcdeFgHiJKL  AbCdefGhIjKKL aBcDefGhIjKL  aBCdEfgHiJkL  aBCdEFggHiJkL
    aBcDEfGhIjKl  AbCdEfGHiJkL  aBcDdeFGhIJkL aBcdEfGhIJKl  ABcdeFgHiJKL
    aAbCdeFgHiJKl ABcDefGhIjKl  ABCdEfgHiIjKl ABcDeFgHiJkL  aBcDEfGhIjKl
    AbCdEeFGhIjKl AbCdeFGhIJkL  aBcdEfGhIJKl  AbCddEfGhIJkL AbCdeFgHiJkL
    ABcDefGhIjKl  ABbCDefGhIjKl AbCDeFgHiJkL  aBcDeFGgHiJkL aBcdEFgHIjKl
    AbcDeFgHIJkL  aBcdEeFgHIjKL aBcdEfgHIjKL  AbCdeFghIjKL  AbCCdeFghIjKL
    aBCdEfGhIjkL  AbCDeFgHhIjKl aBCdEfGHiJkL  abCdEfGHIjKl  AbcDeEfGHiJKl
    AbCdefGHiJKL  aBcDefgHiJKL  aBCddEfgHiJKl ABCdeFghIjKL  aBCdEfGhIjjKl
    ABcDEfGhIjkL  aBcDEfGHiJkL  abCdEfFGhIJkL abCdEfGhIJKl  AbCdefGhIJKl
    ABcDeefGhIJkL ABcdEfgHiJkL  ABcDeFghIjKl  ABcCDeFgHijKl ABcDeFGhIjkL
    aBcDeFGgHIjKl aBcDeFgHIJkL  abCdEfgHIJkL  AbCdeeFgHIjKL AbCdefGhIjKL
    AbCdEfgHiJkL  ABcDdEfgHiJkL AbCDeFghIjKl  AbCDeFgHiJkLl AbCdEFgHiJKl
    aBcDeFgHIjKL  abCdeFfGHiJKL abCdeFgHiJKL  aBcDefGhIjKL  AbCdEefGhIjKL
    aBCdEfgHiJkL  aBCdEFghIjKl  AbCcDEfGhIjKl AbCdEfGHiJkL  aBcdEfGHhIJkL
    aBcdEfGhIJKl  AbCdeFgHiJKL  aBcDeeFgHiJKl ABcDefGhIjKl  ABCdEfgHiJkL
    aBCdDeFgHiJkL aBcDEfGhIjKl  AbCdEfGhIJkL  aBbcDeFGhIJkL aBcdEfGhIJKl
    AbCdeFfgHIJkL AbCdeFghIJkL  ABcDefGhiJkL  ABcDEefGhIjkL AbCDeFgHiJkL
    aBcDeFGhIjKl  AbbCdEFgHIjKl AbcDeFgHIJkL  aBcdEfGgHIjKL aBcdEfgHIjKL
    AbCdeFghIjKL  AbCDeeFghIjKL aBCdEfGhIjkL  AbCdEFgHiJkl  AbCDdEfGHiJkL
    abCdEfGHiJKl  AbcDeFgHIjKL  aBbcDefGHiJKL aBcdEfgHiJKL  aBCdeFfgHiJKl
    ABCdeFghIjKl  ABCdEfGhiJkL  aBCdEEfGhIjkL aBcDEfGHiJkL  abCdEfGHiJKl
    AbcCdEfGhIJKl AbcDefGhIJKl  ABcdEfgGhIJkL ABcdEfgHiJkL  ABcDeFghIjKl
    ABcDEfFghIjKl AbCDeFGhIjkL  aBcDeFGhIJkL  abCdDeFgHIjKL abCdeFgHIJkL
    AbcDefGhIJkL  ABccDefGhIjKL])

(defsubst calendar-japanese-month-indicators (y-idx)
  "Month indicators of Y-IDX."
  (string-to-list
   (symbol-name (aref calendar-japanese-year-months y-idx))))

(defsubst calendar-japanese-months-days (month-indicators)
  "Number of Days of MONTH-INDICATORS."
  (mapcar (lambda (month-indicator) (if (< month-indicator 96) 30 29)) month-indicators))

(defvar calendar-japanese-absolute
  (let ((vector (make-vector (1+ (length calendar-japanese-year-months))
                             calendar-japanese-absolute-start)))
    (dotimes (i (length calendar-japanese-year-months))
      (aset vector (1+ i)
            (apply '+
                   (aref vector i)
                   (calendar-japanese-months-days
                    (calendar-japanese-month-indicators i)))))
    vector)
  "Absolute date of 1/1 of each year (since 454 A.D) in Japan.")

(defconst calendar-japanese-era
  '(("<安康>" (12 14 0454))
    ("<雄略>" (11 13 0457))
    ("<清寧>" (01 15 0480))
    ("<顕宗>" (01 01 0485))
    ("<仁賢>" (01 05 0488))
    ("<武烈>" (12 nil 0499))
    ("<継体>" (02 04 0507))
    ("<安閑>" (02 07 0534))
    ("<宣化>" (12 nil 0536))
    ("<欽明>" (12 05 0539))
    ("<敏達>" (04 03 0572))
    ("<用明>" (09 05 0585))
    ("<崇峻>" (08 02 0587))
    ("<推古>" (12 08 0592) (03 07 0628))
    ("<舒明>" (01 04 0629) (10 09 0641))
    ("<皇極>" (01 15 0642))
    ("大化" (06 19 0645))
    ("白雉" (02 15 0650))
    ("<斉明>" (01 03 0655))
    ("<天智>" (01 01 0662))
    ("<弘文>" (01 01 0672))
    ("<天武>" (02 27 0673))
    ("朱鳥" (07 20 0686))
    ("<持統>" (01 01 0687))
    ("<文武>" (08 01 0697))
    ("大宝" (03 21 0701))
    ("慶雲" (05 10 0704))
    ("和銅" (01 11 0708))
    ("霊亀" (09 02 0715))
    ("養老" (11 17 0717))
    ("神亀" (02 04 0724))
    ("天平" (08 05 0729))
    ("天平感宝" (04 14 0749))
    ("天平勝宝" (07 02 0749))
    ("天平宝字" (08 18 0757))
    ("天平神護" (01 07 0765))
    ("神護景雲" (08 16 0767))
    ("宝亀" (10 01 0770))
    ("天応" (01 01 0781))
    ("延暦" (10 22 0782))
    ("大同" (05 18 0806))
    ("弘仁" (09 19 0810))
    ("天長" (01 05 0824))
    ("承和" (01 03 0834))
    ("嘉祥" (06 13 0848))
    ("仁寿" (04 28 0851))
    ("斉衡" (11 30 0854))
    ("天安" (02 21 0857))
    ("貞観" (04 15 0859))
    ("元慶" (04 16 0877))
    ("仁和" (02 21 0885))
    ("寛平" (04 27 0889))
    ("昌泰" (04 26 0898))
    ("延喜" (07 15 0901))
    ("延長" ((04) 11 0923)) ; 唯一の閏月改元
    ("承平" (04 26 0931))
    ("天慶" (05 22 0938))
    ("天暦" (04 22 0947))
    ("天徳" (10 27 0957))
    ("応和" (02 16 0961))
    ("康保" (07 10 0964))
    ("安和" (08 13 0968))
    ("天禄" (03 25 0970))
    ("天延" (12 20 0973))
    ("貞元" (07 13 0976))
    ("天元" (11 29 0978))
    ("永観" (04 15 0983))
    ("寛和" (04 27 0985))
    ("永延" (04 05 0987))
    ("永祚" (08 08 0989))
    ("正暦" (11 07 0990))
    ("長徳" (02 22 0995))
    ("長保" (01 13 0999))
    ("寛弘" (07 20 1004))
    ("長和" (12 25 1012))
    ("寛仁" (04 23 1017))
    ("治安" (02 02 1021))
    ("万寿" (07 13 1024))
    ("長元" (07 25 1028))
    ("長暦" (04 21 1037))
    ("長久" (11 10 1040))
    ("寛徳" (11 24 1044))
    ("永承" (04 14 1046))
    ("天喜" (01 11 1053))
    ("康平" (08 29 1058))
    ("治暦" (08 02 1065))
    ("延久" (04 13 1069))
    ("承保" (08 23 1074))
    ("承暦" (11 17 1077))
    ("永保" (02 10 1081))
    ("応徳" (02 07 1084))
    ("寛治" (04 07 1087))
    ("嘉保" (12 15 1094))
    ("永長" (12 17 1096))
    ("承徳" (11 21 1097))
    ("康和" (08 28 1099))
    ("長治" (02 10 1104))
    ("嘉承" (04 09 1106))
    ("天仁" (08 03 1108))
    ("天永" (07 13 1110))
    ("永久" (07 13 1113))
    ("元永" (04 03 1118))
    ("保安" (04 10 1120))
    ("天治" (04 03 1124))
    ("大治" (01 22 1126))
    ("天承" (01 29 1131))
    ("長承" (08 11 1132))
    ("保延" (04 27 1135))
    ("永治" (07 10 1141))
    ("康治" (04 28 1142))
    ("天養" (02 23 1144))
    ("久安" (07 22 1145))
    ("仁平" (01 26 1151))
    ("久寿" (10 28 1154))
    ("保元" (04 27 1156))
    ("平治" (04 20 1159))
    ("永暦" (01 10 1160))
    ("応保" (09 04 1161))
    ("長寛" (03 29 1163))
    ("永万" (06 05 1165))
    ("仁安" (08 27 1166))
    ("嘉応" (04 08 1169))
    ("承安" (04 21 1171))
    ("安元" (07 28 1175))
    ("治承" (08 04 1177) (08 20 1183)) ; 源氏
    ("養和" (07 14 1181))
    ("寿永" (05 27 1182) (03 24 1185)) ; 平家
    ("元暦" (04 16 1184))
    ("文治" (08 14 1185))
    ("建久" (04 11 1190))
    ("正治" (04 27 1199))
    ("建仁" (02 13 1201))
    ("元久" (02 20 1204))
    ("建永" (04 27 1206))
    ("承元" (10 25 1207))
    ("建暦" (03 09 1211))
    ("建保" (12 06 1213))
    ("承久" (04 12 1219))
    ("貞応" (04 13 1222))
    ("元仁" (11 20 1224))
    ("嘉禄" (04 20 1225))
    ("安貞" (12 10 1227))
    ("寛喜" (03 05 1229))
    ("貞永" (04 02 1232))
    ("天福" (04 15 1233))
    ("文暦" (11 05 1234))
    ("嘉禎" (09 19 1235))
    ("暦仁" (11 23 1238))
    ("延応" (02 07 1239))
    ("仁治" (07 16 1240))
    ("寛元" (02 26 1243))
    ("宝治" (02 28 1247))
    ("建長" (03 18 1249))
    ("康元" (10 05 1256))
    ("正嘉" (03 14 1257))
    ("正元" (03 26 1259))
    ("文応" (04 13 1260))
    ("弘長" (02 20 1261))
    ("文永" (02 28 1264))
    ("建治" (04 25 1275))
    ("弘安" (02 29 1278))
    ("正応" (04 28 1288))
    ("永仁" (08 05 1293))
    ("正安" (04 25 1299))
    ("乾元" (11 21 1302))
    ("嘉元" (08 05 1303))
    ("徳治" (12 14 1306))
    ("延慶" (10 09 1308))
    ("応長" (04 28 1311))
    ("正和" (03 20 1312))
    ("文保" (02 03 1317))
    ("元応" (04 28 1319))
    ("元亨" (02 23 1321))
    ("正中" (12 09 1324))
    ("嘉暦" (04 26 1326))
    ("元徳" (08 29 1329) (04 28 1332))
    ("元弘" (08 09 1331)) ; 大覚寺統
    ("建武" (01 29 1334)) ; 大覚寺統
    ("延元" (02 29 1336)) ; 大覚寺統
    ("興国" (04 28 1340)) ; 大覚寺統
    ("正平" (12 08 1346)) ; 大覚寺統
    ("建徳" (07 24 1370)) ; 大覚寺統
    ("文中" (04 nil 1372)) ; 大覚寺統
    ("天授" (05 27 1375)) ; 大覚寺統
    ("弘和" (02 10 1381)) ; 大覚寺統
    ("元中" (04 28 1384) ((10) 5 1392)) ; 大覚寺統
    ("正慶" (04 28 1332) (05 18 1333)) ; 持明院統
    ("暦応" (08 28 1338)) ; 持明院統
    ("康永" (04 27 1342)) ; 持明院統
    ("貞和" (10 21 1345)) ; 持明院統
    ("観応" (02 27 1350)) ; 持明院統
    ("文和" (09 27 1352)) ; 持明院統
    ("延文" (03 28 1356)) ; 持明院統
    ("康安" (03 29 1361)) ; 持明院統
    ("貞治" (09 23 1362)) ; 持明院統
    ("応安" (02 18 1368)) ; 持明院統
    ("永和" (02 27 1375)) ; 持明院統
    ("康暦" (03 22 1379)) ; 持明院統
    ("永徳" (02 24 1381)) ; 持明院統
    ("至徳" (02 27 1384)) ; 持明院統
    ("嘉慶" (08 23 1387)) ; 持明院統
    ("康応" (02 09 1389)) ; 持明院統
    ("明徳" (03 26 1390)) ; 持明院統
    ("応永" (07 05 1394))
    ("正長" (04 27 1428))
    ("永享" (09 05 1429))
    ("嘉吉" (02 17 1441))
    ("文安" (02 05 1444))
    ("宝徳" (07 28 1449))
    ("享徳" (07 25 1452))
    ("康正" (07 25 1455))
    ("長禄" (09 28 1457))
    ("寛正" (12 21 1460))
    ("文正" (02 28 1466))
    ("応仁" (03 05 1467))
    ("文明" (04 28 1469))
    ("長享" (07 20 1487))
    ("延徳" (08 21 1489))
    ("明応" (07 19 1492))
    ("文亀" (02 29 1501))
    ("永正" (02 30 1504))
    ("大永" (08 23 1521))
    ("享禄" (08 20 1528))
    ("天文" (07 29 1532))
    ("弘治" (10 23 1555))
    ("永禄" (02 28 1558))
    ("元亀" (04 23 1570))
    ("天正" (07 28 1573))
    ("文禄" (12 08 1592))
    ("慶長" (10 27 1596))
    ("元和" (07 13 1615))
    ("寛永" (02 30 1624))
    ("正保" (12 16 1644))
    ("慶安" (02 15 1648))
    ("承応" (09 18 1652))
    ("明暦" (04 13 1655))
    ("万治" (07 23 1658))
    ("寛文" (04 25 1661))
    ("延宝" (09 21 1673))
    ("天和" (09 29 1681))
    ("貞享" (02 21 1684))
    ("元禄" (09 30 1688))
    ("宝永" (03 13 1704))
    ("正徳" (04 25 1711))
    ("享保" (06 22 1716))
    ("元文" (04 28 1736))
    ("寛保" (02 27 1741))
    ("延享" (02 21 1744))
    ("寛延" (07 12 1748))
    ("宝暦" (10 27 1751))
    ("明和" (06 02 1764))
    ("安永" (11 16 1772))
    ("天明" (04 02 1781))
    ("寛政" (01 25 1789))
    ("享和" (02 05 1801))
    ("文化" (02 11 1804))
    ("文政" (04 22 1818))
    ("天保" (12 10 1830))
    ("弘化" (12 02 1844))
    ("嘉永" (02 28 1848))
    ("安政" (11 27 1854))
    ("万延" (03 18 1860))
    ("文久" (02 19 1861))
    ("元治" (02 20 1864))
    ("慶応" (04 08 1865))
    ("明治" (09 08 1868))
    ("大正" (07 30 1912))
    ("昭和" (12 25 1926))
    ("平成" (01 08 1989))
    ("令和" (05 01 2019))
    ("" (nil nil 2099))))

(defvar calendar-japanese-era-year nil
  "Absolute date of 1/1 of each year (since 454 A.D) in Japan.")

(defvar calendar-japanese-era-year-max nil)

(defun calendar-japanese-era-setup ()
  "Set up `cj-ear-year' and `cj-ear-year-max' variables."
  (let ((vector (make-vector (calendar-japanese-year-index 2100) nil))
        (ht (make-hash-table :test 'equal)))
    (dotimes (i (1-(length calendar-japanese-era)))
      (let* ((era (car (elt calendar-japanese-era i)))
             (start (elt (elt calendar-japanese-era i) 1))
             (end (or (elt (elt calendar-japanese-era i) 2)
                      (elt (elt calendar-japanese-era (1+ i)) 1)))
             (start-year (elt start 2))
             (end-year (elt end 2)))
        (puthash era (cons start-year (- end-year start-year -1)) ht)
        (cl-loop for i from start-year to end-year
                 do
                 (cl-pushnew (cons era (- i start-year -1))
                             (aref vector (calendar-japanese-year-index i))))))
    (setq calendar-japanese-era-year vector)
    (setq calendar-japanese-era-year-max ht)))

(calendar-japanese-era-setup)

;;; Code:

(defsubst calendar-japanese-months (month-indicators)
  "List of months (leap month is list) from MONTH-INDICATORS."
  (cl-loop for indicator in month-indicators
           for month = (% indicator 32)
           collect (if (eq prev-month month) (list month) month)
           for prev-month = month))

;;###autoload
(defun calendar-japanese-from-absolute (date)
  "Calculate Japanese Date from  absolute DATE.
Leap month is expressed as a list."
  (unless (integerp date) (error "Date is not integer"))
  (if (< date calendar-japanese-absolute-start)
      (error "Abs date before 165501 is not supported"))
  (if (< 683734 date) (calendar-gregorian-from-absolute date)
    (let* ((y-idx (1- (cl-position-if (lambda (x) (< date x))
                                      calendar-japanese-absolute)))
           (year (+ y-idx calendar-japanese-year-index))
           (days (- date (aref calendar-japanese-absolute y-idx)))
           (month-indicators (calendar-japanese-month-indicators y-idx))
           (months-days (calendar-japanese-months-days month-indicators))
           (months (calendar-japanese-months month-indicators))
           (days-acc 0)
           (m-idx (cl-position-if
                   (lambda (x) (if (< days (+ x days-acc)) t
                            (cl-incf days-acc x) nil))
                   months-days))
           (month (elt months m-idx))
           (day (- days days-acc -1)))
      (list month day year))))

;;;###cal-autoload
(defun calendar-japanese-to-absolute (date)
  "Convert Japanese DATE to Aboslute date.
Leap month is expressed as a list."
  (if (< 1872 (elt date 2)) (calendar-absolute-from-gregorian date)
    (let* ((month (elt date 0))
           (day   (elt date 1))
           (year  (elt date 2))
           (y-idx (calendar-japanese-year-index year))
           (abs   (aref calendar-japanese-absolute y-idx))
           (m-indicators (calendar-japanese-month-indicators y-idx))
           (months       (calendar-japanese-months m-indicators))
           (months-days  (calendar-japanese-months-days m-indicators))
           (m-idx (cl-position month months :test 'equal)))
      (apply '+ abs day -1 (seq-take months-days m-idx)))))

(defun calendar-japanese-sexagenary (base)
  "Sexagenary with parenthesis of BASE number."
  (let* ((stem  (% base 10))
         (branch (% base 12))
	 (lexical `((stem .  ,(aref calendar-japanese-celestial-stem stem))
		    (branch . ,(aref calendar-japanese-terrestrial-branch branch))
		    (stem-on .  ,(aref calendar-japanese-celestial-stem-on stem))
		    (branch-on . ,(aref calendar-japanese-terrestrial-branch-on branch))
		    (stem-kun .  ,(aref calendar-japanese-celestial-stem-kun stem))
		    (branch-kun . ,(aref calendar-japanese-terrestrial-branch-kun branch))
		    (stem-no .  ,(if (cl-oddp stem) "の" "")))))
    (mapconcat (lambda (sym) (eval sym lexical)) calendar-japanese-sexagenary-form "")))

(defun calendar-japanese-year-name (era-year year)
  "Japanese ERA-YEAR (YEAR) name with sexagenary."
  (format "%d年%s" era-year
          (calendar-japanese-sexagenary (- year 4))))

(defun calendar-japanese-month-name (month year)
  "Japanese MONTH name of the YEAR with sexagenary."
  (let ((leap (when (listp month) (setq month (car month)) t))
        (sexagenary (calendar-japanese-sexagenary (+ (* year 12) month 13))))
    (format "%s%d月%s" (if leap "閏" "") month sexagenary)))

(defun calendar-japanese-day-name (date)
  "Japanese day name of DATE with sexagenary."
  (let* ((base (+ (calendar-japanese-to-absolute date) 14))
         (sexagenary (calendar-japanese-sexagenary base)))
    (format "%d日%s" (elt date 1) sexagenary)))

(defun calendar-japanese-query-year ()
  "Query Japanese year."
  (let* ((era (completing-read "Era? " calendar-japanese-era-year-max))
         (era-tuple (gethash era calendar-japanese-era-year-max))
          (start-year (car era-tuple))
          (max-year (cdr era-tuple))
          (candidate-years
           (cl-loop for i from 1 to max-year
                    collect (calendar-japanese-year-name
                             i (+ i start-year -1)))))
    (+ (cl-position (completing-read "Year? " candidate-years)
                    candidate-years :test 'equal)
       start-year)))

(defun calendar-japanese-query-date (year)
  "Query Japanese date of YEAR."
  (interactive (list (calendar-japanese-query-year)))
  (let (month day date)
    (if (< year 1873)
        ;; Old Japanese Calendar
        (let* ((month-indicators
                (calendar-japanese-month-indicators
                 (calendar-japanese-year-index year)))
               (months (calendar-japanese-months month-indicators))
               (month-name-list
                (mapcar (lambda (m) (calendar-japanese-month-name m year))
                        months))
               (month-name (completing-read "Month? " month-name-list))
               (m-idx (cl-position month-name month-name-list :test 'equal)))
          (setq month (elt months m-idx))
          (setq day (let* ((days
                            (cl-loop for i from 1 to
                                     (elt (calendar-japanese-months-days
                                           month-indicators) m-idx)
                                     collect (calendar-japanese-day-name
                                              (list month i year)))))
                      (1+ (cl-position (completing-read "Day? " days)
                                       days :test 'equal)))))
      ;; Gregorian
      (setq month (calendar-read "Month? (1-12) " (lambda (x) (<= x 12))))
      (setq day (let ((last-day (calendar-last-day-of-month month year)))
                  (calendar-read (format "Days? (1-%d) " last-day)
                                 (lambda (d) (<= d last-day))))))
    (setq date (list month day year))
    (when (called-interactively-p 'any) (message "date=%s" date))
    date))

;;;###cal-autoload
(defun calendar-japanese-goto-date (date)
  "Move cursor to Japanese date DATE."
  (interactive (list (call-interactively 'calendar-japanese-query-date)))
  (calendar-goto-date (calendar-gregorian-from-absolute
                       (calendar-japanese-to-absolute date))))

(defun calendar-japanese-era-name (year)
  "Japanese Era Name of YEAR with sexagenary."
  (let* ((eras (aref calendar-japanese-era-year
                     (calendar-japanese-year-index year)))
         (base (- year 4)))
    (concat
     (mapconcat (lambda (era) (let ((name (car era))
                               (year (cdr era)))
                           (when (= year 1) (setq year "元"))
                           (format "%s%s年" name year)))
                (reverse eras) "・")
     (calendar-japanese-sexagenary base))))

(defun calendar-japanese-date-string (date)
  "Japanese DATE string."
  (let* ((year (elt date 2))
         (era-name (calendar-japanese-era-name year))
         (month-name (calendar-japanese-month-name (elt date 0) year))
         (day-name (calendar-japanese-day-name date)))
    (format "%s%s%s" era-name month-name day-name)))

;;;###autoload
(defun calendar-japanese-print-date ()
  "Show the Japanese date equivalents of date."
  (interactive)
  (message "Japanese date: %s"
           (calendar-japanese-date-string
            (calendar-japanese-from-absolute
             (calendar-absolute-from-gregorian
              (calendar-cursor-to-date t))))))

(provide 'cal-japan)

;;; cal-japan.el ends here
