clear

cd "/Users/yxy/UChi/Summer2025/Procurement/dta"

*******************************************************
* parameter setting
*******************************************************
use "china_procurement_bunchingfinal.dta", clear

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


local binlist 10000 20000 30000


matrix b_mat  = J(4,3,.)
matrix se_mat = J(4,3,.)
matrix bn_mat = J(4,3,.)
matrix n_mat  = J(4,3,.)

local col = 1
foreach bw of local binlist {

    local row = 1
    foreach c of local catlist {
        preserve
            if "`c'" != "all" {
                keep if cat == "`c'"
            }

            gen bincounts = 0
            gen zj = .

            global start = ceil((-$thr*0.25) / `bw')
            global end   = floor(($thr*0.25) / `bw')

            forvalues k = $start(1)$end {
                count if recenter <= (`k'+0.5)*`bw' & recenter > (`k'-0.5)*`bw'
                replace bincounts = r(N) if recenter <= (`k'+0.5)*`bw' & recenter > (`k'-0.5)*`bw'
                replace zj = `k' if recenter <= (`k'+0.5)*`bw' & recenter > (`k'-0.5)*`bw'
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

            matrix b_mat[`row',`col']  = r(b)
			matrix se_mat[`row',`col'] = r(b_se)
			matrix bn_mat[`row',`col'] = r(bn)
			matrix n_mat[`row',`col']  = r(numobs)

        restore
        local ++row
    }
    local ++col
}

*============================
* Export results to LaTeX
*============================

cap mkdir "/Users/yxy/UChi/Summer2025/Procurement/res/tab"
texdoc init "/Users/yxy/UChi/Summer2025/Procurement/res/tab/BinSize_Table.tex", replace force

texdoc write \begin{table}[htbp]\centering
texdoc write \caption{Polynomial Regression Specification Checks -- Choice of the Bin Size}
texdoc write \resizebox{\textwidth}{!}{%
texdoc write \begin{tabular}{p{1.8cm}*{4}{>{\centering\arraybackslash}p{3.2cm}}}
texdoc write \hline\hline
texdoc write  & All categories & \mbox{Construction Works} & Goods & Services \\
texdoc write \midrule

local binlabels "10,000 20,000 30,000"

forvalues i = 1/3 {
    local bw_label : word `i' of `binlabels'
    texdoc write \multicolumn{5}{c}{Bin size: `bw_label' CNY} \\

    * === b with stars ===
    local brow ""
    forvalues r = 1/4 {
        local b  = b_mat[`r',`i']
        local se = se_mat[`r',`i']
        local t  = `b'/`se'
        local stars ""
        if abs(`t') > 2.58 local stars = "***"
        else if abs(`t') > 1.96 local stars = "**"
        else if abs(`t') > 1.64 local stars = "*"

        local brow "`brow' & `: display %6.3f `b''`stars'"
    }
    texdoc write \(\hat b\) `brow' \\

    * se
    texdoc write  & [ `: display %6.3f se_mat[1,`i']' ] ///
                    & [ `: display %6.3f se_mat[2,`i']' ] ///
                    & [ `: display %6.3f se_mat[3,`i']' ] ///
                    & [ `: display %6.3f se_mat[4,`i']' ] \\

    * BN
    texdoc write \(\hat B_N\) ///
        & `: display %6.0f bn_mat[1,`i']' ///
        & `: display %6.0f bn_mat[2,`i']' ///
        & `: display %6.0f bn_mat[3,`i']' ///
        & `: display %6.0f bn_mat[4,`i']' \\

    texdoc write \midrule
}

* N
texdoc write N ///
    & `: display %6.0f n_mat[1,1]' ///
    & `: display %6.0f n_mat[2,1]' ///
    & `: display %6.0f n_mat[3,1]' ///
    & `: display %6.0f n_mat[4,1]' \\

texdoc write \hline\hline \end{tabular}}
texdoc write \end{table}
texdoc close

