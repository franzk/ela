describe 'StringMixin', ->
  describe '#toCamel', ->
    it 'returns the string in camelcase', ->
      (expect "such-test-much-wow".toCamel()).toEqual("suchTestMuchWow")
      (expect "such_test_much_wow".toCamel()).toEqual("suchTestMuchWow")
      (expect "such-test-much_wow".toCamel()).toEqual("suchTestMuchWow")
      (expect "SuchTestMuchWow".toCamel()).toEqual("suchTestMuchWow")

  describe '#toCapitalCamel', ->
    it 'returns the string in camelcase with first char capitalized', ->
      (expect "such-test-much-wow".toCapitalCamel()).toEqual("SuchTestMuchWow")
      (expect "such_test_much_wow".toCapitalCamel()).toEqual("SuchTestMuchWow")
      (expect "such-test-much_wow".toCapitalCamel()).toEqual("SuchTestMuchWow")
      (expect "SuchTestMuchWow".toCapitalCamel()).toEqual("SuchTestMuchWow")

  describe '#toUnderscore', ->
    it 'returns the string in underscore', ->
      (expect "SuchTestMuchWow".toUnderscore()).toEqual("such_test_much_wow")
      (expect "suchTestMuchWow".toUnderscore()).toEqual("such_test_much_wow")
      (expect "such-test-much-wow".toUnderscore()).toEqual("such_test_much_wow")
      (expect "such_test_much_wow".toUnderscore()).toEqual("such_test_much_wow")

  describe '#toDash', ->
    it 'returns the string in dashed', ->
      (expect "SuchTestMuchWow".toDash()).toEqual("such-test-much-wow")
      (expect "suchTestMuchWow".toDash()).toEqual("such-test-much-wow")
      (expect "such-test-much-wow".toDash()).toEqual("such-test-much-wow")
      (expect "such_test_much_wow".toDash()).toEqual("such-test-much-wow")

  describe '#toLabel', ->
    it 'returns the string as human readable label', ->
      (expect "SuchTestMuchWow".toLabel()).toEqual("Such Test Much Wow")
      (expect "suchTestMuchWow".toLabel()).toEqual("Such Test Much Wow")
      (expect "such-test-much-wow".toLabel()).toEqual("Such Test Much Wow")
      (expect "such_test_much_wow".toLabel()).toEqual("Such Test Much Wow")
