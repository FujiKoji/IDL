pro art_b_rel,probe=probe
  window,xs=1600,ys=1000
  !p.charsize=1.2
  
  array = con_text()

  stop
  
  loadct_sd,47
  
  for ii=1.,N_ELEMENTS(array)-1 do begin
    timespan,array[ii],2,/h
    
    ;fpe周波数
    thm_load_esa,probe=probe[0],datatype='peif_density'
    get_data,'th'+probe[0]+'_peif_density',data=i_density
    store_data,'th'+probe[0]+'_fpe',$
      data={x:i_density.x,y:9000*sqrt(i_density.y)}
      
    ;fce周波数
    thm_load_fgm,probe=probe[0],datatype='fgs_btotal',level='l2'
    get_data,'th'+probe[0]+'_fgs_btotal',data=btotal
    store_data,'th'+probe[0]+'_fgs_fce',$
      data={x:btotal.x,y:btotal.y*28.0},dlim={color:1,thick:2}
      
    ;UHR周波数
    tinterpol_mxn,'th'+probe[0]+'_fgs_fce','th'+probe[0]+'_fpe'
    get_data,'th'+probe[0]+'_fgs_fce_interp',data=fce
    get_data,'th'+probe[0]+'_fpe',data=fpe
    store_data,'uhr_freq',$
      data={x:fce.x,y:sqrt(fpe.y^2+fce.y^2)},dlim={color:4,thick:2}
    
    ;日陰補正を行った磁場データの取得
    thm_load_fgm,probe=probe[0],level='l1',datatype='fgl', use_eclipse=2,coord='dsl'
  
    ;artのSSE座標の取得
    art_sse,probe[0]
    
    ;座標系をSSEに変換
    thm_cotrans,'th'+probe[0]+'_fgl',out_coord='sse'
  
    ;磁場データの平均化
    avg_data,'th'+probe[0]+'_fgl',3.0,newname='th'+probe[0]+'_fgl_avg'
    art_calc_bcon,probes=probe[0]
    
    ;load Bt Et data
    thm_load_fft,probe=probe[0],datatype='fff_*',level='l2'

    ;load gse
    thm_load_state,probe=probe[0],datatype='pos',coord='gse'

    ;load elecronic data which sort by pitch angle.
    ;; load ESA L0 and FGM L2 data.
    thm_load_esa_pkt,probe=probe[0],datatype='peef'
    ;; !!! For FGM eclipse correction should not be applied when the data is used to calculate PADs. !!!
    thm_load_fgm,probe=probe[0],level=2,coord='dsl'

    ;; make pitch angle distribution using thm_part_products
    ;; pitch angle distribution for 60-100 eV electrons
    thm_part_products,probe=probe[0],datatype='peef',output='pa',energy=[60,100],mag_name='th'+probe[0]+'_fgl_dsl',suffix='_energy_60-100'

    ;; pitch angle distribution for 300-500 eV electrons
    thm_part_products,probe=probe[0],datatype='peef',output='pa',energy=[300,500],mag_name='th'+probe[0]+'_fgl_dsl',suffix='_energy_300-500'

    ;; make energy-time spectrogram for a specific pitch angle range
    ;; energy-time spectrogram for P.A. range from  0 to 20 deg.
    thm_part_products,probe=probe[0],datatype='peef',output='energy',pitch=[0,20],mag_name='th'+probe[0]+'_fgl_dsl',suffix='_pa_0-20'

    ;; energy-time spectrogram for P.A. range from  70 to 110 deg.
    thm_part_products,probe=probe[0],datatype='peef',output='energy',pitch=[70,110],mag_name='th'+probe[0]+'_fgl_dsl',suffix='_pa_70-110'

    ;; energy-time spectrogram for P.A. range from  160 to 180 deg.
    thm_part_products,probe=probe[0],datatype='peef',output='energy',pitch=[160,180],mag_name='th'+probe[0]+'_fgl_dsl',suffix='_pa_160-180'
    
    ;convert km to re.
    tkm2re,'th'+probe[0]+'_state_pos_gse'
    
    ;store ? data to Et data. 
    store_data,'th'+probe[0]+'_fff_64_eac34_fce',$
      data=['th'+probe[0]+'_fff_64_eac34','th'+probe[0]+'_fgs_fce','uhr_freq']
    
    ;store ? data to Bt data.
    store_data,'th'+probe+'_fff_64_scm2_fce',$
      data=['th'+probe[0]+'_fff_64_scm2','th'+probe[0]+'_fgs_fce']
    
    ylim,'*_fce',1e0,8e3,1
    
    options,'th'+probe[0]+'_fff_64_eac34_fce',$
      ytitle='THM-'+strupcase(probe[0])+' E34!CFrequency!C[Hz]',$
      ztitle='[(V/m)^2/Hz]',ysubtitle=''
    
    options,'th'+probe[0]+'_fff_64_scm2_fce',$
      ytitle='THM-'+strupcase(probe[0])+' SCM2!CFrequency!C[Hz]',$
      ztitle='[(nT)^2/Hz]',ysubtitle=''
    
    zlim,'th'+probe[0]+'_fff_*_e*',1e-14,1e-8,1
    zlim,'th'+probe[0]+'_fff_*_s*',1e-9,1e-4,1
    
    options,'th'+probe[0]+'_state_pos_gse_re',labels=['X','Y','Z'],$
      ytitle='Pos in GSE!C[RE]',thick=2,ysubtitle=''

    options,'th'+probe[0]+'_state_pos_sse_rl',labels=['X','Y','Z'],$
      ytitle='Pos in SSE!C[RL]',thick=2,constant=[-1,0,1]
      
    options,'th'+probe[0]+'_state_pos_sse_rl',labels=['X','Y','Z'],$
      ytitle='Pos in SSE!C[RL]',thick=2,constant=[-1,0,1]
    
    options,'th'+probe[0]+'_state_pos_gse_re',labels=['X','Y','Z'],$
      ytitle='Pos in GSE!C[RE]',thick=2,ysubtitle=''
      
    options,'th'+probe[0]+'_Bcon_flg',panel_size=0.3

    get_timespan,t
    ts=time_struct(t[0])

    tplot_title='THM-'+probe[0]+' '+time_string(t[0])+' - '+time_string(t[1])

    png_fname='th'+probe[0]+$
      string(ts.year,format='(i4)')+string(ts.month,format='(i2.2)')+$
      string(ts.date,format='(i2.2)')+string(ts.hour,format='(i2.2)')+$
      string(ts.min,format='(i2.2)')+string(ts.sec,format='(i2.2)')

    tplot,['th'+probe[0]+'_peef_eflux_energy_pa_0-20','th'+probe[0]+'_peef_eflux_energy_pa_70-110','th'+probe[0]+'_peef_eflux_energy_pa_160-180',$ ;pitch angle
      'th'+probe[0]+'_fff_64_eac34_fce','th'+probe[0]+'_fff_64_scm2_fce',$ ;Et Bt data
      'th'+probe[0]+'_fgl_avg','th'+probe[0]+'_Bcon_flg','th'+probe[0]+'_bdist',$
      'th'+probe[0]+'_state_pos_gse_re','th'+probe[0]+'_state_pos_sse_rl']

    makepng,png_fname
    
  endfor
end