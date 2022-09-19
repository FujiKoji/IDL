;+
; Procedure art_make_ql_find_ech_v00
;
; Usage:
;  To make QL plots to find ECH waves on 2022-03-20:
;  art_make_ql_find_ech_v00,probe='b',start='2022-03-20',days=1
;-   ctime,tt  timebar,tt,thick=3

;関数の呼び出し設定
pro art_make_ql_find_ech_v02,probe=probe,start=start,days=days

  window,xs=1600,ys=1000
  !p.charsize=1.2
  loop_in_day=12; 4 hour intervals

  for ii=0.,days-1 do begin

    timespan,time_double(start)+ii*86400.0,1,/d

    thm_load_esa,probe=probe,datatype='pe?f_en_eflux peef_sc_pot peif_velocity_gse',level='l2'
    thm_load_fft,probe=probe,datatype='fff_*',level='l2'
    thm_load_fgm,probe=probe,datatype='fgs_btotal',level='l2'
    

    thm_load_state,probe=probe,datatype='pos',coord='gse'
    art_sse,probe
    tkm2re,'th'+probe+'_state_pos_gse'

    get_data,'th'+probe[0]+'_fgs_btotal',data=btotal
    store_data,'th'+probe[0]+'_fgs_fce',data={x:btotal.x,y:btotal.y*28.0},dlim={color:1,thick:2}

    ; store_data,'th'+probe[0]+'_fff_64_eac12_fce',$
    ;   data=['th'+probe+'_fff_*_eac12','th'+probe+'_fgs_fce']

    store_data,'th'+probe[0]+'_fff_64_eac34_fce',$
      data=['th'+probe+'_fff_64_eac34','th'+probe+'_fgs_fce']

    store_data,'th'+probe[0]+'_fff_*_eac56_fce',$
      data=['th'+probe+'_fff_64_eac56','th'+probe+'_fgs_fce']

    ; store_data,'th'+probe[0]+'_fff_64_scm1_fce',$
    ;   data=['th'+probe+'_fff_64_scm1','th'+probe+'_fgs_fce']

    ;store_data,'th'+probe[0]+'_fff_64_scm2_fce',$
      ;data=['th'+probe+'_fff_64_scm2','th'+probe+'_fgs_fce']

    ;store_data,'th'+probe[0]+'_fff_64_scm3_fce',$
      ;data=['th'+probe+'_fff_64_scm3','th'+probe+'_fgs_fce']

    ylim,'*_fce',1e0,4e3,1

    options,'th'+probe+'_peef_en_eflux',$
      ytitle='THM-'+strupcase(probe)+' !CElectron energy!C[eV]',$
      ztitle='[ev/(cm^2-s-str-eV)]',ysubtitle=''

    options,'th'+probe+'_peif_en_eflux',$
      ytitle='THM-'+strupcase(probe)+' !CIon energy!C[eV]',$
      ztitle='[ev/(cm^2-s-str-eV)]',ysubtitle=''

    options,'th'+probe+'_fff_*_e*12',$
      ytitle='THM-'+strupcase(probe)+' E12!CFrequency!C[Hz]',$
      ztitle='[(V/m)^2/Hz]',ysubtitle=''

    options,'th'+probe+'_fff_*_e*34',$
      ytitle='THM-'+strupcase(probe)+' E34!CFrequency!C[Hz]',$
      ztitle='[(V/m)^2/Hz]',ysubtitle=''

    options,'th'+probe+'_fff_*_e*56',$
      ytitle='THM-'+strupcase(probe)+' E56!CFrequency!C[Hz]',$
      ztitle='[(V/m)^2/Hz]',ysubtitle=''

    zlim,'th'+probe+'_fff_*_e*',1e-14,1e-8,1

    options,'th'+probe+'_state_pos_gse_re',labels=['X','Y','Z'],$
      ytitle='Pos in GSE!C[RE]',thick=2,ysubtitle=''

    options,'th'+probe+'_state_pos_sse_rl',labels=['X','Y','Z'],$
      ytitle='Pos in SSE!C[RL]',thick=2,constant=[-1,0,1]
      
    options,'th'+probe+'_peif_velocity_gse',labels=['X','Y','Z']

    store_data,'th'+probe[0]+'_peef_en_eflux_pot',$
      data=['th'+probe[0]+'_peef_en_eflux','th'+probe[0]+'_peef_sc_pot']

    ylim,'th'+probe[0]+'_peef_en_eflux_pot',1e1,3e4,1
    zlim,'th'+probe[0]+'_peef_en_eflux_pot',1e3,1e9,1
    zlim,'th'+probe[0]+'_peif_en_eflux',1e3,1e8,1

    for jj=0.,loop_in_day-1 do begin

      timespan,time_double(start)+ii*86400.0+jj*86400.0/loop_in_day,86400.0/loop_in_day,/sec

      get_timespan,t
      ts=time_struct(t[0])

      tplot_title='THM-'+probe+' '+time_string(t[0])+' - '+time_string(t[1])

      png_fname='th'+probe+'_find_ECH_QL_'+$
        string(ts.year,format='(i4)')+string(ts.month,format='(i2.2)')+$
        string(ts.date,format='(i2.2)')+string(ts.hour,format='(i2.2)')+$
        string(ts.min,format='(i2.2)')+string(ts.sec,format='(i2.2)')

      tplot,['th'+probe+'_peif_en_eflux','th'+probe+'_peef_en_eflux_pot',$
        'th'+probe+'_peif_velocity_gse',$
        'th'+probe+'_state_pos_gse_re','th'+probe+'_state_pos_sse_rl']

      makepng,png_fname

    endfor
  endfor

end