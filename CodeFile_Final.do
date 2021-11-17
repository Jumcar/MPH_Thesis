**------------------------------------------------------------------------------*/
/* 	Project: 		Co-Twin Control Study of Physical Activity, Resilience, & 
					Symptoms of Depression & Anxiety During the COVID-19 Pandemic Repsonse 
					------------------------------------------------------------
	Analyst:		Julia Caruana
**------------------------------------------------------------------------------*/

** LOAD DIRECTORY

/*---------------------------------------------------------------------------------------
	DEMOGRAPHIC DESCRIPTIVES
*-----------------------------------------------------------------------------------------
	Parse Study ID Variable
----------------------------------------------------------------------------------------*/
	split intProject_UID, p(-) 		/* Splits ID variable to generate additional pair_ID and twin_ID variables*/
	rename intProject_UID1 pair_ID 	/* Rename pair_ID */
	rename intProject_UID2 twin_ID 	/* Rename twin_ID */
/*-----------------------------------------------------------------------------------------
	Same-Sex Pair Identifier
----------------------------------------------------------------------------------------*/
	gen twin_ID_n=. 						/*Create numerical twin identifier */
	replace twin_ID_n=1 if twin_ID=="A"		/* Recode string to numeric */
	replace twin_ID_n=2 if twin_ID=="B"		/* Recode string to numeric */
	destring pair_ID, generate (pair_ID_n)	/* De-string Pair ID to numeric */
	sort pair_ID_n twin_ID_n				/* Sort numeric pair and twin identifiers */
	* Generate string variable for gender
	generate db_gender_string=""					/* Generate string variable for gender */ 
	replace db_gender_string="M" if db_gender==1	/*1 = Male */
	replace db_gender_string="F" if db_gender==2	/*2 = Female */
	* Generate pair sex variable where MM = male only, FF = female only 
	by pair_ID_n: gen sex_sex = db_gender_string[_n]+db_gender_string[_n+1]			/* Generate pair sex variable*/ 
	replace sex_sex = db_gender_string[_n]+db_gender_string[_n-1] if sex_sex=="M"	/* Generate string sex*/ 
	replace sex_sex = db_gender_string[_n]+db_gender_string[_n-1] if sex_sex=="F"	/* Generate string sex*/ 
	* Generate same sex pairs indicator
	generate same_sex=.						
	replace same_sex=1 if sex_sex=="MM"		
	replace same_sex=1 if sex_sex=="FF"
	replace same_sex=0 if sex_sex=="MF"
	replace same_sex=0 if sex_sex=="FM"
	label define same_sex_label 1 "Same sex pair" 0 "Different sex pair" 
	label values same_sex same_sex_label 
*----------------------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------------------
	CLEAN: Location of Participant at time of responding
-----------------------------------------------------------------------------------------
Aim: 	1. Clean state and postcode variables. 
		2. Work out which participants are excluded on basis of being outside Australia/ moving during lockdown. 
-----------------------------------------------------------------------------------------
	CLEAN STATE RESPONSES
----------------------------------------------------------------------------------------*/
	* Clean State Variable
	gen state_clean =.
	replace state_clean=. if state=="2"
	replace state_clean=7 if state=="7: VIC"
	replace state_clean=1 if state=="ACT"
	replace state_clean=4 if state=="AU-QLD"
	replace state_clean=. if state=="Auckland"
	replace state_clean=. if state=="Australia"
	replace state_clean=1 if state=="Australian Capital Territory"
	replace state_clean=. if state=="Cork "
	replace state_clean=. if state=="E"
	replace state_clean=3 if state=="N S W"
	replace state_clean=3 if state=="N.S.W,"
	replace state_clean=3 if state=="N.S.W."
	replace state_clean=3 if state=="NEW SOUTH WALES"
	replace state_clean=3 if state=="NSW"
	replace state_clean=3 if state=="NSW "
	replace state_clean=2 if state=="NT"
	replace state_clean=3 if state=="New South Wales"
	replace state_clean=2 if state=="Northern Territory"
	replace state_clean=3 if state=="Nsw"
	replace state_clean=3 if state=="Nsw "
	replace state_clean=4 if state=="QLD"
	replace state_clean=4 if state=="QLD "
	replace state_clean=4 if state=="QUEENSLAND"
	replace state_clean=4 if state=="Qld"
	replace state_clean=4 if state=="Qld "
	replace state_clean=4 if state=="Qld."
	replace state_clean=4 if state=="Queensland"
	replace state_clean=4 if state=="Queensland "
	replace state_clean=5 if state=="SA"
	replace state_clean=5 if state=="Sa"
	replace state_clean=5 if state=="South Australia"
	replace state_clean=5 if state=="South Australia "
	replace state_clean=6 if state=="TAS"
	replace state_clean=6 if state=="TASMANIA"
	replace state_clean=6 if state=="Tas"
	replace state_clean=6 if state=="Tasmania"
	replace state_clean=6 if state=="Tasmania "
	replace state_clean=7 if state=="VIC"
	replace state_clean=7 if state=="VIC "
	replace state_clean=7 if state=="VICTORIA"
	replace state_clean=7 if state=="VICTORIA "
	replace state_clean=7 if state=="Vic"
	replace state_clean=7 if state=="Vic "
	replace state_clean=7 if state=="Vic hi"
	replace state_clean=7 if state=="Vic."
	replace state_clean=7 if state=="Victoria"
	replace state_clean=7 if state=="Victoria "
	replace state_clean=7 if state=="Voctoria"
	replace state_clean=7 if state=="Vuc"
	replace state_clean=8 if state=="W.A."
	replace state_clean=8 if state=="WA"
	replace state_clean=8 if state=="Wa"
	replace state_clean=8 if state=="Western Australia"
	replace state_clean=8 if state=="Western Australia "
	replace state_clean=8 if state=="Western Australian "
	replace state_clean=1 if state=="act"
	replace state_clean=. if state=="n/a"
	replace state_clean=3 if state=="nsw"
	replace state_clean=4 if state=="qld"
	replace state_clean=5 if state=="sa"
	replace state_clean=5 if state=="south Australia "
	replace state_clean=5 if state=="south australia"
	replace state_clean=6 if state=="tasmania"
	replace state_clean=7 if state=="vic"
	replace state_clean=7 if state=="vic "
	replace state_clean=7 if state=="victoria"
	replace state_clean=8 if state=="wa"
	replace state_clean=8 if state=="western australia"
	replace state_clean=. if state==""
	* Label Variables: 1 = ACT, 2 = NT, 3 = NSW, 4 = QLD, 5 = SA, 6 = TAS, 7 = VIC, 8 = WA. 
	label define state_clean_label 1 "ACT" 2 "NT" 3 "NSW" 4 "QLD" 5 "SA" 6 "TAS" 7 "VIC" 8 "WA"
	label values state_clean state_clean_label 
	/*-----------------------------------------------------------------------------------------
		CLEAN POSTCODE RESPONSES
	----------------------------------------------------------------------------------------*/
	** Clean postcodes
	gen postcode_clean=postcode
	replace postcode_clean="3142" if postcode_clean=="Victoria 3142"
	replace postcode_clean="7303" if postcode_clean=="7303 "
	replace postcode_clean="" if postcode_clean=="31404"
	replace postcode_clean="" if postcode_clean=="."
	/*-----------------------------------------------------------------------------------------
		REPLACE MISSING STATES BASED ON POSTCODES SUPPLIED
	----------------------------------------------------------------------------------------*/
	** Update missing state_clean values based on postcode_clean values  
	* NSW
	replace state_clean=3 if postcode_clean=="2069"
	replace state_clean=3 if postcode_clean=="2155"
	* ACT
	replace state_clean=1 if postcode_clean=="2548"
	replace state_clean=1 if postcode_clean=="2617"
	* VIC
	replace state_clean=7 if postcode_clean=="3031"
	replace state_clean=7 if postcode_clean=="3034"
	replace state_clean=7 if postcode_clean=="3046"
	replace state_clean=7 if postcode_clean=="3124"
	replace state_clean=7 if postcode_clean=="3133"
	replace state_clean=7 if postcode_clean=="3141"
	replace state_clean=7 if postcode_clean=="3149"
	replace state_clean=7 if postcode_clean=="3163"
	replace state_clean=7 if postcode_clean=="3222"
	replace state_clean=7 if postcode_clean=="3781"
	* QLD
	replace state_clean=4 if postcode_clean=="4051"
	* SA
	replace state_clean=5 if postcode_clean=="5131"
	* WA
	replace state_clean=8 if postcode_clean=="6007"
/*-----------------------------------------------------------------------------------------
	WITHIN AUSTRALIA
----------------------------------------------------------------------------------------*/
	* living_australia = currently living in Australia, 0 = no, 1 = yes.
	* Clean country variable, binary categorical Australia vs Overseas. 
	gen country_clean =.
	*Overseas 
	replace country_clean=2 if living_australia==0
	replace country_clean=2 if country=="Austria"
	replace country_clean=2 if country=="Canada"
	replace country_clean=2 if country=="England"
	replace country_clean=2 if country=="England, Uk"
	replace country_clean=2 if country=="Ireland "
	replace country_clean=2 if country=="Netherlands"
	replace country_clean=2 if country=="New Zealand"
	replace country_clean=2 if country=="New Zealand "
	replace country_clean=2 if country=="New zealand"
	replace country_clean=2 if country=="Singapore"
	replace country_clean=2 if country=="Spain"
	replace country_clean=2 if country=="UK"
	replace country_clean=2 if country=="USA"
	replace country_clean=2 if country=="United Arab Emirates"
	replace country_clean=2 if country=="United Kingdom"
	replace country_clean=2 if country=="United Kingdom "
	replace country_clean=2 if country=="United States"
	replace country_clean=2 if country=="United States America"
	replace country_clean=2 if country=="United States of America"
	*Within Australia
	replace country_clean=1 if living_australia==1
	replace country_clean=1 if state_clean==1
	replace country_clean=1 if state_clean==2
	replace country_clean=1 if state_clean==3
	replace country_clean=1 if state_clean==4
	replace country_clean=1 if state_clean==5
	replace country_clean=1 if state_clean==6
	replace country_clean=1 if state_clean==7
	replace country_clean=1 if state_clean==8
	replace country_clean=1 if country=="Australia"
	replace country_clean=1 if country=="Australia "
	* Label Variables: 1 = Australia, 2 = Not Australia
	label define country_clean_label 1 "Australia" 2 "Overseas" 
	label values country_clean country_clean_label 
	* tab country_clean		// 43 (2.74%) reported not living in Australia at time of responding
*==========================================================================================*/	

