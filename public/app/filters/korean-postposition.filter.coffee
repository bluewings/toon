'use strict'

angular.module 'scomp'
.filter 'koreanPostposition', ->

  BASE = 0xAC00
  INITIALS = ['ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ',
    'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ']
  MEDIALS = ['ㅏ', 'ㅐ', 'ㅑ', 'ㅒ', 'ㅓ', 'ㅔ', 'ㅕ', 'ㅖ', 'ㅗ', 'ㅘ',
    'ㅙ', 'ㅚ', 'ㅛ', 'ㅜ', 'ㅝ', 'ㅞ', 'ㅟ', 'ㅠ', 'ㅡ', 'ㅢ', 'ㅣ']
  FINALES = ['', 'ㄱ', 'ㄲ', 'ㄳ', 'ㄴ', 'ㄵ', 'ㄶ', 'ㄷ', 'ㄹ', 'ㄺ',
    'ㄻ', 'ㄼ', 'ㄽ', 'ㄾ', 'ㄿ', 'ㅀ', 'ㅁ', 'ㅂ', 'ㅄ', 'ㅅ', 'ㅆ',
    'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ']

  getSymbol = (char) ->
    if !char.match /[ㄱ-ㅎ가-힣]/
      return false
    else if char.match /[ㄱ-ㅎ]/
      return result =
        initial: char
        medial: ''
        finale: ''
        initialOffset: INITIALS.join('').search(char)
        medialOffset: -1
        finaleOffset: -1
        
    tmp = char.charCodeAt(0) - BASE

    finaleOffset = tmp % FINALES.length
    medialOffset = ((tmp - finaleOffset) / FINALES.length) % MEDIALS.length
    initialOffset = (((tmp - finaleOffset) / FINALES.length) - medialOffset) / MEDIALS.length

    result =
      initial: INITIALS[initialOffset]
      medial: MEDIALS[medialOffset]
      finale: FINALES[finaleOffset]
      initialOffset: initialOffset
      medialOffset: medialOffset
      finaleOffset: finaleOffset

  replaceFn = (value, testStr, postposition) ->
    symbol = getSymbol(testStr)
    if symbol.finale
      testStr + postposition.replace /\(.\)/, ''
    else
      testStr + postposition.replace /.+\((.)\)/, '$1'

  (value) ->
    value = value.replace /(.)(이가\(가\))/g, replaceFn
    value = value.replace /(.)(은\(는\))/g, replaceFn
    value = value.replace /(.)(을\(를\))/g, replaceFn
    value.replace /(.)(이\(가\))/g, replaceFn
