pro art_make_pad_mod,probe=probe,trange=trange,hours=hours


timespan,trange,hours,/h

;; load ESA L0 and FGM L2 data. 
thm_load_esa_pkt,probe=probe,datatype='peef'
;; !!! For FGM eclipse correction should not be applied when the data is used to calculate PADs. !!!
thm_load_fgm,probe=probe,level=2,coord='dsl'
art_sse,probe

;; make pitch angle distribution using thm_part_products
;; pitch angle distribution for 60-100 eV electrons
thm_part_products,probe=probe,datatype='peef',output='pa',energy=[60,100],mag_name='th'+probe+'_fgl_dsl',suffix='_energy_60-100'

;; pitch angle distribution for 300-500 eV electrons
thm_part_products,probe=probe,datatype='peef',output='pa',energy=[300,500],mag_name='th'+probe+'_fgl_dsl',suffix='_energy_300-500'



;; make energy-time spectrogram for a specific pitch angle range
;; energy-time spectrogram for P.A. range from  0 to 20 deg.
thm_part_products,probe=probe,datatype='peef',output='energy',pitch=[0,20],mag_name='th'+probe+'_fgl_dsl',suffix='_pa_0-20'

;; energy-time spectrogram for P.A. range from  70 to 110 deg.
thm_part_products,probe=probe,datatype='peef',output='energy',pitch=[70,110],mag_name='th'+probe+'_fgl_dsl',suffix='_pa_70-110'

;; energy-time spectrogram for P.A. range from  160 to 180 deg.
thm_part_products,probe=probe,datatype='peef',output='energy',pitch=[160,180],mag_name='th'+probe+'_fgl_dsl',suffix='_pa_160-180'

end