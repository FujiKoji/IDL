pro art_sse, probe

; - define a lunar radius
Rl = 1738.0 ;km

; - load sc state data
thm_load_state, probe=probe, /get_support, coord='gse'

; - fix to not appending the _gse to the pos and vel data
get_data,'th'+strtrim(probe,2)+'_state_pos',data = d, lim=l, dlim=dl
get_data,'th'+strtrim(probe,2)+'_state_vel',data = vd, lim=vl, dlim=vdl

store_data,'th'+strtrim(probe,2)+'_state_pos_gse', data=d, lim=l, dlim=dl
store_data,'th'+strtrim(probe,2)+'_state_vel_gse', data=vd, lim=vl, dlim=vdl

; - load the SPICE kernel data
thm_load_slp

; - convert the sc position from GSE to SSE
thm_cotrans, probe = probe, $
                     datatype = 'state_pos_gse', $
                     in_coord = 'gse', $
                     out_coord = 'sse', $
;                    in_suffix = '_gse', $
                     out_suffix = '_sse'

; - convert the sc velocity from GSE to SSE
thm_cotrans, probe = probe, $
;		     datatype = 'state_vel_gse', $
		     datatype = 'state_vel', $
		     in_coord = 'gse', $
		     out_coord = 'sse', $
		     in_suffix = '_gse', $
		     out_suffix = '_sse'

; - calculate the distances in Rl and store into a variable
get_data, 'th'+strtrim(probe[0],2)+'_state_pos_gse_sse', data = d, limits=l, dlimits=dl
alt = SQRT(d.y[*,0]^2 + d.y[*,1]^2 + d.y[*,2]) - Rl
; - bug fix below, AP, 12/2/11
d.y = d.y/Rl; - 1.
dl.data_att.units = 'Rl'
store_data, 'th'+strtrim(probe[0],2)+'_state_pos_sse_rl', data = d, limits=l, dlimits=dl

; - calculate the net altitude above the Moon and store for both km and Rl
dalt = {x:d.x, y:alt, v:d.v}
store_data, 'th'+strtrim(probe[0],2)+'_alt',data=dalt
daltrl = {x:d.x, y:alt/Rl, v:d.v}
store_data, 'th'+strtrim(probe[0],2)+'_alt_rl', data=daltrl

end