*==========================================================================================*/
*	APPLY SAMPLE EXCLUSIONS
*==========================================================================================*/
			* Exclude if overseas. 
				tab country_clean				// 43 people were overseas at time of responding
				keep if country_clean== 1		// 43 participants deleted (either Australia or no country reported)
			*------------------------------------
			* Exclude if any response to key variable measures missing
			egen nmis_keyvars=rmiss2(QS41_walk_moderate QS41_walk_vigorously QS38_dassQ3_positive_feeling 	QS38_dassQ5_initiative_diff QS38_dassQ10_look_forward QS38_dassQ13_blue QS38_dassQ16_unable_enthus QS38_dassQ17_worthless QS38_dassQ21_meaningless)
			*------------------------------------
			* Number participants with missing scores
				* tab nmis_keyvars	// 1363 had complete data, 164 missing ≥1 of key variable items
				* Keep if no PA response missing
				keep if nmis_keyvars == 0
			*------------------------------------
			* Keep only if co-twin still included
				* tab twin_ID_n
					sort pair_ID_n twin_ID_n
					by pair_ID_n: generate n2a = _N	// generate n2 indicating the number of twins remaining for each pair
					list pair_ID_n twin_ID_n n2a		// investigate missing pairs
					keep if n2a==2					// delete incomplete twin pairs
					
				tab twin_ID_n					// Check even count of twin 1 and twin 2 --> yes, 601 pairs
			tab pair_ID_n					// 1202 participants remain
			*------------------------------------
			* Keep if same-sex twin pair. 
				keep if same_sex==1
				tab twin_ID_n		// Check even count of twin 1 and twin 2 --> yes, 561 pairs
				tab same_sex		// 1122 participants belonging to 561 same-sex twin pairs, residing in Australia, with complete data on key variables.

				
				/*=========================================================================================
	SCORING LOCKDOWN EXPOSURE
==========================================================================================*/
*	BINARY LOCKDOWN VARIABLE 
	* At time of responding, was individual in lockdown?
	* Everyone outside of Victoria will have been out of lockdown --> 0
	*For people in Victoria -- need to check date of survey commencement & postcode. 

		gen lockdown_bin =.
	** Non-Victorian States 
		* lockdown_bin == 0 if not in Vic
		replace lockdown_bin=0 if state_clean==1
		replace lockdown_bin=0 if state_clean==2
		replace lockdown_bin=0 if state_clean==3
		replace lockdown_bin=0 if state_clean==4
		replace lockdown_bin=0 if state_clean==5
		replace lockdown_bin=0 if state_clean==6
		replace lockdown_bin=0 if state_clean==8
		
	** Victorians who started survey before September 16 were in lockdown
		* lockdown_bin == 2 if in VIC. 
		replace lockdown_bin=1 if state_clean==7
		replace lockdown_bin=2 if state_clean==7 & date_started>date("20200916","YMD")
		replace lockdown_bin=1 if postcode_clean=="3055" & date_started>date("20200916","YMD") // metro melb in lockdown to 28Oct
		replace lockdown_bin=1 if postcode_clean=="3121" & date_started>date("20200916","YMD") // metro melb in lockdown to 28Oct
		replace lockdown_bin=1 if postcode_clean=="3070" & date_started>date("20200916","YMD") // metro melb in lockdown to 28Oct
		replace lockdown_bin=1 if postcode_clean=="3108" & date_started>date("20200916","YMD") // metro melb in lockdown to 28Oct
		replace lockdown_bin=1 if postcode_clean=="3068" & date_started>date("20200916","YMD") // metro melb in lockdown to 28Oct
		replace lockdown_bin=1 if postcode_clean=="3161" & date_started>date("20200916","YMD") // metro melb in lockdown to 28Oct
		replace lockdown_bin=1 if postcode_clean=="3414" & date_started>date("20200916","YMD") // metro melb in lockdown to 28Oct
		replace lockdown_bin=0 if postcode_clean=="3084" & date_started>date("20200916","YMD") // out of lockdown
		replace lockdown_bin=0 if postcode_clean=="3723" & date_started>date("20200916","YMD") // out of lockdown
		replace lockdown_bin=0 if postcode_clean=="3216" & date_started>date("20200916","YMD") // out of lockdown
	* Label Variables: 1 = Australia, 2 = Not Australia
		label define lockdown_bin_lab 0 "Not in Lockdown" 1 "In Lockdown" 
		label values lockdown_bin lockdown_bin_lab 	
	 tab lockdown_bin
*=========================================================================================
* METRO MELB
gen metro_melb =.
** Non-Victorian States 
		replace metro_melb=0 if state_clean==7
		
* postcode_clean belongs to Metro Melb. 
		replace metro_melb=1 if postcode_clean=="3067" 
		replace metro_melb=1 if postcode_clean=="3067" 
		replace metro_melb=1 if postcode_clean=="3040" 
		replace metro_melb=1 if postcode_clean=="3042" 
		replace metro_melb=1 if postcode_clean=="3021" 
		replace metro_melb=1 if postcode_clean=="3206" 
		replace metro_melb=1 if postcode_clean=="3020" 
		replace metro_melb=1 if postcode_clean=="3078" 
		replace metro_melb=1 if postcode_clean=="3018" 
		replace metro_melb=1 if postcode_clean=="3028" 
		replace metro_melb=1 if postcode_clean=="3000" 
		replace metro_melb=1 if postcode_clean=="3002" 
		replace metro_melb=1 if postcode_clean=="3004" 
		replace metro_melb=1 if postcode_clean=="3011" 
		replace metro_melb=1 if postcode_clean=="3012" 
		replace metro_melb=1 if postcode_clean=="3016" 
		replace metro_melb=1 if postcode_clean=="3018" 
		replace metro_melb=1 if postcode_clean=="3021" 
		replace metro_melb=1 if postcode_clean=="3027" 
		replace metro_melb=1 if postcode_clean=="3028" 
		replace metro_melb=1 if postcode_clean=="3029" 
		replace metro_melb=1 if postcode_clean=="3030" 
		replace metro_melb=1 if postcode_clean=="3031" 
		replace metro_melb=1 if postcode_clean=="3032" 
		replace metro_melb=1 if postcode_clean=="3034" 
		replace metro_melb=1 if postcode_clean=="3037" 
		replace metro_melb=1 if postcode_clean=="3038" 
		replace metro_melb=1 if postcode_clean=="3040" 
		replace metro_melb=1 if postcode_clean=="3041" 
		replace metro_melb=1 if postcode_clean=="3042"
		replace metro_melb=1 if postcode_clean=="3043"
		replace metro_melb=1 if postcode_clean=="3044"
		replace metro_melb=1 if postcode_clean=="3047" 
		replace metro_melb=1 if postcode_clean=="3052" 
		replace metro_melb=1 if postcode_clean=="3055" 
		replace metro_melb=1 if postcode_clean=="3056" 
		replace metro_melb=1 if postcode_clean=="3057" 
		replace metro_melb=1 if postcode_clean=="3058" 
		replace metro_melb=1 if postcode_clean=="3060" 
		replace metro_melb=1 if postcode_clean=="3064" 
		replace metro_melb=1 if postcode_clean=="3065" 
		replace metro_melb=1 if postcode_clean=="3067" 
		replace metro_melb=1 if postcode_clean=="3068" 
		replace metro_melb=1 if postcode_clean=="3070" 
		replace metro_melb=1 if postcode_clean=="3073" 
		replace metro_melb=1 if postcode_clean=="3078" 
		replace metro_melb=1 if postcode_clean=="3079" 
		replace metro_melb=1 if postcode_clean=="3083" 
		replace metro_melb=1 if postcode_clean=="3084" 
		replace metro_melb=1 if postcode_clean=="3085" 
		replace metro_melb=1 if postcode_clean=="3087" 
		replace metro_melb=1 if postcode_clean=="3088" 
		replace metro_melb=1 if postcode_clean=="3093" 
		replace metro_melb=1 if postcode_clean=="3101" 
		replace metro_melb=1 if postcode_clean=="3104" 
		replace metro_melb=1 if postcode_clean=="3106" 
		replace metro_melb=1 if postcode_clean=="3107" 
		replace metro_melb=1 if postcode_clean=="3108" 
		replace metro_melb=1 if postcode_clean=="3109" 
		replace metro_melb=1 if postcode_clean=="3115" 
		replace metro_melb=1 if postcode_clean=="3121" 
		replace metro_melb=1 if postcode_clean=="3122" 
		replace metro_melb=1 if postcode_clean=="3123" 
		replace metro_melb=1 if postcode_clean=="3124" 
		replace metro_melb=1 if postcode_clean=="3126" 
		replace metro_melb=1 if postcode_clean=="3127" 
		replace metro_melb=1 if postcode_clean=="3128" 
		replace metro_melb=1 if postcode_clean=="3129" 
		replace metro_melb=1 if postcode_clean=="3130" 
		replace metro_melb=1 if postcode_clean=="3131" 
		replace metro_melb=1 if postcode_clean=="3132" 
		replace metro_melb=1 if postcode_clean=="3133" 
		replace metro_melb=1 if postcode_clean=="3134" 
		replace metro_melb=1 if postcode_clean=="3135" 
		replace metro_melb=1 if postcode_clean=="3136" 
		replace metro_melb=1 if postcode_clean=="3141" 
		replace metro_melb=1 if postcode_clean=="3142" 
		replace metro_melb=1 if postcode_clean=="3143" 
		replace metro_melb=1 if postcode_clean=="3144" 
		replace metro_melb=1 if postcode_clean=="3145" 
		replace metro_melb=1 if postcode_clean=="3146" 
		replace metro_melb=1 if postcode_clean=="3147" 
		replace metro_melb=1 if postcode_clean=="3148" 
		replace metro_melb=1 if postcode_clean=="3149" 
		replace metro_melb=1 if postcode_clean=="3150" 
		replace metro_melb=1 if postcode_clean=="3152" 
		replace metro_melb=1 if postcode_clean=="3153" 
		replace metro_melb=1 if postcode_clean=="3154" 
		replace metro_melb=1 if postcode_clean=="3156" 
		replace metro_melb=1 if postcode_clean=="3158" 
		replace metro_melb=1 if postcode_clean=="3160" 
		replace metro_melb=1 if postcode_clean=="3161" 
		replace metro_melb=1 if postcode_clean=="3162" 
		replace metro_melb=1 if postcode_clean=="3163" 
		replace metro_melb=1 if postcode_clean=="3165" 
		replace metro_melb=1 if postcode_clean=="3166" 
		replace metro_melb=1 if postcode_clean=="3167" 
		replace metro_melb=1 if postcode_clean=="3171" 
		replace metro_melb=1 if postcode_clean=="3173" 
		replace metro_melb=1 if postcode_clean=="3182" 
		replace metro_melb=1 if postcode_clean=="3184" 
		replace metro_melb=1 if postcode_clean=="3185" 
		replace metro_melb=1 if postcode_clean=="3186" 
		replace metro_melb=1 if postcode_clean=="3187" 
		replace metro_melb=1 if postcode_clean=="3188" 
		replace metro_melb=1 if postcode_clean=="3190" 
		replace metro_melb=1 if postcode_clean=="3191" 
		replace metro_melb=1 if postcode_clean=="3192" 
		replace metro_melb=1 if postcode_clean=="3193" 
		replace metro_melb=1 if postcode_clean=="3194" 
		replace metro_melb=1 if postcode_clean=="3195" 
		replace metro_melb=1 if postcode_clean=="3197" 
		replace metro_melb=1 if postcode_clean=="3198" 
		replace metro_melb=1 if postcode_clean=="3199" 
		replace metro_melb=1 if postcode_clean=="3204" 
		replace metro_melb=1 if postcode_clean=="3205" 
		replace metro_melb=1 if postcode_clean=="3207" 
		replace metro_melb=1 if postcode_clean=="3338" 
		replace metro_melb=1 if postcode_clean=="3429" 
		replace metro_melb=1 if postcode_clean=="3750" 
		replace metro_melb=1 if postcode_clean=="3752" 
		replace metro_melb=1 if postcode_clean=="3754" 
		replace metro_melb=1 if postcode_clean=="3781" 
		replace metro_melb=1 if postcode_clean=="3782" 
		replace metro_melb=1 if postcode_clean=="3793" 
		replace metro_melb=1 if postcode_clean=="3802" 
		replace metro_melb=1 if postcode_clean=="3803" 
		replace metro_melb=1 if postcode_clean=="3805" 
		replace metro_melb=1 if postcode_clean=="3806" 
		replace metro_melb=1 if postcode_clean=="3810" 
		replace metro_melb=1 if postcode_clean=="3912" 
		replace metro_melb=1 if postcode_clean=="3916" 
		replace metro_melb=1 if postcode_clean=="3928" 
		replace metro_melb=1 if postcode_clean=="3930" 
		replace metro_melb=1 if postcode_clean=="3931" 
		replace metro_melb=1 if postcode_clean=="3934" 
		replace metro_melb=1 if postcode_clean=="3936" 
		replace metro_melb=1 if postcode_clean=="3938" 
		replace metro_melb=1 if postcode_clean=="3940" 
		replace metro_melb=1 if postcode_clean=="3976" 
		replace metro_melb=1 if postcode_clean=="3978" // postcode_clean within Metro Melb
		*----------------------------------
		* Lockdown days == 172 if postcode 3012, 3021, 3032, 3038, 3042, 3046, 3047, 3055, 3060, 3064. 
		replace metro_melb=1 if postcode_clean=="3012"
		replace metro_melb=1 if postcode_clean=="3021"
		replace metro_melb=1 if postcode_clean=="3032"
		replace metro_melb=1 if postcode_clean=="3038"
		replace metro_melb=1 if postcode_clean=="3042"
		replace metro_melb=1 if postcode_clean=="3046"
		replace metro_melb=1 if postcode_clean=="3047"
		replace metro_melb=1 if postcode_clean=="3055"
		replace metro_melb=1 if postcode_clean=="3060"
		replace metro_melb=1 if postcode_clean=="3064"
		*----------------------------------
		* Lockdown days == 168 if postcode 3031, 3051. 
		replace metro_melb=1 if postcode_clean=="3031"
		replace metro_melb=1 if postcode_clean=="3051"
