clear
cd "/Users/yxy/UChi/Summer2025/Procurement/dta"

use "china_procurement_bunchingfinal.dta", clear

keep if threshold == 400
keep if amount_stad >= -200 & amount_stad <= 200

gen openbid = (method=="公开招标")

gen bin = floor(amount/5)

preserve
collapse (count) n=amount, by(bin openbid)
reshape wide n, i(bin) j(openbid)
replace n0 = 0 if missing(n0)
replace n1 = 0 if missing(n1)

gen total = n0 + n1
gen share_open  = n1/total
gen share_other = n0/total
gen amount_bin  = bin*5
gen one = 1
gen _zero = 0

twoway ///
    (scatter share_open amount_bin, mcolor(black) msymbol(o) msize(small)), ///
    xline(400, lcolor(black) lpattern(dash)) ///
    ytitle("Share of contracts (open bidding)") ///
    xtitle("Contract amount (10,000 CNY, bin=5)") ///
    ylabel(0(.2)1, format(%2.1f)) ///
    legend(order(1 "Observed") pos(6) ring(0)) ///
    graphregion(color(white))
graph export "/Users/yxy/UChi/Summer2025/Procurement/res/fig/share_open_scatter.pdf", as(pdf) replace
restore



preserve
    keep if threshold == 400
    keep if method == "公开招标"
    keep if inrange(amount, 300, 500)

    DCdensity amount_stad, breakpoint(0) b(2) generate(Xj Yj r0 fhat se_fhat)

    gen hi = fhat + 1.96*se_fhat
    gen lo = fhat - 1.96*se_fhat

    twoway ///
        (scatter Yj Xj, msymbol(oh) mcolor(gs8) msize(small)) ///
        (line fhat r0 if r0<0, lcolor(black) lwidth(medthick)) ///
        (line fhat r0 if r0>=0, lcolor(black) lwidth(medthick)) ///
        (line hi r0, lcolor(black) lpattern(dash) lwidth(thin)) ///
        (line lo r0, lcolor(black) lpattern(dash) lwidth(thin)) ///
        , ///
        xline(0, lcolor(black) lpattern(dash)) ///
        ytitle("Density") ///
        xtitle("Dist. from threshold (400,000 CNY)") ///
        graphregion(color(white)) legend(off)


    graph export "/Users/yxy/UChi/Summer2025/Procurement/res/fig/Mccrary.pdf", as(pdf) replace

restore
