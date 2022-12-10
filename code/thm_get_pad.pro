pro thm_get_pad,probe=sc,typ=typ,trange=trange,dist=dist,pad_str=pad_str,pa_avg=pa_avg

trange=time_double(trange)
thm_load_state,probe=sc,/get_support
thm_load_fgm,probe=sc,datatype='fgs',coord='dsl',level=2,trange=trange
mag_data='th'+sc+'_fgs_dsl'
esadata=thm_part_dist_array(probe=sc,typ=typ,trange=trange,mag_data=mag_data)
data=*esadata[0]

thm_pgs_make_fac,data.time,'th'+sc+'_fgs_dsl','th'+sc+'_state_pos',sc,fac_output=fac_mat,fac_type='xgse'
dist=data

if not keyword_set(pa_avg) then begin

	pad=fltarr(n_elements(dist),dist(0).nenergy,88)
	pa=fltarr(n_elements(dist),dist(0).nenergy,88)
	energy=fltarr(n_elements(dist),dist(0).nenergy,88)

endif else begin

	pad=fltarr(n_elements(dist),dist(0).nenergy,16)
	pa=fltarr(n_elements(dist),dist(0).nenergy,16)
	energy=fltarr(n_elements(dist),dist(0).nenergy,16)

endelse

for ii=0L,n_elements(data)-1 do begin

	spd_pgs_do_fac,data[ii],reform(fac_mat[ii,*,*],[3,3]),output=dist_tmp,error=error
	thm_convert_esa_units,dist_tmp,'eflux'
	dist[ii]=dist_tmp

	for jj=0.,dist(0).nenergy-1 do begin


		if keyword_set(pa_avg) then begin

			ind=where(finite(dist[ii].data[jj,*]) eq 1)
			bin1d,reform(90-dist[ii].theta[jj,ind]),reform(dist[ii].data[jj,ind]),0,180,22.5/2.0,kinbin,pa0,avg
			pad[ii,jj,*]=avg
			pa[ii,jj,*]=pa0
			energy[ii,jj,*]=dist(ii).energy[jj,0:15]

		endif else begin

			pa[ii,jj,*]=reform(90-dist[ii].theta[jj,*])
			ind=sort(pa[ii,jj,*])
			pa[ii,jj,*]=pa[ii,jj,ind]
			pad[ii,jj,*]=dist[ii].data[jj,ind]
			energy[ii,jj,*]=dist(ii).energy[jj,*]

		endelse
	endfor
endfor

pad_str={x:dist.time,y:pad,v1:pa,v2:energy}

end
