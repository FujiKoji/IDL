;+
; Procedure art_make_ql_find_ech_v00
; 
; Usage: 
;  To make QL plots to find ECH waves on 2022-03-20:
;  art_make_ql_find_ech_v00,probe='b',start='2022-03-20',days=1
;-

pro art_make_ql_find_ech_v00,probe=probe,start=start,days=days

window,xs=1600,ys=1000
!p.charsize=1.2
loop_in_day=6; 4 hour intervals

;stop

for ii=0.,days-1 do begin

	timespan,time_double(start)+ii*86400.0,1,/d

	thm_load_esa,probe=probe,datatype='pe?f_en_eflux',level='l2'
	thm_load_fft,probe=probe,datatype='fff_*',level='l2'
	thm_load_state,probe=probe,datatype='pos',coord='gse'
	art_sse,probe
	tkm2re,'th'+probe+'_state_pos_gse'

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

	options,'th'+probe+'_fff_*_s*1',$
		ytitle='THM-'+strupcase(probe)+' SCM1!CFrequency!C[Hz]',$
		ztitle='[(nT)^2/Hz]',ysubtitle=''

	options,'th'+probe+'_fff_*_s*2',$
		ytitle='THM-'+strupcase(probe)+' SCM2!CFrequency!C[Hz]',$
		ztitle='[(nT)^2/Hz]',ysubtitle=''

	options,'th'+probe+'_fff_*_s*3',$
		ytitle='THM-'+strupcase(probe)+' SCM3!CFrequency!C[Hz]',$
		ztitle='[(nT)^2/Hz]',ysubtitle=''

	zlim,'th'+probe+'_fff_*_e*',1e-14,1e-8,1
	zlim,'th'+probe+'_fff_*_s*',1e-9,1e-4,1

	options,'th'+probe+'_state_pos_gse_re',labels=['X','Y','Z'],$
			ytitle='Pos in GSE!C[RE]',thick=2,ysubtitle=''

	options,'th'+probe+'_state_pos_sse_rl',labels=['X','Y','Z'],$
			ytitle='Pos in SSE!C[RL]',thick=2,constant=[-1,0,1]

	for jj=0.,loop_in_day-1 do begin

		timespan,time_double(start)+ii*86400.0+jj*86400.0/loop_in_day,86400.0/loop_in_day,/sec

		get_timespan,t
		ts=time_struct(t[0])

		tplot_title='THM-'+probe+' '+time_string(t[0])+' - '+time_string(t[1])

		png_fname='th'+probe+'_find_ECH_QL_'+$
					string(ts.year,format='(i4)')+string(ts.month,format='(i2.2)')+$
					string(ts.date,format='(i2	.2)')+string(ts.hour,format='(i2.2)')+$
					string(ts.min,format='(i2.2)')+string(ts.sec,format='(i2.2)')

		tplot,['th'+probe+'_pe?f_en_eflux',$
				 'th'+probe+'_fff_*_e*','th'+probe+'_fff_*_s*',$
				 'th'+probe+'_state_pos_gse_re','th'+probe+'_state_pos_sse_rl']

		makepng,png_fname

	endfor
endfor

end