clear

cd "/Users/yxy/UChi/Summer2025/Procurement/dta"

use "china_procurement_bunching.dta",clear

*** ====== threhold = 200 =========**
local minval    = 3000000      
local maxval    = 5000000    
local binwidth  = 10000      
local thr = 4000000

keep if amount >= `minval' & amount <= `maxval'
keep if threshold == `thr'
gen bincounts = 0
gen zj = .

local start = ceil((`minval' - threshold) / `binwidth')
local end   = floor((`maxval' - threshold) / `binwidth')

di `start'
di `end'

forvalues i = `start'(1)`end' {
    count if recenter <= (`i'+0.5)*`binwidth' & recenter > (`i'-0.5)*`binwidth'
    replace bincounts = r(N) if recenter <= (`i'+0.5)*`binwidth' & recenter > (`i'-0.5)*`binwidth'
    replace zj = `i' if recenter <= (`i'+0.5)*`binwidth' & recenter > (`i'-0.5)*`binwidth'
}




collapse (mean) bincounts, by(zj)


set seed 123456
local iglow  = `start' + 10
local ighigh = `end' - 10

bunch_count zj bincounts, ///
    bpoint(-1)          /// 
    binwidth(1)        /// 因为 zj 已经是标准化后的索引，单位就是 1 bin
	max_it(2000)	///
    low_bunch(-1)      /// 门槛左边要排除的 bin（可试 -2,-3 看稳健性）
    high_bunch(1)      /// 门槛右边要排除的 bin
    ig_low(`iglow')        /// 拟合范围下限（对应 -33，留出点 margin）
    ig_high(`ighigh')        /// 拟合范围上限
    nboot(2000)         /// bootstrap 次数（100 先跑，正式结果建议 500+）
    int2one(1)         /// 保证总面积匹配
    plot(1) plot_fit(1) ///
    outvar(all)
twoway (area all3 zj) (bar all2 zj), ///
    xtitle("Anticipated Value Relative to Threshold (10,000 RMB bins)") ///
    ytitle("Frequency") ///
    title("Threshold 400w") ///
    xlabel(#10) ylabel(#5) legend(off) ///
    text(45 10 "Excess mass (b) = " "Standard error = ", box margin(small)) ///
    scheme(sj)


* 生成bin中心点（对齐到5万的网格）
preserve
gen bin_center = zj * `binwidth'   // zj 是你已有的bin索引
label var bin_center "Bin center (relative to threshold)"

* 按bin聚合，得到每个bin的合同数量
collapse (mean) bincounts, by(bin_center)

* 画直方图（条形图）
twoway bar bincounts bin_center, ///
    barwidth(`binwidth')  ///
    xtitle("Amount relative to threshold (RMB)") ///
    ytitle("Number of contracts") ///
    title("Bunching around threshold 4,000,000 RMB")
restore
