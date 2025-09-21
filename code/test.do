clear

cd "/Users/yxy/UChi/Summer2025/Procurement/dta"

import delimited "china_procurement_bunchingfinal.csv", encoding(utf8) clear
cap drop prov city county
cap rename 年份 year
cap rename region prov
save "china_procurement_bunchingfinal.dta", replace

import delimited "/Users/yxy/UChi/Summer2025/Procurement/dta/threshold.csv", encoding(utf8) clear

tempfile thresholds
save `thresholds'

use "/Users/yxy/UChi/Summer2025/Procurement/dta/china_procurement_bunchingfinal.dta", clear
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


save "china_procurement_bunchingfinal.dta", replace
	