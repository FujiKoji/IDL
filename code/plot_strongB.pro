pro plot_strongb,probe=probe,time=time,span=span
  window,xs=2000,ys=1000
  init_crib_colors
  datatemplate=ascii_template()
  file=dialog_pickfile()
  data=read_ascii(file, template=datatemplate)
  
  pos = [[data.LON],[data.LAT]]
  pos_b = data.BT
  bin2d,pos[*,0],pos[*,1],pos_b,$
        binum=500,$
        averages=averages,$
        medians=medians,$
        xcenters=x_centers,$
        ycenters=y_centers,$
        flagnodata=!values.d_nan
  plotxyz,x_centers,y_centers,averages,xtitle='LON',ytitle='LAT',zrange=[0,300]
  
  timespan,time,span,/m
  ;日陰補正を行った磁場データの取得
  thm_load_fgm,probe=probe[0],level='l1',datatype='fgl', use_eclipse=2,coord='dsl'
  ;artのSSE座標の取得
;  art_sse,probe=probe[0]
  thm_load_slp
  ;座標系をSSEに変換
  thm_cotrans,'th'+probe[0]+'_fgl',out_coord='sse'
  ;磁場データの平均化
  avg_data,'th'+probe[0]+'_fgl',3.0,newname='th'+probe[0]+'_fgl_avg'
  art_calc_bcon,probes=probe[0]
  
  tplotxy,'th'+probe[0]+'_bconnect_latlon',versus='yx',/over,color=5,psym=5
end