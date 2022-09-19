;関数の呼び出し設定
pro art_b_flag,probe=probe,start=start,hours=hours

window,xs=1600,ys=1000
!p.charsize=1.2

timespan, start,hours,/h
;load L2 FGM data, which is corrected for eclipse effect
thm_load_fgm,probe=probe,level='l2',datatype='fgl',coord='dsl',suffix='_uncorrected'
;日陰補正を行った磁場データの取得
thm_load_fgm,probe=probe,level='l1',datatype='fgl', use_eclipse=2,coord='dsl'


tplot,['th'+probe+'_fgl']
stop

;artのSSE座標の取得
art_sse,probe
;座標系をSSEに変換
thm_cotrans,'th'+probe+'_fgl',out_coord='sse'
thm_cotrans,'th'+probe+'_fgl_dsl_uncorrected',out_coord='sse'
;磁場データの平均化
avg_data,'th'+probe+'_fgl',3.0,newname='th'+probe+'_fgl_avg'
art_calc_bcon,probes=probe
tplot,['th'+probe+'_fgl','th'+probe+'_Bcon_flg','th'+probe+'_bdist']

end