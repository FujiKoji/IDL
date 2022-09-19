;関数の呼び出し設定
pro art_b_pitch,probe=probe,start=start,hours=hours

window,xs=1600,ys=1000
!p.charsize=1.2

timespan, start,hours,/h
;load L2 FGM data, which is corrected for eclipse effect
thm_load_fgm,probe=probe,level='l2',datatype='fgl',coord='dsl',suffix='_uncorrected'
;日陰補正を行った磁場データの取得
thm_load_fgm,probe=probe,level='l1',datatype='fgl', use_eclipse=2,coord='dsl'


tplot,['thc_fgl_dsl_uncorrected','thc_fgl']
stop

;artのSSE座標の取得
art_sse,probe
;座標系をSSEに変換
thm_cotrans,'th_fgl',out_coord='sse'
thm_cotrans,'thc_fgl_dsl_uncorrected',out_coord='sse'
;磁場データの平均化
avg_data,'thc_fgl',3.0,newname='thc_fgl_avg'
art_calc_bcon,probes=probe
tplot,['thc_fgl_dsl_uncorrected','thc_fgl','thc_Bcon_flg','thc_bdist']

end