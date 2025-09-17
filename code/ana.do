clear

cd "/Users/yxy/UChi/Summer2025/Procurement/dta"

import delimited "china_procurement_2cat.csv", encoding(utf8) clear
cap drop prov city county
cap rename 年份 year
cap rename region prov
save "china_procurement_2cat.dta", replace

import delimited "/Users/yxy/UChi/Summer2025/Procurement/dta/threshold.csv", encoding(utf8) clear

tempfile thresholds
save `thresholds'

use "/Users/yxy/UChi/Summer2025/Procurement/dta/china_procurement_2cat.dta", clear
drop if prov == "西藏自治区"
drop if prov == "新疆维吾尔自治区"

merge m:1 prov year using `thresholds'

tab _merge
drop if _merge==2 
drop _merge


gen amount_stad = amount - threshold
label var amount_stad "Contract amount minus policy threshold"

rename 采购方式 method

keep if inlist(method, "公开招标", "协议供货", "单一来源", "定点采购", ///
    "电子卖场", "竞争性磋商", "竞争性谈判", "询价", "邀请招标")

histogram amount, bin(50) ///
    frequency ///
    xtitle("Contract amount minus policy threshold") ///
    ytitle("Number of contracts") ///
    title("Distribution of amount")
	
histogram amount_stad, bin(50) ///
    frequency ///
    xtitle("Contract amount minus policy threshold") ///
    ytitle("Number of contracts") ///
    title("Distribution of amount_stad")

preserve
keep if threshold == 400
keep if method == "公开招标"
histogram amount_stad, bin(100) ///
    frequency ///
    xtitle("Contract amount minus policy threshold") ///
    ytitle("Number of contracts") ///
    title("Distribution of amount_stad threshold = 400")
restore

preserve
keep if threshold == 400
drop if method == "公开招标"
histogram amount_stad, bin(100) ///
    frequency ///
    xtitle("Contract amount minus policy threshold") ///
    ytitle("Number of contracts") ///
    title("Distribution of amount_stad threshold = 400")
restore

preserve
keep if threshold == 400
histogram amount_stad, bin(100) ///
    frequency ///
    xtitle("Contract amount minus policy threshold") ///
    ytitle("Number of contracts") ///
    title("Distribution of amount_stad threshold = 400")
rddensity amount_stad, c(0) plot
restore

preserve
keep if threshold == 400
gen treatment = (method == "公开招标")
label var treatment "1 if open bidding, 0 otherwise"

xtile amount_bin = amount, n(50)

collapse (mean) treatment (mean) amount, by(amount_bin)

twoway (line treatment amount), ///
    title("Probability of open bidding by contract amount") ///
    xtitle("Contract amount") ytitle("Probability of open bidding")
	
rddensity amount_stad, c(0) plot
	
restore

preserve
keep if threshold == 200

histogram amount_stad, bin(100) ///
    frequency ///
    xtitle("Contract amount minus policy threshold") ///
    ytitle("Number of contracts") ///
    title("Distribution of amount_stad threshold = 200")
restore

preserve
keep if threshold == 200
rddensity amount_stad, c(0) plot
restore
 
foreach thr in 100 200 300 400 {
    preserve
        keep if threshold == `thr'
		keep if method == "公开招标"

        histogram amount_stad, bin(100) ///
            frequency ///
            xtitle("Contract amount minus policy threshold") ///
            ytitle("Number of contracts") ///
            title("Distribution of amount_stad, threshold = `thr'") ///
            name(g`thr', replace)
    restore
}

graph  g100 g200 g300 g400

foreach thr in 100 200 300 400 {
    preserve
        keep if threshold == `thr'
		keep if cat == "服务"

        histogram amount_stad, bin(100) ///
            frequency ///
            xtitle("Contract amount minus policy threshold") ///
            ytitle("Number of contracts") ///
            title("Distribution of amount_stad service, threshold = `thr'") ///
            name(g`thr', replace)
    restore
	preserve
        keep if threshold == `thr'
		keep if cat == "货物"

        histogram amount_stad, bin(100) ///
            frequency ///
            xtitle("Contract amount minus policy threshold") ///
            ytitle("Number of contracts") ///
            title("Distribution of amount_stad goods, threshold = `thr'") ///
            name(g2`thr', replace)
    restore
}
graph  g100 g200 g300 g400 g2100 g2200 g2300 g2400

foreach thr in 100 200 300 400{
	preserve
    keep if threshold == `thr'   
    keep if inlist(cat,"货物","服务")

    twoway (histogram amount_stad if cat=="服务", bin(100) color(navy%40)) ///
           (histogram amount_stad if cat=="货物", bin(100) color(maroon%40)), ///
           legend(order(1 "服务" 2 "货物")) ///
           xtitle("Contract amount minus policy threshold") ///
           ytitle("Number of contracts") ///
           title("Distribution of amount_stad, threshold = `thr'") ///
		   name(f`thr',replace)
	restore
}
graph f100 f200 f300 f400

foreach thr in 100 200 300 400{
	preserve
    keep if threshold == `thr'   
    keep if inlist(cat,"货物","服务")
	rddensity amount_stad, c(0) plot
	restore
}


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

gen amount_stad = amount - threshold
label var amount_stad "Contract amount minus policy threshold"

rename 采购方式 method

keep if inlist(method, "公开招标", "协议供货", "单一来源", "定点采购", ///
    "电子卖场", "竞争性磋商", "竞争性谈判", "询价", "邀请招标")
	
foreach thr in 100 200 300 400{
	preserve
    keep if threshold == `thr'   
    keep if inlist(cat,"服务","工程")

    twoway (histogram amount_stad if cat=="工程", bin(100) color(navy%40)) ///
           (histogram amount_stad if cat=="服务", bin(100) color(maroon%40)), ///
           legend(order(1 "工程" 2 "服务")) ///
           xtitle("Contract amount minus policy threshold") ///
           ytitle("Number of contracts") ///
           title("Distribution of amount_stad, threshold = `thr'") ///
		   name(f`thr',replace)
	restore
}
graph f100 f200 f300 f400
