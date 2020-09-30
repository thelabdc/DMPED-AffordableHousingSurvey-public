**Merging the MAR residential units file to the MAR Address Points file using objectid

use "MAR Residential Units.dta"
sort address_id
save "MAR Residential Units.dta", replace
clear

use "MAR Address Points.dta"
sort address_id

save "MAR Address Points.dta", replace
clear

use "MAR Residential Units.dta", clear
merge m:1 address_id using "MAR Address Points.dta"

rename _merge MAR_merge

save "MAR2.dta", replace

**Systematically adding the wards to unit-level addresses that are missing them. 
encode ward, gen(wardx)
label define wardx 0 "BLANK" 1 "Ward 1" 2 "Ward 2" 3 "Ward 3" 4 "Ward 4" 5 ///
"Ward 5" 6 "Ward 6" 7 "Ward 7" 8 "Ward 8", replace
egen wardnewx = max(wardx) , by(fulladdress)

rename wardnewx ward_sample
drop wardx 

**Drop nonresidential or demolished properties

drop if type_ == "PLACE"
drop if res_type == "NON RESIDENTIAL"
drop if status == "ASSIGNED" 
drop if status == "RETIRE" 
drop if status == "TEMPORARY"

save "MAR2.dta", replace

**Now merge in the tax data using ssl 
sort ssl
save "MAR2.dta", replace
clear

use "TaxData.dta"
sort ssl 
save "TaxData.dta", replace
clear

use "MAR2.dta", clear
merge m:1 ssl using "TaxData.dta", force
save "SurveySamplingFrame.dta",replace

**Dropping extra tax file data
drop if _merge ==2 

**Dropping by tax category.

tab mix2txtype 
sort mix2txtype 

*E1, Religous
*E2, Educational
*E4, Hospitals
*E5, Libaries
*E6, Foreign government 
*E7, Cemeteries
*E8, Miscellaneous (these appear to be tax exempt multifamily dwellings). 
*E9, WMATA
*HP, Homestead Preservation 
*RL, DCRLA
*US, United States

drop if mix2txtype == "E2"
drop if mix2txtype == "E4"
drop if mix2txtype == "E5"
drop if mix2txtype == "E6"
drop if mix2txtype == "E7"
drop if mix2txtype == "E9"

*Some properties owned by religious organizations appear to be used as homes/shelters, 
*especially the #multi-unit properties. Dropping the properties that are taxed as 
*religious but are not multi-unit. 

replace unitnum = "BLANK" if missing(unitnum)

drop if mix2txtype == "E1" & unitnum == "BLANK"

save "SurveySamplingFrame.dta", replace

**Dropping by use code.  

*Dormitories
drop if usecode == 36 

*Medical
drop if usecode == 82

*Educational 
drop if usecode == 83 

*Embassy, chancery
drop if usecode == 85 

*Museum, library, gallery
drop if usecode == 86 

*Healthcare facility 
drop if usecode == 88 

*Vacant-True
drop if usecode == 91 

*Vacant-with permit
drop if usecode == 92 

*Vacant-true
drop if usecode == 191 

*Vacant-with permit
drop if usecode == 192 

*Vacant-Unimproved parking
drop if usecode == 196 

*Vacant-Improved and abandoned
drop if usecode == 197 

save "SurveySamplingFrame.dta", replace

replace ward = "BLANK" if missing(ward)

save "SurveySamplingFrame.dta", replace

**Sampling by ward

sort ward_sample 
by ward_sample: count
by ward_sample: sample 2600, count 

save "WardSamples.dta"





