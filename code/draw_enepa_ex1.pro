;; 
; Copy & paste codes to generates plots of differential energy fluxes as a function of energy v.s. pitch angle 
;;

; time interval when loss cone & electron beam are observed.
; The event shown in Sawaguchi+2020:
; 
;
pro draw_enepa_ex1

;  timespan,'2011-09-10/05:38:00',2,/min
  timespan,'2021-07-25/10:05:00',2,/min
  
  get_timespan,t
  probe='b'  ; ARTEMIS-2
  typ='peeb' ; particle burst mode data
  
  thm_get_pad, probe=probe, typ=typ, trange=t, dist=dist, pad_str=pad_str
  
  window,xs=600,ys=800
  
  for ii=0., n_elements(pad_str.x)-1 do begin
  
  	data=transpose(reform(pad_str.y[ii,*,*])) ; energy & pitch angle
  	energy=reform(pad_str.v2[ii,*,0]) 
  	pa=reform(pad_str.v1[ii,0,*])
  
  	ind=where(finite(data,/nan) eq 1,cts)
  
  	if cts lt 10 then begin
  
  		plotxyz,pa,energy,data,xrange=[0,180],yrange=[10,3e4],/xsty,/ysty,/ylog,/zlog,/noiso,$
  			xtitle='Pitch angle [deg.]',ytitle='Energy [eV]',ztitle='differential energy flux',$
  			title=time_string(pad_str.x[ii]),charsize=1.4
  		
  		makepng,strupcase(ii)
  
  		wait,1.0
  
  	endif
  
  endfor

end