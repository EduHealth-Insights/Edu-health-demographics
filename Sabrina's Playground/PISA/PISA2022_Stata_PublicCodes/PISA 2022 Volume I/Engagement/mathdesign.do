clear
input str10 itemsetA 
CM474Q01S
CM411Q01S
CM411Q02S
CM442Q02S
DM462Q01C
CM192Q01S
CM564Q01S
CM564Q02S
CM447Q01S
CM446Q01S
DM446Q02C
CM982Q01S
CM982Q02S
CM982Q03S
CM982Q04S
CM906Q01S
DM906Q02C
CM909Q01S
CM909Q02S
CM909Q03S
CM943Q01S
CM943Q02S
CM936Q01S
DM936Q02C
CM939Q02S
CMA105Q01
CMA105Q02
CMA105Q03
CMA105Q04
CMA105Q05
CMA136Q02
CMA136Q03
CMA133Q01
CMA133Q02
CMA114Q01
CMA114Q03
CMA114Q04
CMA139Q01
CMA139Q02
CMA127Q01
CMA127Q02
CMA127Q03
CMA152Q01
CMA152Q02
CMA103Q01
CMA103Q02
CMA103Q04
CMA103Q05
CMA107Q01
CMA107Q02
CMA107Q03
CMA120Q01
CMA120Q02
CMA120Q03
CMA119Q01
CMA119Q02
CMA119Q03
CMA153Q01
CMA153Q02
CMA143Q01
CMA143Q02
CMA143Q03
CMA143Q04
CMA157Q01
CMA157Q02
CMA144Q01
CMA144Q03
CMA123Q01
CMA123Q02
CMA102Q01
CMA102Q02
CMA102Q03
CMA149Q01
CMA149Q02
CMA149Q03
CMA121Q01
CMA121Q02
CMA121Q03
end


input str10 itemsetB 
CM496Q01S
CM496Q02S
CM423Q01S
CM571Q01S
CM273Q01S
CM420Q01S
CM559Q01S
DM828Q02C
CM828Q03S
CM464Q01S
CM800Q01S
CM992Q01S
CM992Q02S
DM992Q03C
CM949Q01S
CM949Q02S
DM949Q03C
DM998Q02C
CM954Q01S
DM954Q02C
CM954Q04S
DM953Q02C
CM953Q03S
DM953Q04C
CMA110Q01
CMA110Q02
CMA110Q03
CMA125Q01
CMA125Q02
CMA125Q03
CMA140Q01
CMA140Q02
CMA140Q03
CMA146Q01
CMA146Q02
CMA146Q03
CMA160Q01
CMA160Q02
CMA160Q03
CMA150Q01
CMA150Q02
CMA150Q03
CMA161Q01
CMA161Q02
CMA161Q03
CMA161Q04
CMA131Q01
CMA131Q02
CMA131Q03
CMA131Q04
CMA145Q01
CMA145Q02
CMA101Q01
CMA101Q02
CMA117Q01
CMA117Q02
CMA117Q03
CMA117Q04
CMA129Q01
CMA129Q02
CMA129Q03
CMA132Q01
CMA132Q02
CMA156Q01
CMA151Q01
CMA151Q02
CMA116Q01
CMA116Q02
CMA116Q03
CMA108Q01
CMA108Q02
CMA108Q03
CMA137Q01
CMA137Q03
CMA135Q01
CMA135Q02
CMA135Q03
CMA135Q04

list

input str10 itemsetC
CM033Q01S
DM155Q02C
CM155Q01S
CM155Q04S
CM803Q01S
CM034Q01S
CM305Q01S
CM603Q01S
CM408Q01S
CM915Q01S
CM915Q02S
DM00KQ02C
CM00GQ01S
DM955Q01C
DM955Q02C
CM955Q03S
CM905Q01S
DM905Q02C
CM919Q01S
CM919Q02S
CM948Q01S
CM948Q02S
CM948Q03S
CM967Q01S
CM967Q03S
CMA148Q01
CMA148Q02
CMA148Q03
CMA138Q01
CMA138Q02
CMA162Q01
CMA162Q02
CMA162Q03
CMA154Q01
CMA154Q02
CMA154Q03
CMA130Q01
CMA130Q02
CMA130Q03
CMA147Q01
CMA147Q02
CMA147Q03
CMA147Q04
CMA124Q01
CMA124Q02
CMA124Q03
CMA109Q01
CMA109Q02
CMA109Q03
CMA115Q01
CMA115Q02
CMA112Q01
CMA112Q02
CMA112Q03
CMA126Q02
CMA126Q03
CMA126Q04
CMA128Q01
CMA128Q02
CMA128Q03
CMA134Q01
CMA134Q02
CMA134Q03
CMA142Q01
CMA142Q02
CMA113Q01
CMA113Q02
CMA113Q03
CMA158Q01
CMA158Q02
CMA158Q03
CMA141Q01
CMA141Q02
CMA141Q03
CMA141Q04
CMA111Q01
CMA111Q02
CMA111Q03



foreach item of varlist itemset* {
	replace `item' = substr(lower(`item'),2,5)
}
list

foreach set in A B C {
	levelsof itemset`set', l(itemset`set') clean
}
global itemsetA ""
global itemsetB ""
global itemsetC ""
foreach item in $math2022items {
	foreach unit in `itemsetA' {
		if regexm("`item'","`unit'") global itemsetA "$itemsetA `item'"
	}
	foreach unit in `itemsetB' {
		if regexm("`item'","`unit'") global itemsetB "$itemsetB `item'"
	}
	foreach unit in `itemsetC' {
		if regexm("`item'","`unit'") global itemsetC "$itemsetC `item'"
	}
}
di "`itemsetA'"
di "$itemsetA"