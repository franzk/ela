Math.gaussianElimination = (_A, v) ->
  # copy _A
  A = (a.slice(0) for a in _A)

  # convert to single matrix if necessary
  if v?
    for value, index in v
      A[index].push(value)

  n = A.length

  for k in [0...n] by 1
    # Find maximum absolute value in this column
    maxEl = Math.abs(A[k][k])
    maxRow = k
    for i in [k+1...n] by 1
      if Math.abs(A[k][i]) > maxEl
        maxEl = Math.abs(A[k][i])
        maxRow = i

    # Swap maximum row with current row
    tmp = A[k]
    A[k] = A[maxRow]
    A[maxRow] = tmp

    # In current column, make all values below 0
    for i in [k+1...n] by 1
      c = -A[i][k]/A[k][k]
      A[i][k] = 0
      for j in [k+1..n] by 1
        A[i][j] += c * A[k][j]

  # Solve equation Ax=b for an upper triangular matrix A
  x = new Array(n)
  for k in [n-1..0] by -1
    x[k] = A[k][n] / A[k][k]
    for i in [k-1..0] by -1
      A[i][n] -= A[i][k] * x[k]

  x
