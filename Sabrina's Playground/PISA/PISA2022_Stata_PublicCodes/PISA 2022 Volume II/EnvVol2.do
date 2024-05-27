**********************.**********************.
**********************.**********************.
*** PISA 2022 INITIAL REPORT VOLUME 2
*** ENVIRONMENT
***
*** 
*** DEFINE THE VOLUME SPECIFIC ENVIRONMENT-
***
** Creation Date: 01/01/2023												 
** Author: PISA TEAM, OECD													  
** Last Modification: 31/12/2023		
**********************.**********************.
**********************.**********************.

** Location of files
global			confidentialdata 	"c:\temp\sources"
global			infile 				"c:\temp\Infile"
global			outfile 			"c:\temp\Outfile"
global			dofiles 			"c:\temp\Do-file"
global			logs	 			"c:\temp\Logs"

** Current directory
cd "$outfile"

** Country lists
global 			CNT2022 "ALB ARE ARG AUS AUT BEL BGR BRA BRN CAN CHE  CHL  COL CRI CZE DEU DNK DOM ESP EST FIN FRA GBR GEO GRC GTM HKG HRV HUN IDN IRL ISL ISR ITA JAM JOR JPN KAZ KHM KOR KSV LTU LVA MAC MAR MDA MEX MKD MLT MNE MNG MYS NLD NOR NZL PAN PER PHL POL PRT PRY PSE  QAT QAZ QUR ROU SAU SGP SLV SRB SVK SVN  SWE TAP THA TUR URY USA UZB VNM"  //81 countries for PISA 2022
global 			AVG2022 "AUS AUT BEL CAN CHE CHL COL CRI CZE DEU DNK ESP EST FIN FRA GBR GRC HUN IRL ISL ISR ITA JPN KOR LTU LVA MEX NLD NOR NZL POL PRT SVK SVN  SWE TUR USA" //37 OECD countries
global 			AVG2022adj "DEU FIN SVK JPNCRI TUR CZE COL BEL SVN ISL ITA SWE GRC MEX NOR LTU ISR HUN AUT CHE POL EST PRT FRA ESP KOR" //28 cnts


global repestoptions "pisacoverage flag fast svyparms(NREP(2))"   
