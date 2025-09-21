clear

cd "/Users/yxy/UChi/Summer2025/Procurement/dta"
* binwidth
global binwidth = 20000

* Threshold ：200m, 300m, 400m
foreach thr in 2000000 3000000 4000000 {

    global thr = `thr'
    global minval = $thr - 1000000
    global maxval = $thr + 1000000


    local thr_m = `thr' / 1000000  
    local thr_label = "`thr_m' million CNY"

    *===============================*
    * 1. All categories
    *===============================*
    use "china_procurement_bunchingfinal.dta", clear
    replace amount = amount*10000
    replace threshold = threshold*10000+0.0001
    gen recenter = amount - threshold

    keep if amount >= $minval & amount <= $maxval
    keep if threshold == $thr

    gen bincounts = 0
    gen zj = .

    global start = ceil(($minval - threshold) / $binwidth)
    global end   = floor(($maxval - threshold) / $binwidth)

    forvalues i = $start(1)$end {
        count if recenter <= (`i'+0.5)*$binwidth & recenter > (`i'-0.5)*$binwidth
        replace bincounts = r(N) if recenter <= (`i'+0.5)*$binwidth & recenter > (`i'-0.5)*$binwidth
        replace zj = `i' if recenter <= (`i'+0.5)*$binwidth & recenter > (`i'-0.5)*$binwidth
    }

    collapse (mean) bincounts, by(zj)

    global iglow  = $start + 10
    global ighigh = $end - 10
	
	set seed 12345
    bunch_count zj bincounts, ///
        bpoint(-1) binwidth(1) max_it(2000) ///
        low_bunch(-3) high_bunch(1) ///
        ig_low($iglow) ig_high($ighigh) ///
        nboot(500) int2one(1) ///
        plot(0) plot_fit(0) outvar(all)

    scalar ex_mass = r(b)
    scalar b_se    = r(b_se)
    local lbl1 = "Excess mass (b) = " + string(scalar(ex_mass),"%6.3f")
    local lbl2 = "Standard error = "  + string(scalar(b_se),"%6.3f")

    summarize bincounts if inrange(zj, $iglow, $ighigh)
    local ymax = r(max)
    local xpos = $ighigh - 5
    local ypos1 = `ymax' * 0.9
    local ypos2 = `ymax' * 0.8
    local xmin = $iglow - 5
    local xmax = $ighigh + 5

    cap gen __zero = 0

    twoway ///
        (rarea all3 __zero zj if inrange(zj, $iglow, $ighigh), color(gs12%60)) ///
        (bar   bincounts zj if inrange(zj, $iglow, $ighigh), barw(1) color(gs2)) ///
        (line  all3 zj if inrange(zj, $iglow, $ighigh), lcolor(gs8) lwidth(thin) sort), ///
        xline(0, lpattern(dash)) legend(off) ///
        ytitle("Frequency") ///
        xtitle("Contract value relative to threshold (20,000 CNY bins)") ///
        text(`ypos1' `xpos' "`lbl1'", size(small)) ///
        text(`ypos2' `xpos' "`lbl2'", size(small)) ///
        xscale(range(`xmin' `xmax')) ///
        xlabel(`xmin'(20)`xmax') ///
        title("All categories, threshold = `thr_label'")

    graph export "/Users/yxy/UChi/Summer2025/Procurement/res/fig/bunching_All_categories_`thr_m'm.pdf", replace


    *===============================*
    * 2. 分类循环
    *===============================*
    use "china_procurement_bunchingfinal.dta", clear
    replace amount = amount*10000
    replace threshold = threshold*10000+0.0001
    gen recenter = amount - threshold

    keep if amount >= $minval & amount <= $maxval
    keep if threshold == $thr

    levelsof cat, local(cats)
    foreach c of local cats {
        preserve
            keep if cat == "`c'"

            gen bincounts = 0
            gen zj = .

            forvalues i = $start(1)$end {
                count if recenter <= (`i'+0.5)*$binwidth & recenter > (`i'-0.5)*$binwidth
                replace bincounts = r(N) if recenter <= (`i'+0.5)*$binwidth & recenter > (`i'-0.5)*$binwidth
                replace zj = `i' if recenter <= (`i'+0.5)*$binwidth & recenter > (`i'-0.5)*$binwidth
            }

            collapse (mean) bincounts, by(zj)

            global iglow  = $start + 10
            global ighigh = $end - 10
			
			set seed 12345
            bunch_count zj bincounts, ///
                bpoint(-1) binwidth(1) max_it(500) ///
                low_bunch(-3) high_bunch(1) ///
                ig_low($iglow) ig_high($ighigh) ///
                nboot(500) int2one(1) ///
                plot(0) plot_fit(0) outvar(all)

            scalar ex_mass = r(b)
            scalar b_se    = r(b_se)
            local lbl1 = "Excess mass (b) = " + string(scalar(ex_mass),"%6.3f")
            local lbl2 = "Standard error = "  + string(scalar(b_se),"%6.3f")

            summarize bincounts if inrange(zj, $iglow, $ighigh)
            local ymax = r(max)
            local xpos = $ighigh - 5
            local ypos1 = `ymax' * 0.9
            local ypos2 = `ymax' * 0.8
            local xmin = $iglow - 5
            local xmax = $ighigh + 5

            cap gen __zero = 0

            if "`c'" == "工程" local title "Construction work"
            if "`c'" == "服务" local title "Service"
            if "`c'" == "货物" local title "Goods"

            twoway ///
                (rarea all3 __zero zj if inrange(zj, $iglow, $ighigh), color(gs12%60)) ///
                (bar   bincounts zj if inrange(zj, $iglow, $ighigh), barw(1) color(gs2)) ///
                (line  all3 zj if inrange(zj, $iglow, $ighigh), lcolor(gs8) lwidth(thin) sort), ///
                xline(0, lpattern(dash)) legend(off) ///
                ytitle("Frequency") ///
                xtitle("Contract value relative to threshold (20,000 CNY bins)") ///
                text(`ypos1' `xpos' "`lbl1'", size(small)) ///
                text(`ypos2' `xpos' "`lbl2'", size(small)) ///
                xscale(range(`xmin' `xmax')) ///
                xlabel(`xmin'(20)`xmax') ///
                title("`title', threshold = `thr_label'")

            local safe_c = subinstr("`title'"," ","_",.)
            graph export "/Users/yxy/UChi/Summer2025/Procurement/res/fig/bunching_`safe_c'_`thr_m'm.pdf", replace
        restore
    }
}
