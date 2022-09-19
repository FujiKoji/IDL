;; Procedure:  art_calc_bcon
;;
;; Purpose: Calculates B connection btween s/c and the Moon
;;
;; Keywords:
;;  probe = probe name array
;;
;; Example: 
;;  art_calc_bcon,probes=['b','c']
;;
;; Notes:
;; Created by Yuki Harada on 2014-02-20
;;  - modified from 'art_bconnect_bres.pro' written by Andrew
;;  - 'th?_state_pos_sse' & 'th?_fgs_sse' should have been stored
;;  - SPICE kernel data should have been loaded by 'thm_load_slp'

pro art_calc_bcon, probes=probes

rL = 1738.                    ;- km

for i_probe=0,n_elements(probes)-1 do begin

   get_data,'th'+strtrim(probes[i_probe],2)+'_state_pos_sse',sctime,scpos

;   get_data,'th'+strtrim(probes[i_probe],2)+'_fgs_sse',btime,bvec
   get_data,'th'+strtrim(probes[i_probe],2)+'_fgl_avg',btime,bvec
   ; - interpolate the position times to find the closest B-field measurement
   scinterp = dblarr(3,n_elements(btime))
   ; - define time relative to the first position measurement
   brel_time = btime - btime[0]
   screl_time = sctime - btime[0]

   ; - loop through all the b-field measurements
   ; - and interpolate the s/c position