*----------------------------------
		tab metro_melb
*---------------------------------------------------------------------------------------


*=========================================================================================
*	QUESTIONNAIRE SCORING 
*=========================================================================================
*	SCORING PHYSICAL ACTIVITY
	* tab QS41_walk_moderate 
	* tab QS41_walk_vigorously
	* tab2 QS41_walk_moderate QS41_walk_vigorously
	* tab twin_ID_n
	* Recode to estimate minutes per week. 
	* Moderate Exercise
			gen modexercise_mins =.
			replace modexercise_mins=0 if QS41_walk_moderate==0
			replace modexercise_mins=30 if QS41_walk_moderate==1
			replace modexercise_mins=60 if QS41_walk_moderate==2
			replace modexercise_mins=90 if QS41_walk_moderate==3
			replace modexercise_mins=120 if QS41_walk_moderate==4
			replace modexercise_mins=150 if QS41_walk_moderate==5
			replace modexercise_mins=180 if QS41_walk_moderate==6
			replace modexercise_mins=210 if QS41_walk_moderate==7
	* Vigorous Exercise
			gen vigexercise_mins =.
			replace vigexercise_mins=0 if QS41_walk_vigorously==0
			replace vigexercise_mins=20 if QS41_walk_vigorously==1
			replace vigexercise_mins=40 if QS41_walk_vigorously==2
			replace vigexercise_mins=60 if QS41_walk_vigorously==3
			replace vigexercise_mins=80 if QS41_walk_vigorously==4
			replace vigexercise_mins=100 if QS41_walk_vigorously==5
			replace vigexercise_mins=120 if QS41_walk_vigorously==6
			replace vigexercise_mins=140 if QS41_walk_vigorously==7	
	*----------------------------------------------------------*/	
		* browse
		* tab modexercise_mins
	/*----------------------------------
		CONVERT TO CATEGORICAL PA_Status: MEETS RECOMMENDED PA GUIDELINES
		RECOMMENDED SCORING METHOD from Nyberg et al in Jama
		https://jamanetwork.com/journals/jamainternalmedicine/fullarticle/2763720
		
		(0 points) Poor= <60 mins mod and <20 minutes vigorous 	
		(1 point) Intermediate= 60-150 mins mod or <75mins vig	
		(2 points) Optimal= >=150mins mod or >=75 mins vig activity	    */

		gen PA_status =.
		replace PA_status=0 if (modexercise_mins<60 & vigexercise_mins<20)
		replace PA_status=1 if inrange(modexercise_mins,60,149) | inrange(vigexercise_mins,20,74)
		replace PA_status=2 if (modexercise_mins>=150) | (vigexercise_mins>=75)
		label define PA_status_label 0 "Poor" 1 "Intermediate" 2 "Optimal"
		label values PA_status PA_status_label 
	*----------------------------------
		tab PA_status 		// Poor = 336, Intermediate = 449, Optimal = 337
			
		gen PA_status_rev =.
		replace PA_status_rev=2 if (modexercise_mins<60 & vigexercise_mins<20)
		replace PA_status_rev=1 if inrange(modexercise_mins,60,149) | inrange(vigexercise_mins,20,74)
		replace PA_status_rev=0 if (modexercise_mins>=150) | (vigexercise_mins>=75)
		label define PA_status_rev_lavel 0 "Optimal" 1 "Intermediate" 2 "Poor"
		label values PA_status_rev PA_status_rev_label 
	*----------------------------------
		tab PA_status_rev		// Poor = 336, Intermediate = 449, Optimal = 337
*----------------------------------------------------------------------------------------*/

		tab Q36_current_level_exercise

		gen PA_change =.
		replace PA_change=0 if Q36_current_level_exercise==-2
		replace PA_change=0 if Q36_current_level_exercise==-1
		replace PA_change=1 if Q36_current_level_exercise==0
		replace PA_change=2 if Q36_current_level_exercise==1
		replace PA_change=2 if Q36_current_level_exercise==2
		replace PA_change=. if Q36_current_level_exercise==.
		label define PA_change_label 0 "Worsened" 1 "Stayed the same" 2 "Improved"
		label values PA_change PA_change_label 
	*----------------------------------
		tab PA_change 		// Poor = 336, Intermediate = 449, Optimal = 337

		gen PA_change_rev =.
		replace PA_change_rev=2 if Q36_current_level_exercise==-2
		replace PA_change_rev=2 if Q36_current_level_exercise==-1
		replace PA_change_rev=1 if Q36_current_level_exercise==0
		replace PA_change_rev=0 if Q36_current_level_exercise==1
		replace PA_change_rev=0 if Q36_current_level_exercise==2
		replace PA_change_rev=. if Q36_current_level_exercise==.
		label define PA_change_rev_label 0 "Improved" 1 "Stayed the same" 2 "Worsened"
		label values PA_change_rev PA_change_rev_label 
	*----------------------------------
		tab PA_change_rev 		// Poor = 336, Intermediate = 449, Optimal = 337
			
*=========================================================================================
*	SCORE DASS Subscales
*=========================================================================================
/*-----------------------------------------------------------------------------------------
	Depression Subscale
----------------------------------------------------------------------------------------*/
* Generate DASS-21 depression variable. Sum of items: 3, 5, 10, 13, 16, 17, 21
gen DASS_depress = QS38_dassQ3_positive_feeling + QS38_dassQ5_initiative_diff + QS38_dassQ10_look_forward + QS38_dassQ13_blue + QS38_dassQ16_unable_enthus  + QS38_dassQ17_worthless + QS38_dassQ21_meaningless

	* Symptom cut-offs 
		gen depression_cat=.
		replace depression_cat=1 if DASS_depress<5					// Normal
		replace depression_cat=2 if inrange(DASS_depress,5,6)		// Mild
		replace depression_cat=3 if inrange(DASS_depress,7,10)		// Mod
		replace depression_cat=4 if inrange(DASS_depress,11,13)		// Severe
		replace depression_cat=5 if DASS_depress>=14				// Extremely Severe
		* Label Thresholds
		label define depresscatl 1 "Normal" 2 "Mild" 3 "Moderate" 4 "Severe" 5 "Extremely Severe"
		label values depression_cat depresscatl 

	** Symptom Depression Moderate or More
		gen depression_mod =.
		replace depression_mod=0 if DASS_depress< 7
		replace depression_mod=1 if DASS_depress>=7
		* Label Thresholds
		label define depression_modlab 0 "Normal - Mild" 1 "Moderate - Extremely Severe"
		label values depression_mod depression_modlab

		* Check Distribution
		tab DASS_depress		
		tab depression_cat
		tab depression_mod		

*=========================================================================================
*	SCORE PHYSICAL HEALTH & LIFESTYLE BEHAVIOUR COVARIATES
*=========================================================================================
*	BMI
*----------------------------------------------------------------------------------------*/
		gen height_metres =.
		replace height_metres=(Q8_height/100)
		* Correct mistaken value: extreme outlier. 
		replace height_metres=1.6 if height_metres==16
		* BMI Calc
		gen BMI = Q7_weight/ (height_metres^2)
/*-----------------------------------------------------------------------------------------
	Weight Status
----------------------------------------------------------------------------------------*/
*BMI values of less than 18 were considered underweight, from 18.5 to 25 was considered normal weight, from 25 to 30 was considered overweight, and greater than 30 was considered obese. 
		gen weight_status =.
		*Within Australia
		replace weight_status=1 if BMI<18.5
		replace weight_status=2 if inrange(BMI,18.5,25)
		replace weight_status=3 if inrange(BMI,25,30)
		replace weight_status=4 if BMI>30
		replace weight_status=. if BMI==.
		label define weight_status_label 1 "Underweight" 2 "Normal" 3 "Overweight" 4 "Obese"
		label values weight_status weight_status_label 
/*-----------------------------------------------------------------------------------------
	Smoking
----------------------------------------------------------------------------------------*/
**	KEY VARIABLES: QS39_smoking_status = Which of the following best describes your smoking status throughout your life?
**	Scoring: 1="I have never smoked"; 2="I have smoked occasionally but quit";3="I have smoked regularly (daily) but quit"; 4="I smoke occasionally";5="I smoke regularly (daily)"
* Participants were considered current non-smokers if they reported either: having never smoked, having smoked occasionally but quit, or having smoked regularly (daily) but quit
* Participants were considered current smokers if they reported either: smoking occasionally or smoking regularly (daily). 
		gen current_smoker =.
		replace current_smoker=1 if QS39_smoking_status==1
		replace current_smoker=1 if QS39_smoking_status==2
		replace current_smoker=1 if QS39_smoking_status==3
		replace current_smoker=2 if QS39_smoking_status==4
		replace current_smoker=2 if QS39_smoking_status==5
		label define current_smoker_label 1 "Non-Smoker" 2 "Smoker"
		label values current_smoker current_smoker_label 
/*-----------------------------------
	Alcohol Consumption
-----------------------------------*/
* Number of days participants drank alcohol over the past week. 
* 0 days = 1, 1-2 days = 2, 3-4 days = 3, 5-6 days = 4, every day = 5. 
		tab QS47a_alcohol_days
		* tab QS48_drinking	
		*------------------------------------
		* ALCOHOL CONSUMPTION LEVEL
		gen alcohol_level =. 
		replace alcohol_level=1 if QS47a_alcohol_days==1
		replace alcohol_level=2 if QS47a_alcohol_days==2
		replace alcohol_level=2 if QS47a_alcohol_days==3
		replace alcohol_level=3 if QS47a_alcohol_days==4
		replace alcohol_level=3 if QS47a_alcohol_days==5
		replace alcohol_level=. if QS47a_alcohol_days==.
		* Label
		label define alcohol_level 1 "Non-Drinker" 2 "1-4 Days" 3 "5-7 Days"
		label values alcohol_level alcohol_level_label 
		tab alcohol_level

