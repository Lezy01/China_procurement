
clear

cd "/Users/yxy/UChi/Summer2025/Procurement/dta"

import delimited "china_procurement_primary.csv", encoding(utf8) clear
cap drop prov city county
cap rename 年份 year
cap rename region prov
save "china_procurement_primary.dta", replace

import delimited "/Users/yxy/UChi/Summer2025/Procurement/dta/threshold.csv", encoding(utf8) clear

tempfile thresholds
save `thresholds'

use "/Users/yxy/UChi/Summer2025/Procurement/dta/china_procurement_primary.dta", clear
drop if prov == "西藏自治区"
drop if prov == "新疆维吾尔自治区"

merge m:1 prov year using `thresholds'

tab _merge
drop if _merge==2 
drop _merge

replace threshold = 400 if cat == "工程"


rename 采购方式 method

keep if inlist(method, "公开招标", "协议供货", "单一来源", "定点采购", ///
    "电子卖场", "竞争性磋商", "竞争性谈判", "询价", "邀请招标")
	
replace amount = amount * 10000
replace threshold = threshold * 10000
gen recenter = amount - threshold-0.0001
drop if missing(cat)

save "china_procurement_bunching.dta", replace
