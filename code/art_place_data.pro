pro art_place_data, probe=probe, pngname=pngname
  window,xs=900,ys=800
  !p.charsize=1.2
  loadct_sd,47
    
  ;Bcon
;  array = con_text()
  array = ['2021-11-18/21:40 20','2021-11-18/21:40 20']
  for ii=1.,N_ELEMENTS(array)-1 do begin
    data_set = strsplit(array[ii],/extract)
    timespan,data_set[0],data_set[1],/m
    thm_load_state,probe=probe[0],datatype='pos',coord='sse'
    art_sse,probe[0]
    options,'th'+probe[0]+'_state_pos_sse_rl',$
      xtitle='X POS in SSE(RL)',ytitle='Y POS in SSE (RL)'

    if ii eq 1 then begin
      tplotxy,'th'+probe[0]+'_state_pos_sse_rl',versus='xy',xrange=[-10,10],yrange=[-10,10],/iso,/xsty,/ysty,color=120,xtitle='X POS in SSE(RL)',ytitle='Y POS in SSE (RL)',title=pngname
      draw_earth
      
    endif else begin
      tplotxy,'th'+probe[0]+'_state_pos_sse_rl',versus='xy',xrange=[-10,10],yrange=[-10,10],/iso,/xsty,/ysty,/over,color=120
    endelse
  endfor
  
  ;particle
;  array = con_text()
;  for ii=1.,N_ELEMENTS(array)-1 do begin
;    data_set = strsplit(array[ii],/extract)
;    timespan,data_set[0],data_set[1],/m
;    thm_load_state,datatype='pos',coord='sse'
;    art_sse,probe[0]
;
;    tplotxy,'th'+probe[0]+'_state_pos_sse_rl',versus='xy',xrange=[-10,10],yrange=[-10,10],/iso,/xsty,/ysty,/over,color=120
;  endfor
  makepng,pngname
end
    