/*-----------------------------------
	Sleep
----------------------------------------------------------------------------------------*/
* Generate total sleep time tab QS42_sleep_hours, tab QS42_sleep_minutes
		gen total_sleep_time =QS42_sleep_hours+(QS42_sleep_minutes/60)
		replace total_sleep_time=QS42_sleep_hours if QS42_sleep_minutes==.
		tab total_sleep_time
		* Pre-COVID sleep comparison: QS43_sleep_comparison less = 1, the same = 2, more = 3
		* tab QS43_sleep_comparison	
		* list QS42_sleep_hours QS42_sleep_minutes total_sleep_time // check - good
		*------------------------------------
		* SLEEP LEVEL
		gen sleep_level =. 
		replace sleep_level=1 if total_sleep_time<7
		replace sleep_level=2 if total_sleep_time>=7
		replace sleep_level=. if total_sleep_time==.
		* Label
		label define sleep_level 1 "Inadequate" 2 "Adequate" 
		label values sleep_level sleep_level_label 
		tab sleep_level
/*-----------------------------------------------------------------------------------------
	Social & Emotional Loneliness Questionnaire
----------------------------------------------------------------------------------------
ITEMS: 1. QS30_feel_emptiness, 2. QS30_people_to_rely_on, 3. QS30_people_can_trust, 4. QS30_miss_people, 5. QS30_people_close_to, 6. QS30_feel_rejected			*/
	* RECODE: Yes=1, More or less = 1, No = 0
		gen loneliness_1 =.
		replace loneliness_1=1 if QS30_feel_emptiness==1
		replace loneliness_1=1 if QS30_feel_emptiness==2
		replace loneliness_1=0 if QS30_feel_emptiness==3
		replace loneliness_1=. if QS30_feel_emptiness==.
		label define loneliness_1_label 1 "Yes / More or less" 0 "No"
		label values loneliness_1 loneliness_1_label 
	* RECODE: Yes=1, More or less = 1, No = 0
		gen loneliness_2 =.
		replace loneliness_2=0 if QS30_feel_emptiness==1
		replace loneliness_2=1 if QS30_feel_emptiness==2
		replace loneliness_2=1 if QS30_feel_emptiness==3
		replace loneliness_2=. if QS30_feel_emptiness==.
		label define loneliness_2_label 0 "Yes" 1 "No / More or less"
		label values loneliness_2 loneliness_2_label 
	* RECODE: Yes=1, More or less = 1, No = 0
		gen loneliness_3 =.
		replace loneliness_3=0 if QS30_people_can_trust==1
		replace loneliness_3=1 if QS30_people_can_trust==2
		replace loneliness_3=1 if QS30_people_can_trust==3
		replace loneliness_3=. if QS30_people_can_trust==.
		label define loneliness_3_label 0 "Yes" 1 "No / More or less"
		label values loneliness_3 loneliness_3_label 
	* RECODE: Yes=1, More or less = 1, No = 0
		gen loneliness_4 =.
		replace loneliness_4=1 if QS30_miss_people==1
		replace loneliness_4=1 if QS30_miss_people==2
		replace loneliness_4=0 if QS30_miss_people==3
		replace loneliness_4=. if QS30_miss_people==.
		label define loneliness_4_label 0 "No" 1 "Yes / More or less"
		label values loneliness_4 loneliness_6_label 
	* RECODE: Yes=1, More or less = 1, No = 0
		gen loneliness_5 =.
		replace loneliness_5=0 if QS30_people_close_to==1
		replace loneliness_5=1 if QS30_people_close_to==2
		replace loneliness_5=1 if QS30_people_close_to==3
		replace loneliness_5=. if QS30_people_close_to==.
		label define loneliness_5_label 0 "Yes" 1 "No / More or less"
		label values loneliness_5 loneliness_5_label 
	* RECODE: Yes=1, More or less = 1, No = 0
		gen loneliness_6 =.
		replace loneliness_6=1 if QS30_feel_rejected==1
		replace loneliness_6=1 if QS30_feel_rejected==2
		replace loneliness_6=0 if QS30_feel_rejected==3
		replace loneliness_6=. if QS30_feel_rejected==.
		label define loneliness_6_label 0 "No" 1 "Yes / More or less"
		label values loneliness_6 loneliness_6_label 
	* OVERALL LONELINESS SCORE: Sum of all recoded items
		gen loneliness_total =.
		replace loneliness_total= loneliness_1 + loneliness_2 + loneliness_3 + loneliness_4 + loneliness_5 + loneliness_6
	* tab loneliness_total
			
/*---------------------------------------------------------------------------------------
// Testing Linearity Assumption
Continuous exposures and binary mod-sev depression outcome
---------------------------------------------------------------------------------------*/
// Age
logistic  depression_mod c.age		
estimates store model1
logistic  depression_mod c.age##c.age		
estimates store model2
lrtest model1 model2

// BMI
logistic  depression_mod c.BMI		
estimates store model1
logistic  depression_mod c.BMI##c.BMI		
estimates store model2
lrtest model1 model2

// Sleep Duration
logistic  depression_mod c.total_sleep_time		
estimates store model1
logistic  depression_mod c.total_sleep_time##c.total_sleep_time		
estimates store model2
lrtest model1 model2

// Loneliness Symptoms
logistic  depression_mod c.loneliness_total
estimates store model1
logistic  depression_mod c.loneliness_total##c.loneliness_total		
estimates store model2
lrtest model1 model2
*=========================================================================================
*	MISSING DATA TREATMENT
*==========================================================================================*
*-----------------------------------------------------------------------------------------
* Check Missing Values
*----------------------------------------------------------------------------------------*/
	misschk age						// 
	misschk BMI						// 
	misschk current_smoker			// 
	misschk alcohol_level			// 
	misschk total_sleep_time		// 
	misschk loneliness_total		// 
	misschk lockdown_bin			// 
*-----------------------------------------------------------------------------------------
* Missingness
*----------------------------------------------------------------------------------------*/
	mcartest BMI current_smoker QS47a_alcohol_days total_sleep_time loneliness_total lockdown_bin		 // Null hypothesis is that data are MCAR
/* insufficient evidence against null hypothesis that data are MCAR. 

*=========================================================================================
* Missing data treatment plan: 4.72% of total dataset missing, and data MCAR. Therefore, complete case analysis. 
*=========================================================================================
*=========================================================================================*/
* Exclude if any response to key variable measures missing
* egen nmis_completecase=rmiss2(BMI current_smoker alcohol_level total_sleep_time social_support_level loneliness_total)

* tab nmis_completecase		// 1035 with complete data

/* Keep if no PA response missing
keep if nmis_completecase == 0
	
* Keep only if co-twin still included
				* tab twin_ID_n
					sort pair_ID_n twin_ID_n
					by pair_ID_n: generate n2_completecase = _N	// generate n2 indicating the number of twins remaining for each pair
					list pair_ID_n twin_ID_n n2_completecase		// investigate missing pairs
					keep if n2==2					// delete incomplete twin pairs
					
tab twin_ID_n		// Check even count of twin 1 and twin 2 --> yes, 601 pairs
tab pair_ID_n		// 1202 participants remain


/*=========================================================================================
	DESCRIPTIVE STATISTICS
==========================================================================================*/
/*---------------------------------------------------------------------------------------
	SAMPLE DESCRIPTIVES: No Age Limit Imposed
*----------------------------------------------------------------------------------------*/
	tab2 twin_ID_n sex_sex			// 462 FF pairs, 111 MM pairs
	tab2 twin_ID_n db_zyg			// 349 MZ pairs, 75 DZ pairs
	sum age							//  18- 89, Mean = 52.36, SD = 15.65	
	tab db_zyg_source
	
	
	tab state_clean
	tab date_started
/*-----------------------------------------------------------------------------------------
	TABLE 3
----------------------------------------------------------------------------------------*/
*--------------------------------------------------------------------------------
* DEMOGRAPHICS
*--------------------------------------------------------------------------------
	* Gender composition
		tab db_gender
		tab pair_ID_n
		tab twin_ID_n
		tab2 twin_ID_n db_zyg, row
	* Age
		sum age
		histogram age, discrete 
		twoway histogram age, discrete by(db_gender)		// ~ Normally distributed
		tabstat age, by(db_gender) stat(n mean sd)
		ttest age, by (db_gender)
	* Zygosity
		tab db_zyg
		tab2 db_zyg db_gender, row
		prtesti 924 0.8030 222 0.8468
	* Weight
		tab weight_status
		tab2 weight_status db_gender, cell
			prtesti 416 0.4749 86 0.3981
			prtesti 371 0.4015 111 0.5000
*--------------------------------------------------------------------------------
* PHYSICAL ACTIVITY
*--------------------------------------------------------------------------------
* CHECK: current exercise
	* Mod Exercise
		histogram QS41_walk_moderate, discrete 							// Positively Skewed
		twoway histogram modexercise_mins, discrete by(db_gender)		// Positively Skewed
		tabstat QS41_walk_moderate, by(db_gender) stat(n median iqr p25 p75)
		ttest QS41_walk_moderate, by (db_gender)

	* Vig Exercise
		histogram QS41_walk_vigorously, discrete 							// Positively Skewed
		twoway histogram vigexercise_mins, discrete by(db_gender)		// Positively Skewed
		tabstat QS41_walk_vigorously, by(db_gender) stat(n median iqr p25 p75)
		ttest QS41_walk_vigorously, by (db_gender)

	* PA Status
		tab PA_status
		tab2 PA_status db_gender, col
		graph box PA_status, over(db_gender) box(1, fcolor(ltblue)) b1title("Sex", size(medium))
	
		prtesti 924 0.3139 222 0.2613
		prtesti 924 0.3788 222 0.4910
		prtesti 924 0.3074 222 0.2477

	* PA Change
		tab PA_change
		tab2 PA_change db_gender, col
	
		prtesti 924 0.3539 222 0.3018
		prtesti 924 0.4015 222 0.5000
		prtesti 924 0.2446 222 0.1982

	* Lockdown
		tab2 lockdown_bin db_gender, col
		prtesti 920 0.6283 222 0.6757
		prtesti 920 0.3717 222 0.3243
*--------------------------------------------------------------------------------	
* MENTAL HEALTH
*--------------------------------------------------------------------------------		
		histogram DASS_depress, frequency 							// Positively Skewed
		tabstat DASS_depress, stat(n median iqr p25 p75)		
		tab depression_cat
		* Depression x Sex
		twoway histogram DASS_depress, discrete by(db_gender)		// Positively Skewed
		tabstat DASS_depress, by(db_gender) stat(n median iqr p25 p75)
		ttest DASS_depress, by (db_gender)

		tab2 depression_mod db_gender, col
		tab2 depression_cat db_gender, col
		graph box depression_cat, over(db_gender) box(1, fcolor(ltblue)) b1title("Sex", size(medium))
		
		prtesti 924 0.8539 222 0.9009
		prtesti 924 0.1461 222 0.0991
	
