'use strict'

# 한글 처리를 위한 유틸 모음 (자소분리 자동완성 등)
# http://skywalker@yobi.navercorp.com/skywalker/autocomplete-korean 참고

BASE = 0xAC00

INITIALS = ['ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ',
  'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ']
MEDIALS = ['ㅏ', 'ㅐ', 'ㅑ', 'ㅒ', 'ㅓ', 'ㅔ', 'ㅕ', 'ㅖ', 'ㅗ', 'ㅘ',
  'ㅙ', 'ㅚ', 'ㅛ', 'ㅜ', 'ㅝ', 'ㅞ', 'ㅟ', 'ㅠ', 'ㅡ', 'ㅢ', 'ㅣ']
FINALES = ['', 'ㄱ', 'ㄲ', 'ㄳ', 'ㄴ', 'ㄵ', 'ㄶ', 'ㄷ', 'ㄹ', 'ㄺ',
  'ㄻ', 'ㄼ', 'ㄽ', 'ㄾ', 'ㄿ', 'ㅀ', 'ㅁ', 'ㅂ', 'ㅄ', 'ㅅ', 'ㅆ',
  'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ']
MIXED = 
  'ㄲ': ['ㄱ', 'ㄱ']
  'ㄳ': ['ㄱ', 'ㅅ']
  'ㄵ': ['ㄴ', 'ㅈ']
  'ㄶ': ['ㄴ', 'ㅎ']
  'ㄺ': ['ㄹ', 'ㄱ']
  'ㄻ': ['ㄹ', 'ㅁ']
  'ㄼ': ['ㄹ', 'ㅂ']
  'ㄽ': ['ㄹ', 'ㅅ']
  'ㄾ': ['ㄹ', 'ㅌ']
  'ㄿ': ['ㄹ', 'ㅍ']
  'ㅀ': ['ㄹ', 'ㅎ']
  'ㅄ': ['ㅂ', 'ㅅ']
  'ㅆ': ['ㅅ', 'ㅅ']
  'ㅗ': ['ㅗ', 'ㅚ']
  'ㅜ': ['ㅜ', 'ㅟ']
  'ㅡ': ['ㅡ', 'ㅢ']
EN =
  INITIALS: ['r', 'R', 's', 'e', 'E', 'f', 'a', 'q', 'Q', 't', 'T', 'd', 'w', 'W', 'c', 'z', 'x', 'v', 'g']
  MEDIALS: ['k', 'o', 'i', 'O', 'j', 'p', 'u', 'P', 'h', 'hk', 'ho', 'hl', 'y', 'n', 'nj', 'np', 'nl', 'b', 'm', 'ml', 'l']
  FINALES: ['' ,'r', 'R', 'rt', 's', 'sw', 'sg', 'e', 'f', 'fr', 'fa', 'fq', 'ft', 'fx', 'fv', 'fg', 'a', 'q', 'qt', 't', 'T', 'd', 'w', 'c', 'z', 'x', 'v', 'g']

