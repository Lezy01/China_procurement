clear

cd "/Users/yxy/UChi/Summer2025/Procurement/dta"


import delimited "china_procurement_classified.csv", encoding(utf8) clear
cap drop prov city county
cap rename 年份 year
cap rename region prov

save "china_procurement_classified.dta", replace

import delimited "/Users/yxy/UChi/Summer2025/Procurement/dta/threshold.csv", encoding(utf8) clear

tempfile thresholds
save `thresholds'

use "china_procurement_classified.dta",clear
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

save "china_procurement_classified.dta", replace

use "china_procurement_classified.dta",clear

keep if threshold == 400


gen openbid = (method=="公开招标")

gen bin = floor(amount/10)

preserve
collapse (mean) prob_open=openbid (count) n=amount, by(bin)

gen amount_bin = bin*10

twoway (line prob_open amount_bin, lcolor(red)) ///
       , xline(400)
restore

preserve
keep if threshold == 400
keep if method == "公开招标"
rddensity amount_stad, c(0) plot
restore

drop if price_goods ==0


xi: rdrobust price_goods amount_stad, c(0) fuzzy(openbid) all p(1)  kernel(tri) ///
    bwselect(mserd) scaleregul(1)  covs(i.subcategory_name i.category i.prov)
	

gen ln_price_goods = ln(price_goods + 1)


xi: rdrobust ln_price_goods amount_stad, c(0) fuzzy(openbid) all p(1)  kernel(tri) ///
    bwselect(mserd) scaleregul(1)  covs(i.subcategory_name i.category i.prov)
	

histogram amount_stad, ///
    width(10)    /// 每个 bin 宽度（比如 10，根据你的单位调整）
    frequency    /// 显示频数，而不是密度
    xtitle("amount_stad") ///
    ytitle("Frequency") ///
    title("Distribution of amount_stad")

	
preserve 
drop if category == "工程"
bysort subcategory_name: drop if _N < 10
xi: rdrobust ln_price_goods amount_stad, c(0) fuzzy(openbid) ///
    covs(i.subcategory_name i.prov) all p(1) kernel(tri) bwselect(mserd) scaleregul(1)
restore

preserve 
keep if category == "工程"
bysort subcategory_name: drop if _N < 10
xi:rdrobust ln_price_goods amount_stad, c(0) fuzzy(openbid) ///
    covs(i.subcategory_name i.prov) all p(1) kernel(tri) bwselect(mserd) scaleregul(1)
restore

*============ rd year fixed effect=============*

use "china_procurement_classified.dta",clear

keep if threshold == 400

gen openbid = (method=="公开招标")
drop if price_goods ==0
gen ln_price_goods = ln(price_goods + 1)

xi: rdrobust ln_price_goods amount_stad, c(0) fuzzy(openbid) all p(1)  kernel(tri) ///
    bwselect(mserd) scaleregul(1)  covs(i.subcategory_name i.category i.prov i.year)
	
preserve 
keep if category == "工程"
xi: rdrobust ln_price_goods amount_stad, c(0) fuzzy(openbid) ///
    covs(i.subcategory_name i.prov i.year) all p(1) kernel(tri) bwselect(mserd) scaleregul(1)
restore

levelsof year, local(yrs)
foreach y of local yrs {
    rdplot ln_price_goods amount_stad if year==`y', c(0) ///
        name(g`y', replace) ///
        title("RDD plot, year=`y'")
}
