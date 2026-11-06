**************主回归
use GEGIbasic3.dta,clear
encode industry, gen(indu)
winsor2 LnGApply LnGApplyU LnGApplyI employ Size Lev ROA Growth CF Top1  Age  SOE IndRatio  Board  GDPGR Eect05 LnGGrant LnGGrantI employ1 Eect13 LnGApply1 LnGApplyI1, cuts(1 99) suffix(_w)
reghdfe LnGApply_w employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
gen regsample = e(sample)
keep if regsample==1
reghdfe LnGApply_w employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year indu) vce(cluster stkcd)
$outs EGI_1.xml,replace $basic $add
reghdfe LnGApplyI_w employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w , absorb(year indu) vce(cluster stkcd)
$outs EGI_1.xml,append $basic $add
reghdfe LnGApply_w employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
$outs EGI_1.xml,append $basic $add
reghdfe LnGApplyI_w employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
$outs EGI_1.xml,append $basic $add

tabstat LnGApply_w LnGApplyI_w employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w,  s(N mean sd min max p50) f(%12.3f)c(s)
logout, save(描述性统计1025) excel replace: tabstat LnGApply_w LnGApplyI_w employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w,  s(N mean sd min p50 max)  f(%12.3f) c(s)

****稳健性检验
****更换自变量
xtset stkcd year
reghdfe LnGApply_w employ_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
$outs EGI_1.xml,append $basic $add
reghdfe LnGApplyI_w employ_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
$outs EGI_1.xml,append $basic $add

****滞后一期申请
xtset stkcd year
reghdfe LnGApply1_w employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
$outs EGI_1.xml,replace $basic $add
reghdfe LnGApplyI1_w employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
$outs EGI_1.xml,append $basic $add

******控制遗漏变量
xtset stkcd year
gen lemploy=l.employ1_w
reghdfe LnGApply_w employ1_w lemploy Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
$outs EGI_1.xml,append $basic $add
reghdfe LnGApplyI_w employ1_w lemploy Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
$outs EGI_1.xml,append $basic $add

****熵平衡
use GEGIbasic3.dta,clear
winsor2 LnGApply LnGApplyI employ Size Lev ROA Growth CF Top1  Age  SOE  Dual   IndRatio  Board  GDPGR  GDP Eect03 Eect11 Eect01 employ1 Eect13  Eect05 LnGApply1 LnGApplyI1 , cuts(1 99) suffix(_w)
encode industry, gen(indu)
xtset stkcd year
* 按年份生成就业目标的中位数
bys year: egen median_employ = median(employ1_w)
* 定义处理组：大于当年中位数的地区为"高就业目标地区"
gen treat = (employ1_w > median_employ)
* 检查分组结果
tab year treat
* 2. 熵平衡匹配
ebalance treat Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w
describe _webal
summarize _webal
gen w_ebalance = _webal
replace w_ebalance = 1 if treat==1
reghdfe LnGApply_w employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w [aw=w_ebalance], absorb(year stkcd) vce(cluster stkcd)
$outs EGI_1.xml,replace $basic $add
reghdfe LnGApplyI_w employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w[aw=w_ebalance], absorb(year stkcd) vce(cluster stkcd)
$outs EGI_1.xml,append $basic $add

***稳健性检验1：专利申请改为获得
use GEGIbasic3.dta,clear
winsor2 LnGApply LnGApplyU LnGApplyI employ Size Lev ROA Growth CF Top1  Age  SOE  Dual IndRatio  Board  GDPGR  GDP Eect03 Eect11 LnGGrant LnGGrantI Eect01 employ1 Eect13 Eect05, cuts(1 99) suffix(_w)
encode industry, gen(indu)
xtset stkcd year
reghdfe LnGGrant_w employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
$outs EGI_1.xml,append $basic $add
reghdfe LnGGrantI_w employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
$outs EGI_1.xml,append $basic $add

*****控制firm*indu
use GEGIbasic3.dta,clear
winsor2 LnGApply LnGApplyU LnGApplyI employ Size Lev ROA Growth CF Top1  Age  SOE  Dual  IndRatio  Board  GDPGR  GDP Eect03 Eect11  LnGGrant LnGGrantI Eect01   employ1  Eect13   Eect05 , cuts(1 99) suffix(_w)
encode industry, gen(indu)
gen indu_year=indu*year
reghdfe LnGApply_w employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(indu_year stkcd) vce(cluster stkcd)
$outs EGI_1.xml,append $basic $add
reghdfe LnGApplyI_w employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(indu_year stkcd) vce(cluster stkcd)
$outs EGI_1.xml,append $basic $add

***内生性检验
use GEGIbasic3.dta,clear
winsor2 LnGApply LnGApplyI employ Size Lev ROA Growth  CF Top1  Age  SOE  Dual IndRatio  Board  GDPGR  GDP Eect03 LnGGrant LnGGrantI Eect01 employ1 Eect13 Eect05 LnGApply1 LnGApplyI1 LnGGrant1 pressure_pct_lag, cuts(1 99) suffix(_w)
encode industry, gen(indu)
destring PROVINCECODE, replace force
drop if missing(LnGApply)
gen IV=priority*fellow_any

ivreghdfe LnGApply_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Top1_w Age_w GDPGR_w Eect05_w Eect13_w (employ1_w=IV), absorb(year stkcd) vce(cluster stkcd) first
$outs EGI_IV1.xml,replace $basic $add
ivreghdfe LnGApplyI_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Top1_w Age_w GDPGR_w Eect05_w Eect13_w  (employ1_w=IV) , absorb(year stkcd) vce(cluster stkcd) first
$outs EGI_IV1.xml,append $basic $add