angular.module 'scomp'
.service 'koreanUtil', ->

  prepare = ->

    compare = (a, b) -> if a.length < b.length then 1 else -1

    for type, items of EN
      map = {}
      for each, i in items
        map[each] = i
      items.sort compare

      EN[type] = map
      EN[type + '_REGEXP'] = items.join '|'

    undefined

  engToKor = (search) ->

    regExp = new RegExp "(#{EN.INITIALS_REGEXP})(#{EN.MEDIALS_REGEXP})((#{EN.FINALES_REGEXP})(?=(#{EN.INITIALS_REGEXP})(#{EN.MEDIALS_REGEXP}))|(#{EN.FINALES_REGEXP}))", 'g'

    result = search.replace regExp, (str, initial, medial, finale) ->
      String.fromCharCode EN.INITIALS[initial] * MEDIALS.length * FINALES.length + EN.MEDIALS[medial] * FINALES.length + EN.FINALES[finale] + BASE    

    matches = result.match /^([ㄱ-ㅎ가-힣]+)([a-zA-Z]{1,2})$/
    if matches and matches.length == 3 and EN.INITIALS[matches[2]]
      result = matches[1] + INITIALS[EN.INITIALS[matches[2]]]

    return result

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

    return result
      
  getPatterns = (search, initialSearch, recursive = true) ->

    initialRegexp = []
    if initialSearch
      for i in [0..search.length - 1] by 1
        char = search.charAt(i)
        if char.search /ㄱ-ㅎ가-힣/ > -1
          symbols = getSymbol search.charAt(i)
          if symbols.initial isnt '' and symbols.medial == '' and symbols.finale == ''
            codeFrom = symbols.initialOffset * MEDIALS.length * FINALES.length + BASE
            codeTo = codeFrom + MEDIALS.length * FINALES.length - 1
            regexp = "[#{String.fromCharCode codeFrom}-#{String.fromCharCode codeTo}]"
            initialRegexp.push regexp
          else
            initialRegexp.push char
        else
          initialRegexp.push char
    initialRegexp = initialRegexp.join ''

    lastChar = search.charAt search.length - 1
    symbols = getSymbol lastChar
    
    if !symbols
      regexp = search
      # 글자수가 2이상이고 한글이 전혀 없는 경우 한글로 변환해서 다시 시도해본다
      if recursive and search.length > 1 and search.search /ㄱ-ㅎ가-힣/ == -1
        regexp += '|' + getPatterns engToKor(search), initialSearch, false
      return regexp

    # 해당 초성으로 시작하는 첫번째 문자 : 가, 나, 다, ... , 하
    baseCode = symbols.initialOffset * MEDIALS.length * FINALES.length + BASE

    if symbols.finale != ''
      # CASE 1 : 받침이 있는 경우
      # ex) 민 > (민|미[나-닣]) = 민주주의, 미네랄
      # ex) 해맑 > 해(맑|말[가-깋]) = 해맑은, 해마고기 (종성이 복합자음인 경우)      
      if MIXED[symbols.finale]
        # 종성이 복합자음인 경우 분리되는 경우 적용
        initialOffset = INITIALS.join('').search(MIXED[symbols.finale][1])
        lastChar_ = String.fromCharCode baseCode + symbols.medialOffset * FINALES.length + FINALES.join('').search(MIXED[symbols.finale][0]) + 1
      else
        # 일반적인 경우
        initialOffset = INITIALS.join('').search(symbols.finale)
        lastChar_ = String.fromCharCode baseCode + symbols.medialOffset * FINALES.length
      codeFrom = initialOffset * MEDIALS.length * FINALES.length + BASE
      codeTo = codeFrom + MEDIALS.length * FINALES.length - 1
      regexp = "(#{lastChar}|#{lastChar_}[#{String.fromCharCode codeFrom}-#{String.fromCharCode codeTo}])"
    else if symbols.medial != ''
      # CASE 2 : 받침이 없는 경우
      # ex) 유학우 > 유학[우-윟] = 유학원 (모음이 변경될 여지가 있는 경우: ㅗ, ㅜ, ㅡ)
      # ex) 페이스부 > 페이스[부-붛] = 페이스북
      if MIXED[symbols.medial]
        codeFrom = baseCode + MEDIALS.join('').search(MIXED[symbols.medial][0]) * FINALES.length
        codeTo = baseCode + MEDIALS.join('').search(MIXED[symbols.medial][1]) * FINALES.length + FINALES.length - 1
      else
        codeFrom = baseCode + symbols.medialOffset * FINALES.length
        codeTo = codeFrom + FINALES.length - 1
      regexp = "[#{String.fromCharCode codeFrom}-#{String.fromCharCode codeTo}]"
    else if symbols.initial != ''
      # CASE 3 : 초성으로 끝나는 경우
      # ex) 어학연ㅅ > 어학연[사-싷] = 어학연수
      codeFrom = baseCode
      codeTo = codeFrom + MEDIALS.length * FINALES.length - 1
      regexp = "[#{String.fromCharCode codeFrom}-#{String.fromCharCode codeTo}]"

    if initialRegexp
      initialRegexp + '|' + search.substr(0, search.length - 1) + regexp
    else
      search.substr(0, search.length - 1) + regexp

  prepare()

  engToKor: engToKor
  getSymbol: getSymbol
  getPatterns: getPatterns