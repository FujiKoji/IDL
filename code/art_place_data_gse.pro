pro art_place_data_gse, pngname=pngname
  window,xs=900,ys=800
  !p.charsize=1.2
  
  probe='b'
  ;Bcon
  array = con_text()
;  array = ['2021-11-18/21:40 20','2021-11-18/21:40 20']
  for ii=1.,N_ELEMENTS(array)-1 do begin
    data_set = strsplit(array[ii],/extract)
    timespan,data_set[0],data_set[1],/m
    thm_load_state,probe=probe[0],datatype='pos',coord='gse'
    art_sse,probe[0]
    tkm2re,'th'+probe[0]+'_state_pos_gse'
    options,'th'+probe[0]+'_state_pos_sse_rl',$
      xtitle='X POS in GSE(RE)',ytitle='Y POS in GSE (RE)'

    if ii eq 1 then begin
      tplotxy,'th'+probe[0]+'_state_pos_gse_re',versus='xy',xrange=[-80,80],yrange=[-80,80],/iso,/xsty,/ysty,color=0,xtitle='X POS in GSE(RE)',ytitle='Y POS in GSE (RE)',title=pngname,psym=5
      draw_circle

    endif else begin
      tplotxy,'th'+probe[0]+'_state_pos_gse_re',versus='xy',xrange=[-80,80],yrange=[-80,80],/iso,/xsty,/ysty,/over,color=0,psym=5
    endelse
  endfor
  
  array = con_text()

  for ii=1.,N_ELEMENTS(array)-1 do begin
    data_set = strsplit(array[ii],/extract)
    timespan,data_set[0],data_set[1],/m
    thm_load_state,probe=probe[0],datatype='pos',coord='gse'
    art_sse,probe[0]
    tkm2re,'th'+probe[0]+'_state_pos_gse'
    options,'th'+probe[0]+'_state_pos_sse_rl',$
      xtitle='X POS in GSE(RE)',ytitle='Y POS in GSE (RE)'

    tplotxy,'th'+probe[0]+'_state_pos_gse_re',versus='xy',xrange=[-80,80],yrange=[-80,80],/iso,/xsty,/ysty,/over,color=0,psym=6
  endfor
  
  probe='c'
  array = con_text()

  for ii=1.,N_ELEMENTS(array)-1 do begin
    data_set = strsplit(array[ii],/extract)
    timespan,data_set[0],data_set[1],/m
    thm_load_state,probe=probe[0],datatype='pos',coord='gse'
    art_sse,probe[0]
    tkm2re,'th'+probe[0]+'_state_pos_gse'
    options,'th'+probe[0]+'_state_pos_sse_rl',$
      xtitle='X POS in GSE(RE)',ytitle='Y POS in GSE (RE)'

    tplotxy,'th'+probe[0]+'_state_pos_gse_re',versus='xy',xrange=[-80,80],yrange=[-80,80],/iso,/xsty,/ysty,/over,color=0,psym=7
  endfor
  
  makepng,pngname
end
