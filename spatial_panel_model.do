clear all
import delimited "data_log_f.csv"
save data_log_f.dta, replace
 
spatwmat using  "W_d700.dta",name(w)
use "data_f_z.dta"

global ylist meanch
global xlist countcon meanls meannl meangdp meanitn
xtset objectid year

xsmle $ylist $xlist,fe model(sdm) wmat(w) type(time) nolog noeffects
est store sdm_a
xsmle $ylist $xlist,fe model(sar) wmat(w) type(time) nolog noeffects
est store sar_a
xsmle $ylist $xlist,fe model(sem) emat(w) type(time) nolog noeffects
est store sem_a

lrtest sdm_a sar_a
lrtest sdm_a sem_a


xsmle $ylist $xlist,fe model(sdm) wmat(w) type(both) nolog noeffects
est store both
xsmle $ylist $xlist,fe model(sdm) wmat(w) type(ind) nolog noeffects
est store ind
xsmle $ylist $xlist,fe model(sdm) wmat(w) type(time) nolog noeffects
est store time
xsmle $ylist $xlist,fe model(sar) wmat(w) type(time) nolog noeffects
est store sar_a
xsmle $ylist $xlist,fe model(sem) emat(w) type(time) nolog noeffects
est store sem_a


spatwmat using  "w_500.dta",name(w)
xsmle $ylist $xlist,fe model(sdm) wmat(w) type(time) nolog noeffects
est store d500
spatwmat using  "w_d1400.dta",name(w)
xsmle $ylist $xlist,fe model(sdm) wmat(w) type(time) nolog noeffects
est store d1400
spatwmat using  "w_k_4.dta",name(w)
xsmle $ylist $xlist,fe model(sdm) wmat(w) type(time) nolog noeffects
est store k4
spatwmat using  "w_k_8.dta",name(w)
xsmle $ylist $xlist,fe model(sdm) wmat(w) type(time) nolog noeffects
est store k8
spatwmat using  "w_eco.dta",name(w)
xsmle $ylist $xlist,fe model(sdm) wmat(w) type(time) nolog noeffects
est store eco
spatwmat using  "w_inv.dta",name(w)
xsmle $ylist $xlist,fe model(sdm) wmat(w) type(time) nolog noeffects
est store inv

save "dta_all.dta", replace

xsmle $ylist $xlist,fe model(sdm) wmat(w) type(both) nolog noeffects
est store both
est restore both
outreg2 using panel_results.doc, replace ctitle(both) dec(5) 
xsmle $ylist $xlist,fe model(sdm) wmat(w) type(time) nolog noeffects
est store time
est restore time
outreg2 using  panel_results.doc, append ctitle(time) dec(5)
xsmle $ylist $xlist,fe model(sdm) wmat(w) type(ind) nolog noeffects
est store ind
est restore ind
outreg2 using  panel_results.doc, append ctitle(ind) dec(3)
xsmle $ylist $xlist,fe model(sar) wmat(w) type(time) nolog noeffects
est store sar_a
est restore sar_a
outreg2 using  panel_results.doc, append ctitle(sar) dec(3)
xsmle $ylist $xlist,fe model(sem) emat(w) type(time) nolog noeffects
est store sem_a
est restore sem_a
outreg2 using  panel_results.doc, append ctitle(s) dec(3)


est restore both
esttab both time ind sar_a sem_a using panel_results.csv, replace mtitles(both time ind sar sem) b(%9.4f) se(%9.4f) scalars("rho Rho" "sigma2_e Sigma2_e") coeflabels(countcon "Conflict" meanls "Population" meannl "Nightlight" meangdp "Income" meanitn "ITN") csv star(* 0.10 ** 0.05 *** 0.01) addnotes("z, p, and ci values are in separate files: panel_results_z.csv, panel_results_p.csv, panel_results_ci.csv. Adjust to two significant decimals manually.")
esttab both time ind sar_a sem_a using panel_results_z.csv, replace mtitles(both time ind sar sem) b(%9.4f) z(%9.4f) coeflabels(countcon "Conflict" meanls "Population" meannl "Nightlight" meangdp "Income" meanitn "ITN") csv star(* 0.10 ** 0.05 *** 0.01)
esttab both time ind sar_a sem_a using panel_results_p.csv, replace mtitles(both time ind sar sem) b(%9.4f) p(%9.4f) coeflabels(countcon "Conflict" meanls "Population" meannl "Nightlight" meangdp "Income" meanitn "ITN") csv star(* 0.10 ** 0.05 *** 0.01)
esttab both time ind sar_a sem_a using panel_results_ci.csv, replace mtitles(both time ind sar sem) b(%9.4f) ci(%9.4f) coeflabels(countcon "Conflict" meanls "Population" meannl "Nightlight" meangdp "Income" meanitn "ITN") csv star(* 0.10 ** 0.05 *** 0.01)




lrtest both time,df(14)
lrtest both ind,df(14)

xsmle $ylist $xlist,wmat(w) model(sdm) fe type(ind) vce(cluster id) nolog
test [Wx]x1 =[Wx]x2 =[Wx]x3 =[Wx]x4 =[Wx]x5 =[Wx]x6 =[Wx]x7 =0
testnl ([Wx]ded = -[Spatial]rho*[Main]ded) ([Wx]dotw = -[Spatial]rho*[Main]dotw) ([Wx]ilfa = -[Spatial]rho*[Main]ilfa) ([Wx]fdl = -[Spatial]rho*[Main]fdl) ([Wx]pgdp = -[Spatial]rho*[Main]pgdp) ([Wx]edu = -[Spatial]rho*[Main]edu)


xsmle $ylist $xlist,emat(w) model(sem) hausman nolog
xsmle $ylist $xlist,wmat(w) model(sar) hausman nolog
xsmle $ylist $xlist,wmat(w) model(sdm) hausman nolog

xtreg $ylist $xlist,re
xtreg $ylist $xlist,re
hausman re fe