******3、机制检验
******(1绿色注意力
use GEGIbasic3.dta,clear
winsor2 LnGApply LnGApplyU LnGApplyI employ Size Lev ROA Growth  CF Top1  Age  SOE  Dual   IndRatio  Board  GDPGR  GDP  Eect03   LnGGrant  LnGGrantI Eect01 employ1  Eect13  Eect05 LnGApply1 LnGApplyI1 LnGGrant1 enpro_total enpro_nonum enpro_noeng, cuts(1 99) suffix(_w)
xtset stkcd year
reghdfe enpro_total_w employ1_w  Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
$outs EGI_1.xml,replace $basic $add
reghdfe enpro_nonum_w employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
$outs EGI_1.xml,append $basic $add
reghdfe enpro_noeng_w employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
$outs EGI_1.xml,append $basic $add

******(2时间注意力
use GEGIbasic3.dta,clear
replace pfratio=0 if pfratio==.
label var pfratio 现在未来关键词比例
winsor2 LnGApply LnGApplyU LnGApplyI employ Size Lev ROA Growth  CF Top1  Age  SOE  Dual   IndRatio  Board  GDPGR  GDP Eect03   LnGGrant  LnGGrantI Eect01 employ1  Eect13  Eect05 LnGApply1 LnGApplyI1 LnGGrant1 future_total future_nonum future_noeng present_total present_nonum present_noeng pfratio, cuts(1 99) suffix(_w)
xtset stkcd year
reghdfe present_total_w employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
$outs EGI_1.xml,replace $basic $add
reghdfe present_nonum_w  employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
$outs EGI_1.xml,append $basic $add
reghdfe present_noeng_w  employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
$outs EGI_1.xml,append $basic $add
reghdfe pfratio_w employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
$outs EGI_1.xml,append $basic $add


********4、调节效应
***mayor retirement
use GEGIbasic3.dta,clear
gen lastterm_employ=lastterm*employ1
winsor2 LnGApply LnGApplyU LnGApplyI employ Size Lev ROA Growth  CF Top1  Age  SOE  Dual   IndRatio  Board  GDPGR  GDP Eect03   LnGGrant  LnGGrantI Eect01 employ1  Eect13  Eect05 LnGApply1 LnGApplyI1 LnGGrant1 lastterm_employ, cuts(1 99) suffix(_w)

reghdfe LnGApply_w lastterm_employ_w lastterm employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w , absorb(year stkcd) vce(cluster stkcd)
$outs EGI_m1.xml,replace $basic $add
reghdfe LnGApplyI_w lastterm_employ_w lastterm employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w , absorb(year stkcd) vce(cluster stkcd)
$outs EGI_m1.xml,append $basic $add

***state ownership
cd $out
use GEGIbasic3.dta,clear
xtset stkcd year
gen SOE_employ=SOE*employ1
winsor2 LnGApply LnGApplyU LnGApplyI employ Size Lev ROA Growth  CF Top1  Age  SOE  Dual   IndRatio  Board  GDPGR  GDP  Eect03   LnGGrant  LnGGrantI Eect01 employ1  Eect13  Eect05 LnGApply1 LnGApplyI1 LnGGrant1  SOE_employ, cuts(1 99) suffix(_w)
reghdfe LnGApply_w SOE_employ_w SOE employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
$outs EGI_m1.xml,append $basic $add
reghdfe LnGApplyI_w SOE_employ_w SOE employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w , absorb(year stkcd) vce(cluster stkcd)
$outs EGI_m1.xml,append $basic $add

*****政府环保硬性目标
use GEGIbasic3.dta,clear
gen EnvTarget_employ=EnvTarget*employ1
winsor2 LnGApply LnGApplyI employ1 Size Lev ROA Growth CF Top1 Age IndRatio Board GDPGR Eect13 Eect05 EnvTarget EnvTarget_employ, cuts(1 99) suffix(_w)
reghdfe LnGApply_w EnvTarget_employ_w EnvTarget_w employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
$outs EGI_m1.xml,append $basic $add
reghdfe LnGApplyI_w EnvTarget_employ_w EnvTarget_w employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
$outs EGI_m1.xml,append $basic $add

****3)经济后果:可持续性
use GEGIbasic3.dta,clear
winsor2 LnGApply LnGApplyI employ Size Lev ROA Growth  CF Top1  Age  SOE  Dual IndRatio  Board GDPGR GDP Eect03 Eect01 FC employ1 Eect13 LnGGrant LnGGrantI Eect05 Erank_num Erank_num1 Srank_num1 rank_num1, cuts(1 99) suffix(_w)
reghdfe rank_num1_w employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
$outs EGI_m1.xml,replace $basic $add
reghdfe rank_num1_w employ1_w LnGApply_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
$outs EGI_m1.xml,append $basic $add
reghdfe rank_num1_w employ1_w LnGApplyI_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
$outs EGI_m1.xml,append $basic $add
reghdfe Erank_num1_w employ1_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
$outs EGI_m1.xml,append $basic $add
reghdfe Erank_num1_w employ1_w LnGApply_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
$outs EGI_m1.xml,append $basic $add
reghdfe Erank_num1_w employ1_w LnGApplyI_w Size_w Lev_w ROA_w Growth_w IndRatio_w CF_w Board_w Age_w Top1_w GDPGR_w Eect05_w Eect13_w, absorb(year stkcd) vce(cluster stkcd)
$outs EGI_m1.xml,append $basic $add
