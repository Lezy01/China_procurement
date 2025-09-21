clear

cd "/Users/yxy/UChi/Summer2025/Procurement/dta"

*******************************************************
* parameter setting
*******************************************************
use "china_procurement_bunchingfinal.dta", clear

global thr = 4000000
global bw = 20000
replace amount    = amount * 10000
replace threshold = threshold * 10000 + 0.0001
gen recenter = amount - threshold
keep if threshold == $thr


local yrlist "2020 2021 2022 2023 2024"
local catlist "all 工程 货物 服务"
local englist "All categories" "Construction Works" "Goods" "Services"


matrix b_mat  = J(4,5,.)
matrix se_mat = J(4,5,.)
matrix bn_mat = J(4,5,.)
matrix n_mat  = J(4,5,.)


local col = 1
foreach y of local yrlist {

    local row = 1
    foreach c of local catlist {
        preserve
            if "`c'" != "all" {
                keep if cat == "`c'"
            }
			keep if year == `y'

            gen bincounts = 0
            gen zj = .

            global start = ceil((-$thr*0.25) / $bw )
            global end   = floor(($thr*0.25) / $bw )


			forvalues k = $start(1)$end {
				count if recenter <= (`k'+0.5)*$bw & recenter > (`k'-0.5)*$bw
				if r(N)==0 {
					set obs `=_N+1'
					replace zj = `k' in L
					replace bincounts = 0 in L
				}
				else {
					replace bincounts = r(N) if recenter <= (`k'+0.5)*$bw & recenter > (`k'-0.5)*$bw
					replace zj = `k' if recenter <= (`k'+0.5)*$bw & recenter > (`k'-0.5)*$bw
				}
			}

			replace bincounts = 0.0001 if missing(bincounts) | bincounts==0
            collapse (mean) bincounts, by(zj)

            global iglow  = $start + 10
            global ighigh = $end - 10
			
			di "===`y', cat `c'===="
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


*******************************************************
* Export results to LaTeX 
*******************************************************

cap mkdir "/Users/yxy/UChi/Summer2025/Procurement/res/tab"
texdoc init "/Users/yxy/UChi/Summer2025/Procurement/res/tab/ExcessMassByYear_Table.tex", replace force

texdoc write \begin{table}[htbp]\centering
texdoc write \caption{Estimated Excess Mass below the Thresholds by Year and Main Category}
texdoc write \begin{tabular}{l*{8}{c}}
texdoc write \hline\hline
texdoc write & \multicolumn{2}{c}{All categories} & \multicolumn{2}{c}{Construction works} & \multicolumn{2}{c}{Goods} & \multicolumn{2}{c}{Services} \\
texdoc write Year & Excess mass estimates & SE & Excess mass estimates & SE & Excess mass estimates & SE & Excess mass estimates & SE \\
texdoc write \hline

local yrlabels "2020 2021 2022 2023 2024"

forvalues i = 1/5 {
    local yr_label : word `i' of `yrlabels'

    texdoc write `yr_label' ///
        & `: display %6.3f b_mat[1,`i']' & [ `: display %6.3f se_mat[1,`i']' ] ///
        & `: display %6.3f b_mat[2,`i']' & [ `: display %6.3f se_mat[2,`i']' ] ///
        & `: display %6.3f b_mat[3,`i']' & [ `: display %6.3f se_mat[3,`i']' ] ///
        & `: display %6.3f b_mat[4,`i']' & [ `: display %6.3f se_mat[4,`i']' ] \\
}

texdoc write \hline\hline
texdoc write \end{tabular}
texdoc write \begin{flushleft}\footnotesize Notes: The table estimates the excess mass of contracts relative to the average density at thresholds. Standard errors are presented in brackets.\end{flushleft}
texdoc write \end{table}
texdoc close