*--------------------------------------------------------------------------------*/
*** CONFOUNDERS: PSYCHOSOCIAL SUPPORT
*--------------------------------------------------------------------------------
	tab lockdown_bin
	* Live Alone - Binary
	* Social Support
		tab total_social_support
		tab2 total_social_support db_gender, cell
		graph box total_social_support, over(db_gender) box(1, fcolor(ltblue)) b1title("Sex", size(medium))
		ttest total_social_support, by (db_gender)
	* Loneliness
		histogram loneliness_total, frequency 							// Positively Skewed
		tab loneliness_total
		tabstat loneliness_total, by(db_gender) stat(n median iqr p25 p75)
		histogram loneliness_total, freq 
		ttest loneliness_total, by (db_gender)
*--------------------------------------------------------------------------------
*** CONFOUNDERS: PHYSICAL HEALTH 
*--------------------------------------------------------------------------------
	* BMI - Numerical Continuous
		histogram BMI, frequency 							// Positively Skewed
		twoway histogram bmi, frequency by(db_gender)		// Positively Skewed
		tabstat BMI, by(db_gender) stat(n median iqr p25 p75)
		ttest BMI, by (db_gender)	
	* Weight Category - Categorical
		tab weight_status
		tab2 weight_status db_gender, col
		graph box weight_status, over(db_gender) box(1, fcolor(ltblue)) b1title("Sex", size(medium)
		gen Underweight=(weight_status==1)
		prtest Underweight, by (db_gender) 	
		prtesti 876 0.0228 216 0.0139
		prtesti 876 0.4749 216 0.3981
		prtesti 876 0.2991 216 0.3935
		prtesti 876 0.2032 216 0.1944

	* Sleep - Numerical, Interval
		histogram total_sleep_time, discrete 							// ~N
		twoway histogram total_sleep_time, discrete by(db_gender)		// ~N
		tabstat total_sleep_time, by(db_gender) stat(n mean sd)
		ttest total_sleep_time, by (db_gender)
		tab sleep_level
		tab2 sleep_level db_gender, col

		prtesti 921 0.2877 222 0.2658
		prtesti 921 0.7123 222 0.7342
		
	*Current Smoker - Binary
		tab current_smoker
		tab2 current_smoker db_gender, row
		graph box current_smoker, over(db_gender) box(1, fcolor(ltblue)) b1title("Sex", size(medium))
		prtesti 924 0.0519 222 0.0541

	* Alcohol
		histogram , discrete 							// ~N
		twoway histogram QS47a_alcohol_days, discrete by(db_gender)		// ~N
		tabstat alcohol_level, by(db_gender) stat(n mean sd)
		ttest QS47a_alcohol_days, by (db_gender)
		tab QS47a_alcohol_days
		tab2 alcohol_level db_gender, col
		prtesti 917 0.3817 220 0.2182
		prtesti 917 0.4460 220 0.5455
		prtesti 917 0.1723 220 0.2364	
*================================================================================				
* ASSOCIATIONS BETWEEN PA and MENTAL HEALTH
*--------------------------------------------------------------------------------
	graph box modexercise_mins, over(depression_cat) box(1, fcolor(ltblue)) b1title("Depression", size(medium))
	graph box modexercise_mins, over(depression_mod) box(1, fcolor(ltblue)) b1title("Depression", size(medium))

	graph box vigexercise_mins, over(depression_cat) box(1, fcolor(ltblue)) b1title("Depression", size(medium))
	graph box vigexercise_mins, over(depression_mod) box(1, fcolor(ltblue)) b1title("Depression", size(medium))
	
	graph box modexercise_mins, over(anxiety_cat) box(1, fcolor(ltblue)) b1title("Anxiety", size(medium))
	graph box modexercise_mins, over(anxiety_mod) box(1, fcolor(ltblue)) b1title("Anxiety", size(medium))

	graph box vigexercise_mins, over(anxiety_cat) box(1, fcolor(ltblue)) b1title("Anxiety", size(medium))
	graph box vigexercise_mins, over(anxiety_mod) box(1, fcolor(ltblue)) b1title("Anxiety", size(medium))
	
	graph box DASS_depress, over(PA_status) box(1, fcolor(ltblue)) b1title("PA_Status", size(medium))
	graph box DASS_anxiety, over(PA_status) box(1, fcolor(ltblue)) b1title("PA_Status", size(medium))
*--------------------------------------------------------------------------------
*	CORRELATIONS --> APPENDICES
*----------------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------
*	Pairwise correlations: Not considering the paired structure of the twin data: 
*----------------------------------------------------------------------------------------
pwcorr age db_gender db_zyg BMI sleep_level alcohol_level current_smoker loneliness_total lockdown_bin PA_status PA_change depression_mod, sig

pwcorr PA_status PA_change depression_mod if db_gender==2, sig
pwcorr PA_status PA_change depression_mod if db_gender==1, sig
*----------------------------------------------------------------------------------------
*	Intraclass correlations: Considering the paired structure of the twin data: 
*----------------------------------------------------------------------------------------
* Demographic - Checks
	icc age pair_ID twin_ID, mixed level(95)		// ICC = 1, good
	icc db_gender pair_ID twin_ID, mixed level(95)	// ICC = 1, good
	icc db_zyg pair_ID twin_ID, mixed level(95)		// ICC = 1, good

* Physical Health
	icc BMI pair_ID twin_ID, mixed level(95)	
		icc BMI pair_ID twin_ID if db_gender==2, mixed level(95)	// Female Only		
		icc BMI pair_ID twin_ID if db_gender==1, mixed level(95)	// Male Only		

	icc current_smoker pair_ID twin_ID, mixed level(95)	
		icc current_smoker pair_ID twin_ID if db_gender==2, mixed level(95)	// Female Only		
		icc current_smoker pair_ID twin_ID if db_gender==1, mixed level(95)	// Male Only	
	
	icc QS47a_alcohol_days pair_ID twin_ID, mixed level(95)		
		icc QS47a_alcohol_days pair_ID twin_ID if db_gender==2, mixed level(95)	// Female Only		
		icc QS47a_alcohol_days pair_ID twin_ID if db_gender==1, mixed level(95)	// Male Only	
	
	icc total_sleep_time pair_ID twin_ID, mixed level(95)		
		icc total_sleep_time pair_ID twin_ID if db_gender==2, mixed level(95)	// Female Only		
		icc total_sleep_time pair_ID twin_ID if db_gender==1, mixed level(95)	// Male Only	
	
	icc loneliness_total pair_ID twin_ID, mixed level(95)		
		icc loneliness_total pair_ID twin_ID if db_gender==2, mixed level(95)	// Female Only		
		icc loneliness_total pair_ID twin_ID if db_gender==1, mixed level(95)	// Male Only	
		
	icc lockdown_bin pair_ID twin_ID, mixed level(95)	
		icc lockdown_bin pair_ID twin_ID if db_gender==2, mixed level(95)	// Female Only		
		icc lockdown_bin pair_ID twin_ID if db_gender==1, mixed level(95)	// Male Only	

* Physical Activity
	icc modexercise_mins pair_ID twin_ID, mixed level(95)
		icc modexercise_mins pair_ID twin_ID if db_gender==2, mixed level(95)	// Female Only		
		icc modexercise_mins pair_ID twin_ID if db_gender==1, mixed level(95)	// Male Only	
	
	icc vigexercise_mins pair_ID twin_ID, mixed level(95)
		icc vigexercise_mins pair_ID twin_ID if db_gender==2, mixed level(95)	// Female Only		
		icc vigexercise_mins pair_ID twin_ID if db_gender==1, mixed level(95)	// Male Only	
	
	icc PA_status pair_ID twin_ID, mixed level(95)
		icc PA_status pair_ID twin_ID if db_gender==2, mixed level(95)	// Female Only		
		icc PA_status pair_ID twin_ID if db_gender==1, mixed level(95)	// Male Only	
	
* Depression
	icc DASS_depress pair_ID twin_ID, mixed level(95)
		icc DASS_depress pair_ID twin_ID if db_gender==2, mixed level(95)	// Female Only		
		icc DASS_depress pair_ID twin_ID if db_gender==1, mixed level(95)	// Male Only	

*=========================================================================================		
* Assess Multicollinearity	
logistic depression_mod i.PA_status age db_gender BMI i.sleep_level i.alcohol_level i.current_smoker loneliness_total i.lockdown_bin
vif 

logistic depression_mod i.PA_status_rev age db_gender BMI i.sleep_level i.alcohol_level i.current_smoker loneliness_total i.lockdown_bin
vif
	
* A value of 1 indicates there is no correlation between a given explanatory variable and any other explanatory variables in the model.
* A value between 1 and 5 indicates moderate correlation between a given explanatory variable and other explanatory variables in the model, but this is often not severe enough to require attention.
* A value greater than 5 indicates potentially severe correlation between a given explanatory variable and other explanatory variables in the model. In this case, the coefficient estimates and p-values in the regression output are likely unreliable.
/*=========================================================================================	
		REGRESSION MODELLING APPROACH 1: IGNORING PAIRED STRUCTURE OF DATA
*========================================================================================*	
*=========================================================================================	
*-------------------------------------------------------------------------------------
 	MODEL 1: MULTIVARIABLE LINEAR REGRESSION
------------------------------------------------------------------------------------*
*--------------------------------------*/
*		EXPOSURE: PA_Status, OUTCOME: MOD-SEV DEPRESSION
*--------------------------------------*	

logistic depression_mod i.PA_status age db_gender BMI i.sleep_level i.alcohol_level i.current_smoker loneliness_total i.lockdown_bin

logistic depression_mod i.PA_status 
logistic depression_mod age 
logistic depression_mod db_gender 
logistic depression_mod BMI
logistic depression_mod i.sleep_level
logistic depression_mod i.alcohol_level
logistic depression_mod i.current_smoker 
logistic depression_mod loneliness_total
logistic depression_mod i.lockdown_bin

logistic depression_mod i.PA_status_rev age db_gender BMI i.sleep_level i.alcohol_level i.current_smoker loneliness_total i.lockdown_bin

logistic depression_mod i.PA_status 
logistic depression_mod age 
logistic depression_mod db_gender 
logistic depression_mod BMI
logistic depression_mod i.sleep_level
logistic depression_mod i.alcohol_level
logistic depression_mod i.current_smoker 
logistic depression_mod loneliness_total
logistic depression_mod i.lockdown_bin
* logistic depression_mod i.PA_status i.lockdown_bin age db_gender BMI i.current_smoker i.sleep_level i.QS47a_alcohol_days loneliness_total

*--------------------------------------*/
*		EXPOSURE	PA_Change, OUTCOME: MOD-SEV DEPRESSION
*--------------------------------------*	
* PA Change such that 0 "Worsened" 1 "Stayed the same" 2 "Improved"
logistic depression_mod i.PA_change age db_gender BMI i.sleep_level i.alcohol_level i.current_smoker loneliness_total i.lockdown_bin
	* Univariates
	logistic depression_mod i.PA_change 
	logistic depression_mod age 
	logistic depression_mod db_gender 
	logistic depression_mod BMI
	logistic depression_mod i.sleep_level
	logistic depression_mod i.alcohol_level
	logistic depression_mod i.current_smoker 
	logistic depression_mod loneliness_total
	logistic depression_mod i.lockdown_bin

* Reverse levels on PA Change such that 0 "Improved" 1 "Stayed the same" 2 "Worsened"
logistic depression_mod i.PA_change_rev age db_gender BMI i.sleep_level i.alcohol_level i.current_smoker loneliness_total i.lockdown_bin
	* Univariates
	logistic depression_mod i.PA_change_rev 
	logistic depression_mod age 
	logistic depression_mod db_gender 
	logistic depression_mod BMI
	logistic depression_mod i.sleep_level
	logistic depression_mod i.alcohol_level
	logistic depression_mod i.current_smoker 
	logistic depression_mod loneliness_total
	logistic depression_mod i.lockdown_bin
*=========================================================================================
 	MODEL 2: EFFECT MODIFICATION: PA_Status
*--------------------------------------*/
*		Model Estimation
*--------------------------------------*	
logistic depression_mod i.PA_status##i.lockdown_bin age db_gender BMI i.sleep_level i.alcohol_level i.current_smoker loneliness_total
*--------------------------------------*/
*		Likelihood Ratio Test
*--------------------------------------*	
* Model 1: No Effect Modification
logistic depression_mod i.PA_status i.lockdown_bin age db_gender BMI i.sleep_level i.alcohol_level i.current_smoker loneliness_total
estimates store model1
* Model 2: Effect Modification		
logistic depression_mod i.PA_status##i.lockdown_bin age db_gender BMI i.sleep_level i.alcohol_level i.current_smoker loneliness_total
estimates store model2
// Do LRT
lrtest model1 model2
* The null hypothesis of the likelihood ratio test was that the association between PA and depression was not modified by lockdown status
//// 	NO EFFECT MODIFICATION
*--------------------------------------*/
*		Test Parameter
*--------------------------------------*	
logistic depression_mod i.PA_status##i.lockdown_bin age db_gender BMI i.sleep_level i.alcohol_level i.current_smoker loneliness_total

testparm i.PA_status#i.lockdown_bin

/*--------------------------------------*
*STRATA ESTIMATES:
*--------------------------------------*
logistic depression_mod i.PA_change##i.lockdown_bin age db_gender BMI i.current_smoker i.sleep_level i.alcohol_level loneliness_total

* Baseline Odds
lincom _cons 	// Worsened, not in lockdown
lincom _cons + 1.lockdown_bin	// worse in lockdown

lincom _cons + 1.PA_change	//  same, OR = .0050806
lincom _cons + 1.lockdown_bin + 1.PA_change	+ 1.lockdown_bin#1.PA_change // Stayed the same, OR = .001874

lincom _cons + 2.PA_change	// Improved, OR = .0021924
lincom _cons + 1.lockdown_bin + 2.PA_change + 1.lockdown_bin#2.PA_change	// Improved, OR = .0040445

* PA Improved
	
clear
   input PA lockdown odds
   0 0 	.0055785	// worse 
   0 1 .0055622		// worse + lockdown
   1 0  0.0050806	//  same
	1 1  .001874	// same + lockdown
	2 0  .0021924	//  improved
	2 1 .0040445	// improved + lockdown
	
end
gen logodds=log(odds)

twoway (scatter logodds PA if lockdown==1,c(L) lpattern(solid) msymbol(O)) (scatter logodds PA if lockdown==0, c(L) lpattern(dash) msymbol(T)), xtitle("Self-reported change in PA level since pandemic onset") ytitle("log(Odds of moderate to severe depression symptoms)") xlabel(0(2)1 0 "Worsened" 1 "Stayed the same" 2 "Improved")legend(order(1 "In lockdown" 2 "Not in lockdown") position(3) rows(2) cols(1))

twoway (scatter odds PA if lockdown==1,c(L) lpattern(solid) msymbol(O)) (scatter odds PA if lockdown==0, c(L) lpattern(dash) msymbol(T)), xtitle("Self-reported change in PA level since pandemic onset") ytitle("Odds of moderate to severe depression symptoms") xlabel(0(2)1 0 "Worsened" 1 "Stayed the same" 2 "Improved")legend(order(1 "In lockdown" 2 "Not in lockdown") position(3) rows(2) cols(1))
*--------------------------------------*

	
*=========================================================================================	
		** WITHIN-PAIR REGRESSION MODELLING
*		CO-TWIN CONTROL REGRESSION MODELLING: CARLIN (2005) Co-Twin Control Code 
*=========================================================================================* 
* STAGE 1: Mean Values
*-----------------------------------------------------------------------------------------*/
sort pair_ID_n twin_ID_n

* PHYSICAL ACTIVITY
	* Mean mod_ex for each twin-pair
		by pair_ID_n: egen modexercise_mins_mn = sum(modexercise_mins) 
		replace modexercise_mins_mn=modexercise_mins_mn/2
		tab modexercise_mins_mn		// No missing values
	* Mean vig_ex for each twin-pair
		by pair_ID_n: egen vigexercise_mins_mn = sum(vigexercise_mins) 
		replace vigexercise_mins_mn=vigexercise_mins_mn/2
		tab vigexercise_mins_mn		// No missing values

	* Mean vig_ex for each twin-pair
		by pair_ID_n: egen PA_status_mn = sum(PA_status) 
		replace PA_status_mn=PA_status_mn/2
		tab PA_status_mn		// No missing values
		
	* Mean vig_ex for each twin-pair
		by pair_ID_n: egen PA_change_mn = sum(PA_change) 
		replace PA_change_mn=PA_change_mn/2
		tab PA_change_mn		// No missing values
	
	gen mvpa_mins = modexercise_mins + vigexercise_mins
	tab mvpa_mins
	
		* Mean vig_ex for each twin-pair
		by pair_ID_n: egen mvpa_mins_mn = sum(mvpa_mins) 
		replace mvpa_mins_mn=mvpa_mins_mn/2
		tab mvpa_mins_mn		// No missing values		
* CONFOUNDERS: Physical Health/ Lifestyle Behaviours
	* Mean BMI for each twin-pair
		by pair_ID_n: egen BMI_mn = sum(BMI) 
		by pair_ID_n: egen BMI_count = count(BMI)
		replace BMI_mn=BMI_mn/2
		replace BMI_mn=. if BMI_count==1
		replace BMI_mn=. if BMI_count==0
	* Mean alcohol_days for each twin-pair
		by pair_ID_n: egen alcohol_days_mn = sum(QS47a_alcohol_days) 
		by pair_ID_n: egen alcohol_days_count = count(QS47a_alcohol_days)
		replace alcohol_days_mn=alcohol_days_mn/2
		replace alcohol_days_mn=. if alcohol_days_count==1
		replace alcohol_days_mn=. if alcohol_days_count==0
	* Mean alcohol_level for each twin-pair
		by pair_ID_n: egen alcohol_level_mn = sum(alcohol_level) 
		by pair_ID_n: egen alcohol_level_count = count(alcohol_level)
		replace alcohol_level_mn=alcohol_level_mn/2
		replace alcohol_level_mn=. if alcohol_level_count==1
		replace alcohol_level_mn=. if alcohol_level_count==0
	* Mean current_smoker for each twin-pair
		by pair_ID_n: egen current_smoker_mn = sum(current_smoker) 
		by pair_ID_n: egen current_smoker_count = count(current_smoker)
		replace current_smoker_mn=current_smoker_mn/2
		replace current_smoker_mn=. if current_smoker_count==1
		replace current_smoker_mn=. if current_smoker_count==0
	* Mean total_sleep_time for each twin-pair
		by pair_ID_n: egen total_sleep_time_mn = sum(total_sleep_time) 
		by pair_ID_n: egen total_sleep_time_count = count(total_sleep_time)
		replace total_sleep_time_mn=total_sleep_time_mn/2
		replace total_sleep_time_mn=. if total_sleep_time_count==1
		replace total_sleep_time_mn=. if total_sleep_time_count==0
* CONFOUNDERS: Psychosocial Variables
	* Mean loneliness_total for each twin-pair
		by pair_ID_n: egen loneliness_total_mn = sum(loneliness_total) 
		by pair_ID_n: egen loneliness_total_count = count(loneliness_total)
		replace loneliness_total_mn=loneliness_total_mn/2
		replace loneliness_total_mn=. if loneliness_total_count==1
		replace loneliness_total_mn=. if loneliness_total_count==0
	* Mean total_social_support for each twin-pair
		by pair_ID_n: egen total_social_support_mn = sum(total_social_support) 
		by pair_ID_n: egen total_social_support_count = count(total_social_support)
		replace total_social_support_mn=total_social_support_mn/2
		replace total_social_support_mn=. if total_social_support_count==1
		replace total_social_support_mn=. if total_social_support_count==0
	* Mean lockdown_bin for each twin-pair
		by pair_ID_n: egen lockdown_bin_mn = sum(lockdown_bin) 
		by pair_ID_n: egen lockdown_bin_count = count(lockdown_bin)
		replace lockdown_bin_mn=lockdown_bin_mn/2
		replace lockdown_bin_mn=. if lockdown_bin_count==1
		* tab lockdown_bin_mn // 1114 individuals
		
*-----------------------------------------------------------------------------------------
* STAGE 2: Distance from mean
*-----------------------------------------------------------------------------------------
* PHYSICAL ACTIVITY
	* Mod_ex 
		generate modexercise_mins_d=modexercise_mins-modexercise_mins_mn
	* Vig_ex
		generate vigexercise_mins_d=vigexercise_mins-vigexercise_mins_mn
	* PA_status
		generate PA_status_d=PA_status-PA_status_mn
	* PA_change
		generate PA_change_d=PA_change-PA_change_mn
	* mvpa_mins
		generate mvpa_mins_d=mvpa_mins-mvpa_mins_mn
* CONFOUNDERS: Physical Health/ Lifestyle Behaviours
	*  BMI 
		generate BMI_d=BMI-BMI_mn
	*  alcohol_days 
		generate alcohol_days_d=QS47a_alcohol_days-alcohol_days_mn
	*  alcohol_level 
		generate alcohol_level_d=alcohol_level-alcohol_level_mn
	*  current_smoker
		generate current_smoker_d=current_smoker-current_smoker_mn
	*  total_sleep_time 
		generate total_sleep_time_d=total_sleep_time-total_sleep_time_mn
* CONFOUNDERS: Psychosocial Variables
	*  loneliness_total 
		generate loneliness_total_d=loneliness_total-loneliness_total_mn
	*  total_social_support 
		generate total_social_support_d=total_social_support-total_social_support_mn
* CONFOUNDERS: LOCKDOWN CATEGORY FOR EM
	*  lockdown_bin
		generate lockdown_bin_d=lockdown_bin-lockdown_bin_mn
*-----------------------------------------------------------------------------------------
* STAGE 3: Difference from mean
*-----------------------------------------------------------------------------------------
* Generate within-pair differences in exposure and outcome
	sort pair_ID_n twin_ID_n
* DEPRESSION: DASS_depress within-pair difference
	by pair_ID_n: generate DASS_depress_dif=DASS_depress[_n]-DASS_depress[_n-1] 
* DEPRESSION: DASS_depress within-pair difference
	by pair_ID_n: generate depression_mod_dif=depression_mod[_n]-depression_mod[_n-1] 
* Mod_ex within-pair difference
	by pair_ID_n: generate modexercise_mins_dif=modexercise_mins[_n]-modexercise_mins[_n-1] 
* Vig_ex within-pair difference
	by pair_ID_n: generate vigexercise_mins_dif=vigexercise_mins[_n]-vigexercise_mins[_n-1] 	

/*=========================================================================================
	CONFOUNDER ASSESSMENT
=========================================================================================
		Confounder should predict exposure and outcome=
		Potential Covariates: BMI_d alcohol_days_d current_smoker_d total_sleep_time_d 
		loneliness_total_d total_social_support_d live_alone_d 
		lockdown_days_d COMPASW_W_d COMPASW_C_d COMPASW_O_d COMPASW_M_d COMPASW_P_d COMPASW_A_d COMPASW_S_d
-------------------------------------------------------------------------------------
 	CONFOUNDER ASSESSMENT: 			FEMALE-ONLY PAIRS
-------------------------------------------------------------------------------------*/
* Outcome 1: DASS_depress_dif
	reg DASS_depress_dif BMI_d if db_gender==2, nocons						// 
	reg DASS_depress_dif alcohol_days_d if db_gender==2, nocons				// 
	reg DASS_depress_dif current_smoker_d if db_gender==2, nocons 			// 
	reg DASS_depress_dif total_sleep_time_d if db_gender==2, nocons			// 
	reg DASS_depress_dif loneliness_total_d if db_gender==2, nocons			// 
* Exposure 2: modexercise_mins_d
	reg modexercise_mins_d BMI_d if db_gender==2, nocons					// 
	reg modexercise_mins_d alcohol_days_d if db_gender==2, nocons			// 
	reg modexercise_mins_d current_smoker_d if db_gender==2, nocons 		// 
	reg modexercise_mins_d total_sleep_time_d if db_gender==2, nocons		// 
	reg modexercise_mins_d loneliness_total_d if db_gender==2, nocons		// 
* Exposure 3: vigexercise_mins_d
	reg vigexercise_mins_d BMI_d if db_gender==2, nocons					//
	reg vigexercise_mins_d alcohol_days_d if db_gender==2, nocons			// 
	reg vigexercise_mins_d current_smoker_d if db_gender==2, nocons 		// 
	reg vigexercise_mins_d total_sleep_time_d if db_gender==2, nocons		// 
	reg vigexercise_mins_d loneliness_total_d if db_gender==2, nocons		// 
*-------------------------------------------------------------------------------------
* 		CONFOUNDER ASSESSMENT		MALE-ONLY PAIRS	
*-------------------------------------------------------------------------------------
* Outcome 1: DASS_depress_dif
	reg DASS_depress_dif age if db_gender==1, nocons				//
	reg DASS_depress_dif BMI_d if db_gender==1, nocons				// 
	reg DASS_depress_dif alcohol_days_d if db_gender==1, nocons			// 
	reg DASS_depress_dif current_smoker_d if db_gender==1, nocons 			// 
	reg DASS_depress_dif total_sleep_time_d if db_gender==1, nocons			// 
	reg DASS_depress_dif loneliness_total_d if db_gender==1, nocons			// 
* Exposure 2: modexercise_mins_d
	reg modexercise_mins_d age if db_gender==1, nocons				// 
	reg modexercise_mins_d BMI_d if db_gender==1, nocons				// 
	reg modexercise_mins_d alcohol_days_d if db_gender==1, nocons			// 
	reg modexercise_mins_d current_smoker_d if db_gender==1, nocons 		// 
	reg modexercise_mins_d total_sleep_time_d if db_gender==1, nocons		// 
	reg modexercise_mins_d loneliness_total_d if db_gender==1, nocons		//
* Exposure 3: vigexercise_mins_d
	reg vigexercise_mins_d age if db_gender==1, nocons				//
	reg vigexercise_mins_d BMI_d if db_gender==1, nocons				// 
	reg vigexercise_mins_d alcohol_days_d if db_gender==1, nocons			// 
	reg vigexercise_mins_d current_smoker_d if db_gender==1, nocons 		// 
	reg vigexercise_mins_d total_sleep_time_d if db_gender==1, nocons		// 
	reg vigexercise_mins_d loneliness_total_d if db_gender==1, nocons		// 
*=========================================================================================

/*=========================================================================================
* WITHIN-PAIR DIFFERENCES REGRESSION MODELS
*=========================================================================================
*-------------------------------------------------------------------------------------*/
 * 	FEMALE ONLY PAIRS --- EXPOSURE: modexercise_mins_d
*-------------------------------------------------------------------------------------*/	
* All covars: loneliness only
reg DASS_depress_dif modexercise_mins_d BMI_d alcohol_days_d current_smoker_d total_sleep_time_d loneliness_total_d   if db_gender==2, nocons
* All covars: loneliness only
reg DASS_depress_dif modexercise_mins_d BMI_d alcohol_days_d current_smoker_d total_sleep_time_d loneliness_total_d lockdown_bin_d if db_gender==2, nocons
*=========================================================================================
*-------------------------------------------------------------------------------------*/
 * 	MALE ONLY PAIRS --- EXPOSURE: modexercise_mins_d
*-------------------------------------------------------------------------------------*/	
* All covars: loneliness only
reg DASS_depress_dif modexercise_mins_d BMI_d alcohol_days_d current_smoker_d total_sleep_time_d loneliness_total_d   if db_gender==1, nocons
* All covars: loneliness only
reg DASS_depress_dif modexercise_mins_d BMI_d alcohol_days_d current_smoker_d total_sleep_time_d loneliness_total_d lockdown_bin_d if db_gender==1, nocons
*=========================================================================================

*---------------------------------------------------------------------------------------
*	 SENSITVITY ANALYSES
*---------------------------------------------------------------------------------------
/*---------------------------------------------------------------------------------------
Sensitivity Analysis 1: Exclude over 65s
-----------------------------------------------------------------------------------------*/
* Exclude if over 65. 
	* tab age		
keep if age <66		
* FINAL SAMPLE DESCRIPTIVES if age limit imposed
	tab2 twin_ID_n sex_sex			// 356 FF pairs, 68 MM pairs
	tab2 twin_ID_n db_zyg			// 455 MZ pairs, 106 DZ pairs
	sum age							// 18- 65, Mean = 46.34, SD = 13.04
*-------------------------------------------------*/
* 	MODEL 1: MULTIVARIABLE LINEAR REGRESSION
	* a) PA_Status
