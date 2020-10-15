import math
import strformat

const 
  Imax = 126
  Jmax = 126

type
  Matrix[W, H: static[int]] =
    array[W, array[H, float]]

var v:Matrix[Imax+1, Jmax+1]

proc arbitrary_transmission_line(W,H,w,h,t:int): void =
  const
    Eo = 8.854e-12
    Er = 1.0
    mu = 12.57e-7
    r = 1.5
  var
    c, l, Zo, vnew, c_old:float = 0.0
    i, j, k, done:int = 0

  for i in 0 .. W:
    for j in 0 .. H:
      v[i][i] = 0.0
  for i in ((W-w) div 2) .. ((W-w) div 2 + w):
    for j in h .. (h+t):
      v[i][j] = 1.0

  while done==0:
    k = k+1
    for i in 1 ..< W:
      for j in 1 ..< H:
        if v[i][j] != 1.0:
          vnew = r*(v[i+1][j]+v[i-1][j]+v[i][j+1]+v[i][j-1])/4+(1-r)*v[i][j]
          v[i][j]=vnew
    if k mod 10 == 0:
      c_old = c
      c = 0.0
      for i in 0 ..< W:
        for j in 0 ..< H:
          c = c + pow(v[i][j]-v[i+1][j+1],2.0)+pow(v[i+1][j]-v[i][j+1],2.0)
      c=c*Eo/2.0 # Find capacitance - only correct if air-spaced 
      l=mu*Eo/c  # Calculate the line inductance - always correct 
      c=c*Er     # Correct the capacitance if line has a dielectric 
      Zo=sqrt(l/c)    # Calculate the characteristic impedance 
      #echo fmt"{%5d c=%.2lfpF/m l=%.2lfnH/m Zo=%lf Ohms\n|}",k,c*1e12,l*1e9,Zo
      echo fmt"{k:5d} c={c*1e12:.2f}pF/m l={l*1e9:.2f}nH/m Zo={Zo:.6f} Ohms"
    if abs(c_old-c)/c < 0.00001:
      done = 1
    else:
      done = 0

when isMainModule:
  arbitrary_transmission_line(58,40,32,18,0)

