beforeEach ->
  jasmine.addMatchers
    toBeInstanceOf: (util, customEqualityTesters) ->
      return {
        compare: (actual, expected) ->
          result = pass: (actual instanceof expected)
          result.message = "Expected object to be an instance of #{expected.name}"
          result
      }
