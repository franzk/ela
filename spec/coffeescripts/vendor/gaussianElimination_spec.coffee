describe 'gaussianElimination', ->
  it 'should not modify input matrix', ->
    a = [[-5]]
    Math.gaussianElimination(a, [10])
    expect(a).toEqual([[-5]])

  it 'should work for a 1x1 matrix', ->
    expectRoundedArray(Math.gaussianElimination([[-5]], [10])).toEqual([-2])
    expectRoundedArray(Math.gaussianElimination([[-5, 10]])).toEqual([-2])

  it 'should work for a 2x2 matrix', ->
    expectRoundedArray(Math.gaussianElimination([[-1, 7], [-5, 1]], [-23, -13])).toEqual([2, -3])
    expectRoundedArray(Math.gaussianElimination([[-1, 7, -23], [-5, 1, -13]])).toEqual([2, -3])

  it 'should work for a 3x3 matrix', ->
    expectRoundedArray(Math.gaussianElimination([[-2, -3, -2], [1, 5, -2], [4, -3, 1]], [-6, 31, 15])).toEqual([7, 2, -7])
    expectRoundedArray(Math.gaussianElimination([[-2, -3, -2, -6], [1, 5, -2, 31], [4, -3, 1, 15]])).toEqual([7, 2, -7])

  it 'should work for a 4x4 matrix', ->
    expectRoundedArray(Math.gaussianElimination([[-6, 1, -6, 0], [9, 9, -2, -6], [10, 3, 3, 1], [6, -6, 1, 7]], [-63, -78, 23, 92])).toEqual([3, -9, 6, 2])
    expectRoundedArray(Math.gaussianElimination([[-6, 1, -6, 0, -63], [9, 9, -2, -6, -78], [10, 3, 3, 1, 23], [6, -6, 1, 7, 92]])).toEqual([3, -9, 6, 2])

  it 'should work for a 5x5 matrix', ->
    expectRoundedArray(Math.gaussianElimination([[4, 4, -5, 6, -10], [-3, -8, 0, -7, -2], [7, -4, 8, -9, 9], [6, 6, -7, 1, -8], [2, -3, -5, -9, 4]], [35, -1, -88, -48, -142])).toEqual([-6, -2, 9, 7, -7])
    expectRoundedArray(Math.gaussianElimination([[4, 4, -5, 6, -10, 35], [-3, -8, 0, -7, -2, -1], [7, -4, 8, -9, 9, -88], [6, 6, -7, 1, -8, -48], [2, -3, -5, -9, 4, -142]])).toEqual([-6, -2, 9, 7, -7])
