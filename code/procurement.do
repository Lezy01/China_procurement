
clear

use "/Users/yxy/Downloads/china_procurement.dta",clear

gen amount = real(合同金额万元)
drop if missing(amount) | amount<=0 
drop  if missing(主要标的数量) | missing(主要标的单价) | missing(合同金额万元)
drop if amount<=0
drop 所属地域 所属行业 代理机构 其他补充事宜

gen num_goods = real(主要标的数量)
gen price_goods = real(主要标的单价)

save "/Users/yxy/Downloads/china_procurement_clean1.dta",replace //


use "/Users/yxy/Downloads/china_procurement_clean1.dta",clear

gen running = amount - 200
gen should_open = 1 if running>=0
replace should_open = 0 if running<0

histogram running if running >= -100 & running <= 100, width(1) density ///
    xtitle("Dist. from the discontinuity") ///
    ytitle("Density") ///
    fcolor(gs12) lcolor(gs8) ///
    graphregion(color(white)) ///
    xline(0, lcolor(red))

	
histogram amount if amount >= 20 & amount <= 500, width(1) density ///
    xtitle("Dist. of amount") ///
    ytitle("Density") ///
    fcolor(gs12) lcolor(gs8) ///
    graphregion(color(white)) ///
    xline(200, lcolor(red))
	
histogram amount if amount >= 20 & amount <= 500, width(5) density ///
    xtitle("Dist. of amount") ///
    ytitle("Density") ///
    fcolor(gs12) lcolor(gs8) ///
    graphregion(color(white)) ///
    xline(200, lcolor(red))
		
kdensity amount if amount >= 20 & amount <= 500

keep if inlist(采购方式, "公开招标", "协议供货", "单一来源", "电子卖场", "竞争性磋商", "竞争性谈判", "询价", "邀请招标")


drop if missing(price_goods) | missing(num_goods)


