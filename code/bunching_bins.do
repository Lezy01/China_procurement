*******************************************************
* robustness check
* exclusion bins 1-3
*******************************************************

clear

cd "/Users/yxy/UChi/Summer2025/Procurement/dta"

use "china_procurement_bunchingfinal.dta", clear

global bw = 20000
global thr = 4000000

replace amount    = amount * 10000
replace threshold = threshold * 10000 + 0.0001
gen recenter = amount - threshold
keep if threshold == $thr

global minval = $thr - 1000000
global maxval = $thr + 1000000

keep if amount >= $minval & amount <= $maxval


local catlist "all 工程 货物 服务"
local englist "All categories" "Construction Works" "Goods" "Services"
local excl 2 3 4

matrix b_mat  = J(4,3,.)
matrix se_mat = J(4,3,.)
matrix bn_mat = J(4,3,.)
matrix n_mat  = J(4,3,.)

local col = 1
foreach q of local excl {

    local row = 1
    foreach c of local catlist {
        preserve
            if "`c'" != "all" {
                keep if cat == "`c'"
            }

            gen bincounts = 0
            gen zj = .

            global start = ceil((-$thr*0.25) / $bw)
            global end   = floor(($thr*0.25) / $bw)

            forvalues k = $start(1)$end {
                count if recenter <= (`k'+0.5)*$bw & recenter > (`k'-0.5)*$bw
                replace bincounts = r(N) if recenter <= (`k'+0.5)*$bw & recenter > (`k'-0.5)*$bw
                replace zj = `k' if recenter <= (`k'+0.5)*$bw & recenter > (`k'-0.5)*$bw
            }

            collapse (mean) bincounts, by(zj)

            global iglow  = $start + 10
            global ighigh = $end - 10

            di "=== poly=`q', cat=`c' ==="
            set seed 12345
            bunch_count zj bincounts, ///
                bpoint(-1) binwidth(1) ///
                low_bunch(-`q') high_bunch(1) ///
                ig_low($iglow) ig_high($ighigh) ///
                nboot(500) int2one(1) ///
                plot(0) plot_fit(0) outvar(all)

            matrix b_mat[`row',`col']  = r(b)
            matrix se_mat[`row',`col'] = r(b_se)
            matrix bn_mat[`row',`col'] = r(bn)
            matrix n_mat[`row',`col']  = r(numobs)

        restore
        local ++row
    }
    local ++col
}

*******************************************************
* Export LaTeX table
*******************************************************

cap mkdir "/Users/yxy/UChi/Summer2025/Procurement/res/tab"
texdoc init "/Users/yxy/UChi/Summer2025/Procurement/res/tab/Exclbin_Table.tex", replace force

texdoc write \begin{table}[htbp]\centering
texdoc write \caption{Polynomial Regression Specification Checks -- Excluded Area  below the Threshold}
texdoc write \begin{tabular}{lccc}
texdoc write \hline\hline
texdoc write & Construction Works & Goods & Services \\
texdoc write \hline

local pol 2 3 4
local col = 1
foreach q of local pol {
    texdoc write \multicolumn{4}{l}{Excluded area below the threshold: `q' bins} \\

    * === b with stars ===
    local brow "\(\hat b\)"
    forvalues r = 1/3 {
        local b  = b_mat[`r',`col']
        local se = se_mat[`r',`col']
        local t  = `b'/`se'
        local stars ""
        if abs(`t') > 2.58 local stars = "***"
        else if abs(`t') > 1.96 local stars = "**"
        else if abs(`t') > 1.64 local stars = "*"
        local brow "`brow' & `: display %6.3f `b''`stars'"
    }
    texdoc write `brow' \\

    * se 行
    texdoc write  & [ `: display %6.3f se_mat[1,`col']' ] ///
                  & [ `: display %6.3f se_mat[2,`col']' ] ///
                  & [ `: display %6.3f se_mat[3,`col']' ] \\

    * BN 行
    texdoc write \(\hat B_N\) ///
        & `: display %6.0f bn_mat[1,`col']' ///
        & `: display %6.0f bn_mat[2,`col']' ///
        & `: display %6.0f bn_mat[3,`col']' \\

    texdoc write \hline
    local ++col
}

* N 行
texdoc write N ///
    & `: display %6.0f n_mat[1,1]' ///
    & `: display %6.0f n_mat[2,1]' ///
    & `: display %6.0f n_mat[3,1]' \\

texdoc write \hline\hline
texdoc write \end{tabular}
texdoc write \begin{flushleft}\footnotesize Notes: $\hat B_N$ denotes the estimated excess number of contracts below the threshold, and $\hat b$ denotes the excess mass of contracts relative to the average density at the threshold. Standard errors are presented in brackets. The bin size equals 20,000 CNY and the order of the polynomial fitted to the empirical distribution is 7. *** Estimates significant at the 1\% level, ** at 5\%, * at 10\%.\end{flushleft}
texdoc write \end{table}
texdoc close