*-------------------------------------------------*/
logistic depression_mod i.PA_status age db_gender BMI i.sleep_level i.alcohol_level i.current_smoker loneliness_total i.lockdown_bin

logistic depression_mod i.PA_status_rev age db_gender BMI i.sleep_level i.alcohol_level i.current_smoker loneliness_total i.lockdown_bin
*-------------------------------------------------*/
* 	MODEL 1: MULTIVARIABLE LINEAR REGRESSION
	* a) PA_Change
*-------------------------------------------------*/
logistic depression_mod i.PA_change age db_gender BMI i.sleep_level i.alcohol_level i.current_smoker loneliness_total i.lockdown_bin

logistic depression_mod i.PA_change_rev age db_gender BMI i.sleep_level i.alcohol_level i.current_smoker loneliness_total i.lockdown_bin

*-------------------------------------------------*/
* 	MODEL 2: EFFECT MODIFICATION
*-------------------------------------------------*/	
logistic depression_mod i.PA_status##i.lockdown_bin age db_gender BMI i.sleep_level i.alcohol_level i.current_smoker loneliness_total
*--------------------------------------*/
*		Likelihood Ratio Test
*--------------------------------------*	
* Model 1: No Effect Modification
logistic depression_mod i.PA_status i.lockdown_bin age db_gender BMI i.sleep_level i.alcohol_level i.current_smoker loneliness_total
estimates store model1
* Model 2: Effect Modification		
logistic depression_mod i.PA_status##i.lockdown_bin age db_gender BMI i.sleep_level i.alcohol_level i.current_smoker loneliness_total
estimates store model2
// Do LRT
lrtest model1 model2
* The null hypothesis of the likelihood ratio test was that the association between PA and depression was not modified by lockdown status
//// 	NO EFFECT MODIFICATION
*--------------------------------------*/
*		Test Parameter
*--------------------------------------*	
logistic depression_mod i.PA_status##i.lockdown_bin age db_gender BMI i.sleep_level i.alcohol_level i.current_smoker loneliness_total
testparm i.PA_status#i.lockdown_bin


