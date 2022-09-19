pro art_place_data, probe=probe
  window,xs=900,ys=800
  !p.charsize=1.2
  ;Bcon
  array = con_text()
  
  for ii=1.,N_ELEMENTS(array)-1 do begin
    data_set = strsplit(array[ii],/extract)
    timespan,data_set[0],data_set[1],/m
    
    ;日陰補正を行った磁場データの取得
    thm_load_fgm,probe=probe[0],level='l1',datatype='fgl', use_eclipse=2,coord='dsl'
    
    ;artのSSE座標の取得
    art_sse,probe[0]
    
    ;座標系をSSEに変換
    thm_cotrans,'th'+probe[0]+'_fgl',out_coord='sse'
    
    ;磁場データの平均化
    avg_data,'th'+probe[0]+'_fgl',3.0,newname='th'+probe[0]+'_fgl_avg'
    art_calc_bcon,probes=probe[0]
    
    if ii eq 1 then begin
      tplotxy,'th'+probe[0]+'_bconnect_latlon',versus='xy',xrange=[-200,200],yrange=[-200,200],/iso,/xsty,/ysty,color=0,xtitle='Longitude',ytitle='latitude'
    endif else begin
      tplotxy,'th'+probe[0]+'_bconnect_latlon',versus='xy',xrange=[-200,200],yrange=[-200,200],/iso,/xsty,/ysty,color=0,xtitle='Longitude',ytitle='latitude',/over
    endelse
    
    makepng,'Bcon_moon_plpace'
  endfor
end
    
    
    
    