pro judge_ech,probe=probe,start=start,days=days
  for ii=0.,days-1 do begin
    for mm=0.,11 do begin
      judge = 0
      
      timespan,time_double(start)+ii*86400+mm*7200.0,2,/h
      thm_load_fft,probe=probe[0],datatype='fff_*',level='l2'
      
      ;fpe周波数
      thm_load_esa,probe=probe[0],datatype='peif_density'
      get_data,'th'+probe[0]+'_peif_density',data=i_density
      if typename(i_density) eq 'ANONYMOUS' then begin
        store_data,'th'+probe[0]+'_fpe',$
          data={x:i_density.x,y:9000*sqrt(i_density.y)}
        
        ;fce周波数
        thm_load_fgm,probe=probe[0],datatype='fgs_btotal',level='l2'
        get_data,'th'+probe[0]+'_fgs_btotal',data=btotal
        print,typename(btotal)
        if typename(btotal) eq 'ANONYMOUS' then begin
          store_data,'fce_freq',$
            data={x:btotal.x,y:btotal.y*28.0},dlim={color:1,thick:2}
          get_data,'fce_freq',data=fce_para
          
          ;UHR周波数
          tinterpol_mxn,'fce_freq','th'+probe[0]+'_fpe' ;要素数を合わせる
          get_data,'fce_freq_interp',data=fce
          get_data,'th'+probe[0]+'_fpe',data=fpe
          store_data,'uhr_freq',$
            data={x:fpe.x,y:sqrt(fpe.y^2+fce.y^2)},dlim={color:4,thick:2}
          get_data,'uhr_freq',data=uhr_para
          
      ;    tinterpol_mxn,'uhr_freq','th'+probe[0]+'_fff_64_eac34'
      ;    get_data,'th'+probe[0]+'_fff_64_eac34_interp',data=d
          get_data,'th'+probe[0]+'_fff_64_eac34',data=d
  
          print,'type'
          print,typename(d)
          if typename(d) eq 'ANONYMOUS' then begin
            for jj=0.,n_elements(d.x)-1 do begin
              flag=0
              nodata_index = where(finite(d.y[jj,*])eq 0)
              d.y[jj,nodata_index] = 0
              
              fce_index=nn(fce,d.x[jj])
              uhr_index=nn(uhr_para,d.x[jj])
              fce_num=fce.y[fce_index]
              uhr_num=uhr_para.y[uhr_index]
              
              mark_arr_fce=findgen(n_elements(d.v))
              mark_arr_fce[*]=0
              
              mark_arr_fce_half=findgen(n_elements(d.v))
              mark_arr_fce_half[*]=0
              
              if uhr_num LT 1e4 then begin
                if fce_num GT 1e2 then begin
                  for kk=1.,fix(uhr_num/fce_num) do begin
                    x_fce_1=nn(d.v,fce_num*kk)
                    x_fce_2=nn(d.v,fce_num*(kk+1))
                    x_fce_half=nn(d.y[jj,*],d.y[jj,x_fce_1:x_fce_2].max())
            
                    y_fce_1=d.y[jj,x_fce_1]
                    y_fce_2=d.y[jj,x_fce_2]
                    y_fce_half=d.y[jj,x_fce_half]
                    
                    mark_arr_fce[x_fce_1]=y_fce_1
                    mark_arr_fce[x_fce_2]=y_fce_2
                    
                    mark_arr_fce_half[x_fce_half]=y_fce_half
                    
        ;            if (y_fce_1/y_fce_half GT 10) and (y_fce_2/y_fce_half GT 10) then begin
        ;              flag+=1
        ;            endif
                    if (y_fce_half/y_fce_1 GT 10) and (y_fce_half/y_fce_2 GT 10) then begin
                      flag+=1
                    endif
                  endfor
                  x_uhr=nn(d.v,uhr_num)
                  y_uhr=d.y[jj,x_uhr]
                  max_val=max(d.y[jj,x_uhr:*])
                  
;                  plot,d.v,d.y[jj,*],/ylog,title='fce:'+strupcase(fce_num)+'fuhr:'+strupcase(uhr_num)+'flag:'+strupcase(flag),xrange=[0,4000]
;                  oplot,d.v,mark_arr_fce,psym=2
;                  oplot,d.v,mark_arr_fce_half,psym=4
            
                  ts=time_struct(d.x[jj])
                  png_fname=string(ts.year,format='(i4)')+string(ts.month,format='(i2.2)')+$
                    string(ts.date,format='(i2.2)')+string(ts.hour,format='(i2.2)')+$
                    string(ts.min,format='(i2.2)')+string(ts.sec,format='(i2.2)')
                  
;                  makepng,'judge_ech_png/'+png_fname
                  
                  if flag GE 1 then begin
                    judge+=1
                  endif
                endif
              endif
            endfor
            
            if judge GE 60 then begin
              options,'thb_fff_64_eac34',title=strupcase(fix(judge))
              tplot,['thb_fff_64_eac34']
              makepng,'ech_sepa/'+png_fname
            endif
          endif ;i_density
        endif ;d
      endif ;btotal 
    endfor ; time
  endfor ; day
end