*-------------------------------------------------*/
* 	MODEL 3: WITHIN-PAIR DIFFERENCES
*-------------------------------------------------*/	
* 	Variable prep
sort pair_ID_n twin_ID_n
* PHYSICAL ACTIVITY
	* Mean mod_ex for each twin-pair
		by pair_ID_n: egen modexercise_mins_mn = sum(modexercise_mins) 
		replace modexercise_mins_mn=modexercise_mins_mn/2
		tab modexercise_mins_mn		// No missing values
	* Mean vig_ex for each twin-pair
		by pair_ID_n: egen vigexercise_mins_mn = sum(vigexercise_mins) 
		replace vigexercise_mins_mn=vigexercise_mins_mn/2
		tab vigexercise_mins_mn		// No missing values

* CONFOUNDERS: Physical Health/ Lifestyle Behaviours
	* Mean BMI for each twin-pair
		by pair_ID_n: egen BMI_mn = sum(BMI) 
		by pair_ID_n: egen BMI_count = count(BMI)
		replace BMI_mn=BMI_mn/2
		replace BMI_mn=. if BMI_count==1
		replace BMI_mn=. if BMI_count==0
	* Mean alcohol_days for each twin-pair
		by pair_ID_n: egen alcohol_days_mn = sum(QS47a_alcohol_days) 
		by pair_ID_n: egen alcohol_days_count = count(QS47a_alcohol_days)
		replace alcohol_days_mn=alcohol_days_mn/2
		replace alcohol_days_mn=. if alcohol_days_count==1
		replace alcohol_days_mn=. if alcohol_days_count==0
	* Mean alcohol_level for each twin-pair
		by pair_ID_n: egen alcohol_level_mn = sum(alcohol_level) 
		by pair_ID_n: egen alcohol_level_count = count(alcohol_level)
		replace alcohol_level_mn=alcohol_level_mn/2
		replace alcohol_level_mn=. if alcohol_level_count==1
		replace alcohol_level_mn=. if alcohol_level_count==0
	* Mean current_smoker for each twin-pair
		by pair_ID_n: egen current_smoker_mn = sum(current_smoker) 
		by pair_ID_n: egen current_smoker_count = count(current_smoker)
		replace current_smoker_mn=current_smoker_mn/2
		replace current_smoker_mn=. if current_smoker_count==1
		replace current_smoker_mn=. if current_smoker_count==0
	* Mean total_sleep_time for each twin-pair
		by pair_ID_n: egen total_sleep_time_mn = sum(total_sleep_time) 
		by pair_ID_n: egen total_sleep_time_count = count(total_sleep_time)
		replace total_sleep_time_mn=total_sleep_time_mn/2
		replace total_sleep_time_mn=. if total_sleep_time_count==1
		replace total_sleep_time_mn=. if total_sleep_time_count==0
* CONFOUNDERS: Psychosocial Variables
	* Mean loneliness_total for each twin-pair
		by pair_ID_n: egen loneliness_total_mn = sum(loneliness_total) 
		by pair_ID_n: egen loneliness_total_count = count(loneliness_total)
		replace loneliness_total_mn=loneliness_total_mn/2
		replace loneliness_total_mn=. if loneliness_total_count==1
		replace loneliness_total_mn=. if loneliness_total_count==0
	* Mean lockdown_bin for each twin-pair
		by pair_ID_n: egen lockdown_bin_mn = sum(lockdown_bin) 
		by pair_ID_n: egen lockdown_bin_count = count(lockdown_bin)
		replace lockdown_bin_mn=lockdown_bin_mn/2
		replace lockdown_bin_mn=. if lockdown_bin_count==1
		* tab lockdown_bin_mn // 1114 individuals
		