;;    for i_b=0ll,n_elements(brel_time)-1 do begin
;;       ; - check to make sure that there are sc measurements on both
;;       ; - sides of the b-field measurement for interpolation
;;       idxlower  = where( screl_time LT brel_time[i_b], lowcnt )
;;       idxhigher = where( screl_time GT brel_time[i_b], hicnt )
;;       if (lowcnt GT 0) AND (hicnt GT 0) then begin
;;          scinterp[0,i_b] = interpol(scpos[*,0],screl_time,brel_time[i_b])
;;          scinterp[1,i_b] = interpol(scpos[*,1],screl_time,brel_time[i_b])
;;          scinterp[2,i_b] = interpol(scpos[*,2],screl_time,brel_time[i_b])
;;       endif else begin
;;          scinterp[*,i_b] = !values.f_nan
;;       endelse
;;    endfor

   ;- just interpolate (much faster)
   scinterp[0,*] = interpol(scpos[*,0],screl_time,brel_time)
   scinterp[1,*] = interpol(scpos[*,1],screl_time,brel_time)
   scinterp[2,*] = interpol(scpos[*,2],screl_time,brel_time)


   ; - loop through bvectors and see if they intersect the Moon
   xt = dblarr(20000) & yt = dblarr(20000) & zt = dblarr(20000)
   bflag = dblarr(n_elements(brel_time))
   bdist = {x:dblarr(n_elements(brel_time)),y:dblarr(n_elements(brel_time))}
   bimpact = {x:dblarr(n_elements(brel_time)),y:dblarr(n_elements(brel_time))}
   surfloc = {x:dblarr(n_elements(brel_time)) $
              ,y:dblarr(3,n_elements(brel_time))}
   belev = {x:dblarr(n_elements(brel_time)),y:dblarr(n_elements(brel_time))}
   Bcon_flg = {x:dblarr(n_elements(brel_time)), $
               y:intarr(n_elements(brel_time),2),v:[0,1],spec:1}

   for ll=0LL,n_elements(brel_time)-1 do begin
      if ll mod 1000 eq 0 then print,'art_calc_bcon:',ll,'/',n_elements(brel_time)-1
      bdist.x[ll]   = brel_time[ll] + btime[0]
      bimpact.x[ll] = brel_time[ll] + btime[0]
      surfloc.x[ll] = brel_time[ll] + btime[0]
      belev.x[ll] = brel_time[ll] + btime[0]
      Bcon_flg.x[ll] = brel_time[ll] + btime[0]
      
      bhat = [ bvec[ll,0], bvec[ll,1], bvec[ll,2] ] $
             / SQRT( bvec[ll,0]^2 + bvec[ll,1]^2 + bvec[ll,2]^2 ) 
      t = findgen(20000) * 1e-2 - 100.0
      xt = scinterp[0,ll]/rL + bhat[0]*t
      yt = scinterp[1,ll]/rL + bhat[1]*t
      zt = scinterp[2,ll]/rL + bhat[2]*t

      dist   = SQRT( xt^2 + yt^2 + zt^2 )
      scdist = SQRT( scinterp[0,ll]^2 + scinterp[1,ll]^2 + scinterp[2,ll]^2 )

      if min(dist,i_min) LE 1.0 then begin
         bflag[ll] = 1.
         sc_alt = scdist - rL
         bdist.y[ll] = sc_alt
         if i_min lt 10000 then Bcon_flg.y[ll,*] = 1 ;- anti-para connection
         if i_min ge 10000 then Bcon_flg.y[ll,*] = 2 ;- parallel connection

         ;- determine location on lunar surface
         surfdist = dist - 1.0
         surfidx = where( surfdist LT 0.0, surfcnt)
         endidx = [ surfidx[0], surfidx(surfcnt-1) ]
         endt = t(endidx)
         if endt[0] LT 0 then endidx = endidx[1] else endidx = endidx[0]
         endidx = endidx + indgen(3) - 1
         ; - interpolate to get the exact {x,y,z} where the B-field
         ; - pierces the surface
         surfloc.y[0,ll] = INTERPOL( xt(endidx), surfdist(endidx), 0.0 ) 
         surfloc.y[1,ll] = INTERPOL( yt(endidx), surfdist(endidx), 0.0 ) 
         surfloc.y[2,ll] = INTERPOL( zt(endidx), surfdist(endidx), 0.0 ) 

         ; - calculate the distance from s/c to Moon along field line
         bimpact.y[ll] = SQRT( ( scinterp[0,ll]/rL - surfloc.y[0,ll])^2 + $
                               ( scinterp[1,ll]/rL - surfloc.y[1,ll])^2 + $
                               ( scinterp[2,ll]/rL - surfloc.y[2,ll])^2 )

         ;- calculate the elevation angle of B
         belev.y[ll] = (!dpi/2. - ACOS( bhat[0]*surfloc.y[0,ll] $
                                       + bhat[1]*surfloc.y[1,ll] $
                                       + bhat[2]*surfloc.y[2,ll] ))*!radeg

         sza   = ACOS( surfloc.y[0,ll] ) * !radeg
         if sza LT 90.0 then $
            print,"CONNECTED DAYSIDE: ",time_string(btime[ll]),' ' $
                  ,strtrim(sc_alt,2)+' km ('+strtrim(sc_alt/rL,2)+' rL)' $
                  +' SZA: '+string(sza,format='(i3)')
         if sza GT 90.0 then $
            print,"CONNECTED NIGHTSIDE: ",time_string(btime[ll]),' ' $
                  , strtrim(sc_alt,2)+' km ('+strtrim(sc_alt/rL,2)+' rL)' $
                  +' SZA: '+string(sza,format='(i3)')
      endif else begin
         bflag[ll] = 0.
         bdist.y[ll] = !values.f_nan
         bimpact.y[ll] = !values.f_nan
         surfloc.y(*,ll) = !values.f_nan
         belev.y[ll] = !values.f_nan
         Bcon_flg.y[ll,*] = 0
      endelse
   endfor

   ; - store Bcon_flg, 0 for non-con, 1 for anti-para-con, 2 for para-con
   store_data,'th'+strtrim(probes[i_probe],2)+'_Bcon_flg', data=Bcon_flg

   ; - store the time v. mag connected altitude as a tplot var
   bdist_dataname = 'th'+strtrim(probes[i_probe],2)+'_bdist'
   bdist.y = bdist.y / rL
   store_data,bdist_dataname, data=bdist

   bimpact_dataname = 'th'+strtrim(probes[i_probe],2)+'_bimpact'
   store_data,bimpact_dataname, data=bimpact

   ; - calculate the phi, theta, alpha (sza) of the connected point
   theta = ACOS( surfloc.y[2,*] ) - !dpi/2.
   phi   = ATAN( surfloc.y[1,*], surfloc.y[0,*] )
   sza   = ACOS( surfloc.y[0,*] )

   angles = {x:dblarr(n_elements(brel_time)),y:dblarr(n_elements(brel_time),3)}
   angles.x = brel_time + btime[0]
   angles.y[*,0] = theta * !radeg
   angles.y[*,1] = phi * !radeg
   angles.y[*,2] = sza * !radeg

   anglesdl = {spec:0, log:0, labels:['theta','phi','sza'],labflag:1}
   angles_datanames = 'th'+strtrim(probes[i_probe],2)+'_bconnect_angles'
   store_data,angles_datanames,data=angles,dlim=anglesdl

   ; - store the time v. mag connected surface location as a tplot var
   surfloc_tmp $
      = {x:dblarr(n_elements(brel_time)),y:dblarr(n_elements(brel_time),3)}
   surfloc_tmp.x = surfloc.x
   for i_tmp=0,2 do begin
      surfloc_tmp.y(*,i_tmp) = surfloc.y(i_tmp,*)
   endfor
   surflocdl = {spec:0, log:0, labels:['x','y','z'],labflag:1}
   store_data,'th'+strtrim(probes[i_probe],2)+'_bconnect_surfloc_sse' $
              ,data=surfloc_tmp,dlim=surflocdl

   thm_cotrans,'th'+strtrim(probes[i_probe],2)+'_bconnect_surfloc' $
               ,in_coord ='sse',out_coord='sel' $
               ,in_suffix = '_sse',out_suffix = '_sel'

   get_data,'th'+strtrim(probes[i_probe],2)+'_bconnect_surfloc_sel' $
            ,data=loc

   ; - calculate the lat, lon of the connected point
   lat = !dpi/2. - ACOS( loc.y[*,2] )
   lon = ATAN( loc.y[*,1], loc.y[*,0] )

   latlon = {x:dblarr(n_elements(loc.x)), y:dblarr(n_elements(loc.x),2)}
   latlon.x = loc.x
   latlon.y[*,0] = lat * !radeg
   latlon.y[*,1] = lon * !radeg

   latlondl = {spec:0, log:0, labels:['lat','lon'],labflag:1}
   latlon_datanames = 'th'+strtrim(probes[i_probe],2)+'_bconnect_latlon'
   store_data,latlon_datanames,data=latlon,dlim=latlondl


   belevdl = {spec:0, log:0, labels:['belev'],labflag:1, color:50}
   belev_datanames = 'th'+strtrim(probes[i_probe],2)+'_bconnect_belev'
   store_data,belev_datanames,data=belev,dlim=belevdl


endfor ;- i_probe


end
