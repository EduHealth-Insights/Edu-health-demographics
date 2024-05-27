cap program drop mylogitmargins
         program define mylogitmargins, eclass
                syntax [if] [in] [pweight], logit(string) [margins(string) loptions(string) moptions(string)]
                tempname b m
        // compute logit regressions, store results in vectors
                logit `logit' [pw `exp'] `if' `in', `loptions'
                matrix `b'= e(b)
        // compute logit postestimation, store results in vectors
                if "`margins'" != "" | "`moptions'" != ""{
                        margins `margins', post `moptions'
                        matrix `m' = e(b)
                        matrix colnames `m' =  margins:
                        matrix `b'= [`b', `m']
                        }
        // post results
                ereturn post `b' 
        end