* STAGE 2: Distance from mean
* PHYSICAL ACTIVITY
	* Mod_ex 
		generate modexercise_mins_d=modexercise_mins-modexercise_mins_mn
	* Vig_ex
		generate vigexercise_mins_d=vigexercise_mins-vigexercise_mins_mn
* CONFOUNDERS: Physical Health/ Lifestyle Behaviours
	*  BMI 
		generate BMI_d=BMI-BMI_mn
	*  alcohol_days 
		generate alcohol_days_d=QS47a_alcohol_days-alcohol_days_mn
	*  alcohol_level 
		generate alcohol_level_d=alcohol_level-alcohol_level_mn
	*  current_smoker
		generate current_smoker_d=current_smoker-current_smoker_mn
	*  total_sleep_time 
		generate total_sleep_time_d=total_sleep_time-total_sleep_time_mn
* CONFOUNDERS: Psychosocial Variables
	*  loneliness_total 
		generate loneliness_total_d=loneliness_total-loneliness_total_mn
* CONFOUNDERS: LOCKDOWN CATEGORY FOR EM
	*  lockdown_bin
		generate lockdown_bin_d=lockdown_bin-lockdown_bin_mn

* STAGE 3: Difference from mean
* Generate within-pair differences in exposure and outcome
	sort pair_ID_n twin_ID_n
* DEPRESSION: DASS_depress within-pair difference
	by pair_ID_n: generate DASS_depress_dif=DASS_depress[_n]-DASS_depress[_n-1] 
* Mod_ex within-pair difference
	by pair_ID_n: generate modexercise_mins_dif=modexercise_mins[_n]-modexercise_mins[_n-1] 
* Vig_ex within-pair difference
	by pair_ID_n: generate vigexercise_mins_dif=vigexercise_mins[_n]-vigexercise_mins[_n-1] 
	
*=========================================================================================
* WITHIN-PAIR DIFFERENCES REGRESSION MODELS
 * 	FEMALE ONLY PAIRS --- EXPOSURE: modexercise_mins_d	
reg DASS_depress_dif modexercise_mins_d BMI_d alcohol_days_d current_smoker_d total_sleep_time_d loneliness_total_d lockdown_bin_d if db_gender==2, nocons
 * 	MALE ONLY PAIRS --- EXPOSURE: modexercise_mins_d
reg DASS_depress_dif modexercise_mins_d BMI_d alcohol_days_d current_smoker_d total_sleep_time_d loneliness_total_d lockdown_bin_d if db_gender==1, nocons
*=========================================================================================

 
/*---------------------------------------------------------------------------------------
Sensitivity Analysis 2: Identical Pairs Only
-----------------------------------------------------------------------------------------*/
* Secondly, analyses were repeated with the subset of identical (MZ) twin pairs to completely control for genetic variability in within-pair difference scores. 

keep if db_zyg==1
tab pair_ID


* FINAL SAMPLE DESCRIPTIVES if age limit imposed
	tab2 twin_ID_n sex_sex			// 356 FF pairs, 68 MM pairs
	tab2 twin_ID_n db_zyg			// 455 MZ pairs, 106 DZ pairs
	sum age							// 18- 65, Mean = 46.34, SD = 13.04
	
*-------------------------------------------------*/
* 	MODEL 1: MULTIVARIABLE LINEAR REGRESSION
	* a) PA_Status
*-------------------------------------------------*/
logistic depression_mod i.PA_status age db_gender BMI i.sleep_level i.alcohol_level i.current_smoker loneliness_total i.lockdown_bin

logistic depression_mod i.PA_status_rev age db_gender BMI i.sleep_level i.alcohol_level i.current_smoker loneliness_total i.lockdown_bin
*-------------------------------------------------*/
* 	MODEL 1: MULTIVARIABLE LINEAR REGRESSION
	* a) PA_Change
*-------------------------------------------------*/
logistic depression_mod i.PA_change age db_gender BMI i.sleep_level i.alcohol_level i.current_smoker loneliness_total i.lockdown_bin

logistic depression_mod i.PA_change_rev age db_gender BMI i.sleep_level i.alcohol_level i.current_smoker loneliness_total i.lockdown_bin

*-------------------------------------------------*/
* 	MODEL 2: EFFECT MODIFICATION
*-------------------------------------------------*/	
logistic depression_mod i.PA_status##i.lockdown_bin age db_gender BMI i.sleep_level i.alcohol_level i.current_smoker loneliness_total
*--------------------------------------*/
*		Likelihood Ratio Test
*--------------------------------------*	
* Model 1: No Effect Modification
logistic depression_mod i.PA_status i.lockdown_bin age db_gender BMI i.sleep_level i.alcohol_level i.current_smoker loneliness_total
estimates store model1
* Model 2: Effect Modification		
logistic depression_mod i.PA_status##i.lockdown_bin age db_gender BMI i.sleep_level i.alcohol_level i.current_smoker loneliness_total
estimates store model2
// Do LRT
lrtest model1 model2
* The null hypothesis of the likelihood ratio test was that the association between PA and depression was not modified by lockdown status
//// 	NO EFFECT MODIFICATION
*--------------------------------------*/
*		Test Parameter
*--------------------------------------*	
logistic depression_mod i.PA_status##i.lockdown_bin age db_gender BMI i.sleep_level i.alcohol_level i.current_smoker loneliness_total
testparm i.PA_status#i.lockdown_bin


*-------------------------------------------------*/
* 	MODEL 3: WITHIN-PAIR DIFFERENCES
*-------------------------------------------------*/	
* 	Variable prep
sort pair_ID_n twin_ID_n
* PHYSICAL ACTIVITY
	* Mean mod_ex for each twin-pair
		by pair_ID_n: egen modexercise_mins_mn = sum(modexercise_mins) 
		replace modexercise_mins_mn=modexercise_mins_mn/2
		tab modexercise_mins_mn		// No missing values
	* Mean vig_ex for each twin-pair
		by pair_ID_n: egen vigexercise_mins_mn = sum(vigexercise_mins) 
		replace vigexercise_mins_mn=vigexercise_mins_mn/2
		tab vigexercise_mins_mn		// No missing values

* CONFOUNDERS: Physical Health/ Lifestyle Behaviours
	* Mean BMI for each twin-pair
		by pair_ID_n: egen BMI_mn = sum(BMI) 
		by pair_ID_n: egen BMI_count = count(BMI)
		replace BMI_mn=BMI_mn/2
		replace BMI_mn=. if BMI_count==1
		replace BMI_mn=. if BMI_count==0
	* Mean alcohol_days for each twin-pair
		by pair_ID_n: egen alcohol_days_mn = sum(QS47a_alcohol_days) 
		by pair_ID_n: egen alcohol_days_count = count(QS47a_alcohol_days)
		replace alcohol_days_mn=alcohol_days_mn/2
		replace alcohol_days_mn=. if alcohol_days_count==1
		replace alcohol_days_mn=. if alcohol_days_count==0
	* Mean alcohol_level for each twin-pair
		by pair_ID_n: egen alcohol_level_mn = sum(alcohol_level) 
		by pair_ID_n: egen alcohol_level_count = count(alcohol_level)
		replace alcohol_level_mn=alcohol_level_mn/2
		replace alcohol_level_mn=. if alcohol_level_count==1
		replace alcohol_level_mn=. if alcohol_level_count==0
	* Mean current_smoker for each twin-pair
		by pair_ID_n: egen current_smoker_mn = sum(current_smoker) 
		by pair_ID_n: egen current_smoker_count = count(current_smoker)
		replace current_smoker_mn=current_smoker_mn/2
		replace current_smoker_mn=. if current_smoker_count==1
		replace current_smoker_mn=. if current_smoker_count==0
	* Mean total_sleep_time for each twin-pair
		by pair_ID_n: egen total_sleep_time_mn = sum(total_sleep_time) 
		by pair_ID_n: egen total_sleep_time_count = count(total_sleep_time)
		replace total_sleep_time_mn=total_sleep_time_mn/2
		replace total_sleep_time_mn=. if total_sleep_time_count==1
		replace total_sleep_time_mn=. if total_sleep_time_count==0
* CONFOUNDERS: Psychosocial Variables
	* Mean loneliness_total for each twin-pair
		by pair_ID_n: egen loneliness_total_mn = sum(loneliness_total) 
		by pair_ID_n: egen loneliness_total_count = count(loneliness_total)
		replace loneliness_total_mn=loneliness_total_mn/2
		replace loneliness_total_mn=. if loneliness_total_count==1
		replace loneliness_total_mn=. if loneliness_total_count==0
	* Mean lockdown_bin for each twin-pair
		by pair_ID_n: egen lockdown_bin_mn = sum(lockdown_bin) 
		by pair_ID_n: egen lockdown_bin_count = count(lockdown_bin)
		replace lockdown_bin_mn=lockdown_bin_mn/2
		replace lockdown_bin_mn=. if lockdown_bin_count==1
		* tab lockdown_bin_mn // 1114 individuals
		
* STAGE 2: Distance from mean
* PHYSICAL ACTIVITY
	* Mod_ex 
		generate modexercise_mins_d=modexercise_mins-modexercise_mins_mn
	* Vig_ex
		generate vigexercise_mins_d=vigexercise_mins-vigexercise_mins_mn
* CONFOUNDERS: Physical Health/ Lifestyle Behaviours
	*  BMI 
		generate BMI_d=BMI-BMI_mn
	*  alcohol_days 
		generate alcohol_days_d=QS47a_alcohol_days-alcohol_days_mn
	*  alcohol_level 
		generate alcohol_level_d=alcohol_level-alcohol_level_mn
	*  current_smoker
		generate current_smoker_d=current_smoker-current_smoker_mn
	*  total_sleep_time 
		generate total_sleep_time_d=total_sleep_time-total_sleep_time_mn
* CONFOUNDERS: Psychosocial Variables
	*  loneliness_total 
		generate loneliness_total_d=loneliness_total-loneliness_total_mn
* CONFOUNDERS: LOCKDOWN CATEGORY FOR EM
	*  lockdown_bin
		generate lockdown_bin_d=lockdown_bin-lockdown_bin_mn

* STAGE 3: Difference from mean
* Generate within-pair differences in exposure and outcome
	sort pair_ID_n twin_ID_n
* DEPRESSION: DASS_depress within-pair difference
	by pair_ID_n: generate DASS_depress_dif=DASS_depress[_n]-DASS_depress[_n-1] 
* Mod_ex within-pair difference
	by pair_ID_n: generate modexercise_mins_dif=modexercise_mins[_n]-modexercise_mins[_n-1] 
* Vig_ex within-pair difference
	by pair_ID_n: generate vigexercise_mins_dif=vigexercise_mins[_n]-vigexercise_mins[_n-1] 
	
*=========================================================================================
* WITHIN-PAIR DIFFERENCES REGRESSION MODELS
 * 	FEMALE ONLY PAIRS --- EXPOSURE: modexercise_mins_d	
reg DASS_depress_dif modexercise_mins_d BMI_d alcohol_days_d current_smoker_d total_sleep_time_d loneliness_total_d lockdown_bin_d if db_gender==2, nocons
 * 	MALE ONLY PAIRS --- EXPOSURE: modexercise_mins_d
reg DASS_depress_dif modexercise_mins_d BMI_d alcohol_days_d current_smoker_d total_sleep_time_d loneliness_total_d lockdown_bin_d if db_gender==1, nocons
*=========================================================================================
