***************************************************
* Descriptive Statistics Table
***************************************************

cd "/Users/yxy/UChi/Summer2025/Procurement/dta"

***************************************************
* 1. By main object
***************************************************
use "china_procurement_bunchingfinal.dta", clear
collapse (sum) total_amount=amount (mean) mean_amount=amount (count) N=amount, by(cat)
egen grand_total = total(total_amount)
gen percent = 100 * total_amount / grand_total

quietly su mean_amount if cat=="货物", meanonly
global mean_goods : display %9.2f r(mean)
quietly su percent if cat=="货物", meanonly
global percent_goods : display %9.2f r(mean)
quietly su N if cat=="货物", meanonly
global N_goods = r(mean)

quietly su mean_amount if cat=="服务", meanonly
global mean_services : display %9.2f r(mean)
quietly su percent if cat=="服务", meanonly
global percent_services : display %9.2f r(mean)
quietly su N if cat=="服务", meanonly
global N_services = r(mean)

quietly su mean_amount if cat=="工程", meanonly
global mean_construction : display %9.2f r(mean)
quietly su percent if cat=="工程", meanonly
global percent_construction : display %9.2f r(mean)
quietly su N if cat=="工程", meanonly
global N_construction = r(mean)

***************************************************
* 2. By procurement procedure (Top 3)
***************************************************
use "china_procurement_bunchingfinal.dta", clear
keep if inlist(method, "公开招标", "电子卖场", "竞争性磋商")
collapse (sum) total_amount=amount (mean) mean_amount=amount (count) N=amount, by(method)
egen grand_total = total(total_amount)
gen percent = 100 * total_amount / grand_total

quietly su mean_amount if method=="公开招标", meanonly
global mean_open : display %9.2f r(mean)
quietly su percent if method=="公开招标", meanonly
global percent_open : display %9.2f r(mean)
quietly su N if method=="公开招标", meanonly
global N_open = r(mean)

quietly su mean_amount if method=="电子卖场", meanonly
global mean_emarket : display %9.2f r(mean)
quietly su percent if method=="电子卖场", meanonly
global percent_emarket : display %9.2f r(mean)
quietly su N if method=="电子卖场", meanonly
global N_emarket = r(mean)

quietly su mean_amount if method=="竞争性磋商", meanonly
global mean_consult : display %9.2f r(mean)
quietly su percent if method=="竞争性磋商", meanonly
global percent_consult : display %9.2f r(mean)
quietly su N if method=="竞争性磋商", meanonly
global N_consult = r(mean)

***************************************************
* 3. By year
***************************************************
use "china_procurement_bunchingfinal.dta", clear
collapse (sum) total_amount=amount (mean) mean_amount=amount (count) N=amount, by(year)
egen grand_total = total(total_amount)
gen percent = 100 * total_amount / grand_total

levelsof year, local(years)

foreach y of local years {
    quietly su mean_amount if year==`y', meanonly
    global mean_y`y' : display %9.2f r(mean)

    quietly su percent if year==`y', meanonly
    global percent_y`y' : display %9.2f r(mean)

    quietly su N if year==`y', meanonly
    global N_y`y' = r(mean)
}

***************************************************
* LaTeX
***************************************************

texdoc init "/Users/yxy/UChi/Summer2025/Procurement/res/tab/Descriptive_Table.tex", replace force

texdoc write \begin{table}[htbp]\centering
texdoc write \caption{Descriptive Statistics}
texdoc write \renewcommand{\arraystretch}{0.9}
texdoc write \label{tab:desc}
texdoc write \begin{tabular}{p{5cm}p{3cm}cc}
texdoc write \hline\hline
texdoc write Characterization & Volume & Percent & N \\
texdoc write \midrule

* By main object
texdoc write \textbf{By main object} \\
texdoc write Goods & $mean_goods & $percent_goods & $N_goods \\[-3pt]
texdoc write Services & $mean_services & $percent_services & $N_services \\[-3pt]
texdoc write Construction works & $mean_construction & $percent_construction & $N_construction \\

* By procurement procedure
texdoc write \midrule
texdoc write \multicolumn{4}{l}{\textbf{By procurement procedure (Top 3)}} \\
texdoc write Open tender & $mean_open & $percent_open & $N_open \\[-3pt]
texdoc write E-marketplace & $mean_emarket & $percent_emarket & $N_emarket \\[-3pt]
texdoc write Competitive consultation & $mean_consult & $percent_consult & $N_consult \\

* By year
texdoc write \midrule
texdoc write \textbf{By year} \\
foreach y of local years {
    texdoc write `y' & ${mean_y`y'} & ${percent_y`y'} & ${N_y`y'} \\[-3pt]
}

texdoc write \hline\hline
texdoc write \end{tabular}
texdoc write \end{table}
texdoc close

