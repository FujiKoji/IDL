;usage:
; To plot ECH waves to get hold when ECH waves is occured.
; art_ech_plot, probe='b', start='2022-01-01',days=31
; when prorgram is stopped, you can make timebar.
; if you want to restart, type '.c'.

; 関数の呼び出し設定
pro art_ech_plot,probe=probe,start=start,days=days

  window,xs=1600,ys=1000
  !p.charsize=1.2
  
  
timespan,start,days,/d

thm_load_esa,probe=probe,datatype='pe?f_en_eflux peef_sc_pot peif_velocity_gse',level='l2'
thm_load_fgm,probe=probe,datatype='fgs_btotal',level='l2'
thm_load_state,probe=probe,datatype='pos',coord='gse'
art_sse,probe
tkm2re,'th'+probe+'_state_pos_gse'

get_data,'th'+probe+'_fgs_btotal',data=btotal

options, 'th'+probe+'_peef_en_eflux',$
  ytitle='THM-'+strupcase(probe)+' !CElectron energy!C[eV]',$
  ztitle='[ev/(cm^2-s-str-eV)]',ysubtitle=''
  
options,'th'+probe+'_peif_en_eflux',$
  ytitle='THM-'+strupcase(probe)+' !CIon energy!C[eV]',$
  ztitle='[ev/(cm^2-s-str-eV)]',ysubtitle=''
  
options,'th'+probe+'_peif_velocity_gse',labels=['X','Y','Z']

options,'th'+probe+'_state_pos_gse_re',labels=['X','Y','Z'],$
  ytitle='Pos in GSE!C[RE]',thick=2,ysubtitle=''

options,'th'+probe+'_state_pos_sse_rl',labels=['X','Y','Z'],$
  ytitle='Pos in SSE!C[RL]',thick=2,constant=[-1,0,1]
  
ylim,'th'+probe[0]+'_peef_en_eflux_pot',1e1,3e4,1
zlim,'th'+probe[0]+'_peef_en_eflux_pot',1e3,1e9,1
zlim,'th'+probe[0]+'_peif_en_eflux',1e3,1e8,1

tplot,['th'+probe+'_peif_en_eflux','th'+probe+'_peef_en_eflux_pot',$
  'th'+probe+'_peif_velocity_gse',$
  'th'+probe+'_state_pos_gse_re','th'+probe+'_state_pos_sse_rl']

stop

ts=time_struct(start)
png_fname='th'+probe+'_plot_ECH_'+$
  string(ts.year,format='(i4)')+string(ts.month,format='(i2.2)')
  
makepng,png_fname
end