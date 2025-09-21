clear

cd "/Users/yxy/UChi/Summer2025/Procurement/dta"


import delimited "china_procurement_final.csv", encoding(utf8) clear
cap drop prov city county
cap rename 年份 year
cap rename region prov

save "china_procurement_rdfinal.dta", replace

import delimited "/Users/yxy/UChi/Summer2025/Procurement/dta/threshold.csv", encoding(utf8) clear

tempfile thresholds
save `thresholds'

use "china_procurement_rdfinal.dta",clear
drop if prov == "西藏自治区"
drop if prov == "新疆维吾尔自治区"

merge m:1 prov year using `thresholds'

tab _merge
drop if _merge==2 
drop _merge

replace threshold = 400 if cat == "工程"

gen amount_stad = amount - threshold
label var amount_stad "Contract amount minus policy threshold"

rename 采购方式 method

keep if inlist(method, "公开招标", "协议供货", "单一来源", "定点采购", ///
    "电子卖场", "竞争性磋商", "竞争性谈判", "询价", "邀请招标")

save "china_procurement_rdfinal.dta", replace

use "/Users/yxy/UChi/Summer2025/Procurement/dta/china_procurement_rdfinal.dta",clear

keep if threshold == 400

keep if amount_stad >=-200 & amount_stad<=200

gen openbid = (method=="公开招标")

gen highdis = (method=="公开招标" | method=="电子卖场")

gen bin = floor(amount/5)

preserve
collapse (mean) prob_open=openbid (count) n=amount, by(bin)

gen amount_bin = bin*5

twoway (line prob_open amount_bin, lcolor(red)) ///
       , xline(400)
restore

preserve
keep if threshold == 400
keep if method == "公开招标"
rddensity amount_stad, c(0) plot
restore

drop if price_goods ==0


gen ln_price_goods = ln(price_goods + 1)
*******************************************************
* 
*******************************************************
cap mkdir "/Users/yxy/UChi/Summer2025/Procurement/res/tab"
cd "/Users/yxy/UChi/Summer2025/Procurement/res/tab"

* Open tendering
eststo clear
reghdfe ln_price_goods openbid, absorb(subcategory_name)
    eststo m1
reghdfe ln_price_goods openbid, absorb(subcategory_name category)
    eststo m2
reghdfe ln_price_goods openbid, absorb(subcategory_name category prov)
    eststo m3
reghdfe ln_price_goods openbid, absorb(subcategory_name category prov year)
    eststo m4

* High discretion
reghdfe ln_price_goods highdis, absorb(subcategory_name)
    eststo m5
reghdfe ln_price_goods highdis, absorb(subcategory_name category)
    eststo m6
reghdfe ln_price_goods highdis, absorb(subcategory_name category prov)
    eststo m7
reghdfe ln_price_goods highdis, absorb(subcategory_name category prov year)
    eststo m8


matrix b_mat  = J(2,8,.)
matrix se_mat = J(2,8,.)
matrix N_mat  = J(1,8,.)

* --- m1 ---
est restore m1
matrix b_mat[1,1]  = _b[openbid]
matrix se_mat[1,1] = _se[openbid]
matrix N_mat[1,1]  = e(N)

* --- m2 ---
est restore m2
matrix b_mat[1,2]  = _b[openbid]
matrix se_mat[1,2] = _se[openbid]
matrix N_mat[1,2]  = e(N)

* --- m3 ---
est restore m3
matrix b_mat[1,3]  = _b[openbid]
matrix se_mat[1,3] = _se[openbid]
matrix N_mat[1,3]  = e(N)

* --- m4 ---
est restore m4
matrix b_mat[1,4]  = _b[openbid]
matrix se_mat[1,4] = _se[openbid]
matrix N_mat[1,4]  = e(N)

* --- m5 ---
est restore m5
matrix b_mat[2,5]  = _b[highdis]
matrix se_mat[2,5] = _se[highdis]
matrix N_mat[1,5]  = e(N)

* --- m6 ---
est restore m6
matrix b_mat[2,6]  = _b[highdis]
matrix se_mat[2,6] = _se[highdis]
matrix N_mat[1,6]  = e(N)

* --- m7 ---
est restore m7
matrix b_mat[2,7]  = _b[highdis]
matrix se_mat[2,7] = _se[highdis]
matrix N_mat[1,7]  = e(N)

* --- m8 ---
est restore m8
matrix b_mat[2,8]  = _b[highdis]
matrix se_mat[2,8] = _se[highdis]
matrix N_mat[1,8]  = e(N)

texdoc init "/Users/yxy/UChi/Summer2025/Procurement/res/tab/Reg_FE_Table.tex", replace force

texdoc write \begin{table}[htbp]\centering
texdoc write \caption{Effects of Open Tendering vs. Low Discretion on Contract Prices}
texdoc write \label{tab:reg_fe}
texdoc write \begin{tabular}{l*{4}{c}}
texdoc write \hline\hline
texdoc write & (1) & (2) & (3) & (4) \\
texdoc write \hline

* ================= Panel A: Open tendering =================
texdoc write \multicolumn{5}{l}{\textbf{Panel A. Open tendering}} \\
texdoc write \(\hat\beta\) ///
    & `: display %6.3f b_mat[1,1]' & `: display %6.3f b_mat[1,2]' & `: display %6.3f b_mat[1,3]' & `: display %6.3f b_mat[1,4]' \\
texdoc write  & ( `: display %6.3f se_mat[1,1]' ) & ( `: display %6.3f se_mat[1,2]' ) & ( `: display %6.3f se_mat[1,3]' ) & ( `: display %6.3f se_mat[1,4]' ) \\
texdoc write Subcat FE & Yes & Yes & Yes & Yes \\
texdoc write Category FE &  & Yes & Yes & Yes \\
texdoc write Prov FE &  &  & Yes & Yes \\
texdoc write Year FE &  &  &  & Yes \\
texdoc write Obs. ///
    & `: display %6.0f N_mat[1,1]' & `: display %6.0f N_mat[1,2]' & `: display %6.0f N_mat[1,3]' & `: display %6.0f N_mat[1,4]' \\

texdoc write \midrule

* ================= Panel B: High discretion =================
texdoc write \multicolumn{5}{l}{\textbf{Panel B. Low discretion methods}} \\
texdoc write \(\hat\beta\) ///
    & `: display %6.3f b_mat[2,5]' & `: display %6.3f b_mat[2,6]' & `: display %6.3f b_mat[2,7]' & `: display %6.3f b_mat[2,8]' \\
texdoc write  & ( `: display %6.3f se_mat[2,5]' ) & ( `: display %6.3f se_mat[2,6]' ) & ( `: display %6.3f se_mat[2,7]' ) & ( `: display %6.3f se_mat[2,8]' ) \\
texdoc write Subcat FE & Yes & Yes & Yes & Yes \\
texdoc write Category FE &  & Yes & Yes & Yes \\
texdoc write Prov FE &  &  & Yes & Yes \\
texdoc write Year FE &  &  &  & Yes \\
texdoc write Obs. ///
    & `: display %6.0f N_mat[1,5]' & `: display %6.0f N_mat[1,6]' & `: display %6.0f N_mat[1,7]' & `: display %6.0f N_mat[1,8]' \\

texdoc write \hline\hline
texdoc write \end{tabular}
texdoc write \begin{flushleft}\footnotesize Robust standard errors in parentheses.\end{flushleft}
texdoc write \end{table}
texdoc close
