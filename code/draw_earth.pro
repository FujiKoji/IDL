pro draw_earth,rot=rot,fill=fill
delta=0
if keyword_set(rot) then delta=!pi/2.0
if keyword_set(fill) then begin
	tvcircle,1,0,0,255,/data,/fill
	tvcircle,1,0,0,/data;,/fill,color=255
endif else tvcircle,1,0,0,/data;,/fill,color=255

x=dblarr(1e3)
y=dblarr(1e3)

for i=0,180 do begin
	for j=0,999 do begin
		y[j]=j*(sin(!pi/2+!pi*i/180+delta))/1000
		x[j]=j*(cos(!pi/2+!pi*i/180+delta))/1000
	endfor
;stop
oplot,x,y

endfor

end
