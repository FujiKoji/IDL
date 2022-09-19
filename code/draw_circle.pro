pro draw_circle
  r=1
  x=dblarr(2e2)
  y=dblarr(2e2)

  delta=0.01

  for xx=0,199 do begin
    y[xx]=sqrt(r^2-((xx-100)*delta)^2)
    x[xx]=(xx-100)*delta
  endfor
  oplot,x,y
  for xx=0,199 do begin
    y[xx]=-sqrt(r^2-((xx-100)*delta)^2)
    x[xx]=(xx-100)*delta
  endfor
  oplot,x,y
end