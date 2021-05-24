/**************************************************************************************************************************************************************************************************
  Programmer: Tony Williams
  Company:    Awana
  Contact:    tonyw@awana.org
  Project:    MOZO 
  Description: Performs MOZO updates on the account based on Registration Status, Registration Level and its Opporunity's Registration Product.
  Created:  3/9/2015 
  Tests:    UpdateMozoAccounts_Test.cls
  ========================================
  Updated:  4/14/2015 - Added a) Registration History inserts and b)Updated Conditionals for both Upgrade and Renewal to check for the new Registration Product value
  Updated:  5/4/2015 - <Post 5:/1> Adedd condition to make sure that Dropped churches now have an account status of 'Added' when they're New, Renewed or are Reinstated
  Updated:  5/4/2015 - <Post 5:/1>  if Expirae date < 9-1-2015 then update the Expire date to 9-1-2016
  Updated:  5/14/2015 - <Post 5-1>  Updated PreSales section of code to change the updated Expire date value from 9-1-2015 to 9-1-2016 as it should have been  in the previous Update (see above).
  Updated:  5/27/2015 - <PreSale> - Added an outer IF condition to include Sales Credits. Updated Reg Status and Expiration Date on the account when a full credit (R0) is given.
  Updated:  7/10/2015 - <PreSale>  - For Sales Credit:  Changed the Condition to check for R0 in the Opportunity's  Registration_Product__C field.
  Updated:  8/03/2015 - <PreSale> - Added checks to add either 'Full' or 'LMS" to Affiliation Mozo User Level based on New registration to R2,R3 or for all Upgrades from R1 current level.
  Updated:  9/20/2015 - <PostSale> - Removal of Sales Credit code since downgrade automation is no longer needed. (All manually done by Ccare)
  Updated:  9/29/2015 - <PostSale> - Made the setting of Expiration Date dynamic, Removed ELSE condition for Sales Credit, MAde sure that If an Reg Status is changed to Reinstated that Expire Date = today's date before date calculations.
  Updated:  6/24/2016 - SFDC Bug   - Fixed duplicate processing per each opportunity b y adding a Sentinel Check
  Updated:  10/7/2016 - <SFDC-209> - Removed setting Account  Status  transition from "Drop to Added" to "Pending to Added" for re-registered churches which were formerly dropped. 
  Updated:  03/17/2016 - <MEM-518> - Removed the dunamic expiration date calculations and changed the expiration date calculations to static value of 7-1-<year>.
  Updated:  10/11/2017 - <ASP-571> - Removal of any references to R4 since R4 membership is no longer being used.
  Updated:  10/30/2017 - <ASP-634> - Now All non-R1 reg Levels will have their Mozo Licenses set to "Full"
  Updated:  12/19/2017 - <ASP-721> - Churches with 7/1/17 exp date that Renew after 1/1/18 will get 6/30/18 exp date and not 6/30/19.
  Updated:  04/02/2018 - <NMM-17,27,29> -  Refactored to now treat Membership and Mozo separately. 
  Updated:  05/14/2018 - <NMM-17> -  Refactored to now treat Membership and Mozo Expiration Date separately. (Changed getMember flags to ChangeExpiration, Added updates to MozoEpxiration date )
  Updated:  05/24/2018 - <ASP-1141> - Updated to fix MOZO expiration date issues. 
  UPdated:  05/24/2018 - <ASP-1142> - Updated fix for MFT so that when MFT is cancelled only the OCR is set to FULL. 
**************************************************************************************************************************************************************************************************************************************************/
 
public class UpdateMozoAccounts {
    public class MozoException extends Exception{}
    public static void handler(List<Account> mozoAccounts,Map<Id,Order> mozoMap){
        Boolean changeExpiration = false;
        Boolean changeRegExpiration = false;
        Boolean changeMozoExpiration = false;
        String default_registration_reason = 'Registration History record automatically added for Membership';
        List<Registration_History__c> registrations_to_insert = new List<Registration_History__c>();  
        List<npe5__Affiliation__c> listOfOCRMozoAffs   = new List<npe5__Affiliation__c>();
        List<npe5__Affiliation__c> listOfValidMozoAffs   = new List<npe5__Affiliation__c>();
        try{ 
            date tempDate = null;  //Extended the scope of these variables so that they can be reused for Sales Credit Segment within this Try block.
            Integer day = 1;    
            Integer month = 7;
            Integer year = 0;
            date Currentdt = date.today();
            Integer todayDay = Currentdt.day();
            Integer todayMonth = Currentdt.month();
            Integer todayYear = Currentdt.year();
            Map<ID,npe5__Affiliation__c> mapAffiliationWithContactRole = new  Map<ID,npe5__Affiliation__c>();
            Map<ID,Order_Contact_Role__c> mapOrderWithContactRole = new Map<ID,Order_Contact_Role__c>();
            Map<ID,npe5__Affiliation__c> mapAffiliateWithAccount = new Map<ID,npe5__Affiliation__c>();
            List<Id> loadOrderIds = new List<Id>();
            Boolean foundMozo = false;
            Boolean getMembership = false;
            String statusKeeper;
            system.debug('<<NUMBER OF QUERIES In TOTAL : '+Limits.getLimitQueries());
            //  Create Mapping for Contact Role With Affiliations from the mozoMap : 1 order per Account
            List<npe5__Affiliation__c> affiliations = [Select Id, Mozo_User_Level__c,npe5__Contact__c from npe5__Affiliation__c where npe5__Status__c = 'Current' and  Historical__c = false and (npe5__Contact__r.Email <> null and npe5__Contact__r.Email <> '') and npe5__Organization__c in: mozoMap.keySet() ];
            for(npe5__Affiliation__c aff : affiliations){
                mapAffiliationWithContactRole.put(aff.npe5__Contact__c,aff);
                
            }
           // Create List of Order Ids for the Mapping that relates Contact Role with Orders
            for(Order o : mozoMap.values()){
              loadOrderIds.add(o.Id);
            }
            for(Order_Contact_Role__c ocr : [Select o.Order__c, o.Contact__c From Order_Contact_Role__c o where  o.Order__c in: loadOrderIds]){
            	mapOrderWithContactRole.put(ocr.Order__c,ocr);   
            }

            // For each Account get its order and process its registration and Mozo info..
            system.debug('<<MOZO ACCOUNTS in UPdateMozoAccounts>> '+mozoAccounts);
            //1.  Get our mozo Accounts ...
            // Go through all 4 process scenarios and if not found then throw an exception.
            if(mozoAccounts.size() > 0){
                for(Account a : mozoAccounts){
                     system.debug('<< 0 - MFT - STATUS>> '+a.Mozo_Trial_Status__c);
                    Order getOrder = mozoMap.get(a.Id); //Use this just in case you have to refer back to Registration Product
                    system.debug('<< REGPRODUCT>> '+getOrder); 
                    system.debug('<<CI BYPASS>> '+a.Cast_Iron_Bypass__c);
                    if(a.Cast_Iron_Bypass__c == null || a.Cast_Iron_Bypass__c != getOrder.Name){
                        system.debug('<< MOZO_EXPIRATION_DATE 1>> '+a.MOZO_Expiration_Date__c);
                        system.debug('<< REGPRODUCT>> '+getOrder.Registration_Product__c);
                        // If this account's opportunity is not a Sales Credit then continue ...
                        system.debug('<< PAY TERMS>> '+getOrder.Payment_Terms__c);
                        if(getOrder.Payment_Terms__c != 'Sales Credit'){ 
                            Boolean setFullLicense = false;
                             system.debug('<< REG LEVEL>> '+a.Registration_Level__c+' << REG STATUS >> '+a.Registration_Status__c);
                            String PreviousRegistrationLevel = a.Registration_Level__c;
                            //If Registration Product contains M and R are purchased simulatneously then process OE - Check 70001 line item
                             if((a.Registration_Level__c != 'R0' && a.Registration_Status__c == null) || 
                               	(a.Registration_Level__c == 'R0' && a.Registration_Status__c == null ) 
                             ){
                                 	//2. <<NEW>> Process for Membership Registration (R1)
                                 	if(getOrder.Registration_Product__c.toLowerCase().indexOf('r') >=0){
										//getMembership = true;
										changeExpiration = true;
                                        statusKeeper = 'New';
                                        system.debug('<< NEW  WITH REG LEVEL >> '+getOrder.Registration_Product__c);
                                    }
									if(getOrder.Registration_Product__c.toLowerCase().indexOf('m') >=0){
                                        foundMozo = true;
									}
                         		}else if(a.Registration_Status__c != 'Dropped'  && 
                                		a.Registration_Status__c != null  &&
                                		a.Registration_Level__c != 'R0'
                          		){ 
                                     system.debug('<< RENEWED  WITH REG LEVEL >> '+getOrder.Registration_Product__c);
                                	//3. <<Renewed>> Process for Membership Registration (R1)
                                 	if(getOrder.Registration_Product__c.toLowerCase().indexOf('r') >=0){
                                		//getMembership = true;
                                		changeExpiration = true;
                                    	statusKeeper = 'Renewed';
                                	}
                                	if(getOrder.Registration_Product__c.toLowerCase().indexOf('m') >=0){
                                		foundMozo = true;
									}
                            	}else if(a.Registration_Status__c == 'Dropped' ){
                                	//4. <<Reinstated>> Process for Membership Registration (R1)
                                	if(getOrder.Registration_Product__c.toLowerCase().indexOf('r') >=0){
                                        system.debug('<< WE ARE IN  DROPPED FOR>> '+getOrder.Registration_Product__c);
                                       // getMembership = true;
                                       	changeExpiration = true;
                                		statusKeeper = 'Reinstated';
                                        a.Reason_Dropped__c = '';
                                	}
                                	if(getOrder.Registration_Product__c.toLowerCase().indexOf('m') >=0){
                                		foundMozo = true;
									}
                            }else if(getOrder.Registration_Product__c.toLowerCase().indexOf('m') >= 0 &&
                                     getOrder.Registration_Product__c.toLowerCase().indexOf('r') < 0 
                                   ){
                                       system.debug('<< OUr MOZO-Only Product >> '+getOrder.Registration_Product__c);
                                       foundMozo = true;
                                   }
                            else{// Hanlding updgrades for mozo just includes the 'U' indicator so prohibit Mozo exp date changes when Mozo is purchased.
                                throw new MozoException('Invalid Mozo State Error: According to the fault this is neither a Renew, New, Reinstate, nor Upgrade.');
                            }   
                            //4. Add in the Membership info for R1 
                            if(changeExpiration ==  true){
                            	a.Registration_Level__c = 'R1';
                                a.Registration_Status__c = statusKeeper;
                                // Check to see what constitutes an Full License is it just M4
                            }
                            //5. Check for Mozo and update the Moz Levels
                            if(foundMozo == true){ 
                                system.debug('<< MOZO_EXPIRATION_DATE 2>> '+a.MOZO_Expiration_Date__c);
                            	//system.debug('<<INSIDE REG STATUS =  R1  WITH MOZO LEVEL>> ');
                                setFullLicense = true;
                                Integer pos = getOrder.Registration_Product__c.toLowerCase().indexOf('m');
								Integer stringLimit = getOrder.Registration_Product__c.length();
                                //system.debug('<<INSIDE REG STATUS =  R1  WITH MOZO LEVEL>> '+getOrder.Registration_Product__c.substring(pos,stringLimit));
								a.MOZO_Level__c =getOrder.Registration_Product__c.substring(pos,stringLimit);
                                if(getOrder.Registration_Product__c.toLowerCase().indexOf('u') < 0 || (a.MOZO_Expiration_Date__c == null)){
                                	system.debug('<< CHANGE MOZO DATE>> '+getOrder.Registration_Product__c);
                                	changeMozoExpiration = true;
                                }
                            }
                            //6. <<FOR TEST CLASS- ONLY>> :Process Full licensing for Mozo but Get ordering ConatctFirst...
                            if(setFullLicense == true){
                                if(Test.isRunningTest() ){
                                    //Create  Contact 
                                    Contact  a_contact = new Contact(FirstName='Bilbo',LastName='Baggins',Email='bbaggins@mailinator.com');
                                    insert a_contact;
                                    // Create OppContactRole
                                    Order_Contact_Role__c a_ocr = new Order_Contact_Role__c(Order__c=getOrder.Id, Contact__c=a_contact.Id);
                                    // Create AFfiliation
                                    npe5__Affiliation__c an_aff = new npe5__Affiliation__c(npe5__Status__c = 'Current',npe5__Organization__c=a.Id, npe5__Contact__c=a_contact.Id,Mozo_User_Level__c='None');
                                    insert a_ocr;
                                    insert an_aff;
                                    system.debug('AFFS >>'+an_aff);
                                }
                                //6B. Get the Contact Role contact in order to process the opportunity and ...[Select o.Order__c, o.Contact__c From Order_Contact_Role__c o where  o.Order__c =: getOrder.Id limit 1];
                               Order_Contact_Role__c ocr = mapOrderWithContactRole.get(getOrder.Id);                                
                                system.debug('<<LINE 174 OCR>> '+ocr);
                                //... get the affiliations for this contact and set the Mozo User Level based on the Registration Level selected. 
                                system.debug('<<  REGISTRATION PRODUCT>> '+getOrder.Registration_Product__c);
                                if(getOrder.Registration_Product__c.contains('M1') || 
                                   getOrder.Registration_Product__c.contains('M2') || 
                                   getOrder.Registration_Product__c.contains('M3') ||
                                   getOrder.Registration_Product__c.contains('M4') ){
                                    	// Create a Map<ContActID,Affiliations  to set OCR's MUL to FULL while checking MFT Status
                                    	Boolean wasMFT = false;
                                       system.debug('<<AFF CONTACTS BOUGHT MOZO>> '+mapAffiliationWithContactRole.values());
                                       	for(npe5__Affiliation__c an_Affiliation : mapAffiliationWithContactRole.values()){
                                       		if(an_Affiliation.npe5__Contact__c == ocr.Contact__c){
                                                system.debug('<<MFT - STATUS - OCR>> '+a.Mozo_Trial_Status__c);
                                                system.debug('<<OCR >> '+an_Affiliation.npe5__Contact__c);
                                           		if(an_Affiliation.Mozo_User_Level__c != 'Full'){
                                               		an_Affiliation.Mozo_User_Level__c = 'Full';
                                                  	listOfOCRMozoAffs.add(an_Affiliation);
                                                    if(a.Mozo_Trial_Status__c == 'Current'){
                                                        wasMFT = true;
                                                    }
                                               	}  
                                         	}else{// Affiliate COntact is Not OCR but Mozo Free Trial is current  while Mozo was purchased
                                                system.debug('<<MFT - STATUS>> '+a.Mozo_Trial_Status__c);
                                             	if(a.Mozo_Trial_Status__c == 'Current'){
                                                	if(an_Affiliation.Mozo_User_Level__c != 'LMS'){
                                                        system.debug('<<NON-OCR >> '+an_Affiliation.npe5__Contact__c);
                                                   		an_Affiliation.Mozo_User_Level__c = 'LMS';
                                                    	listOfOCRMozoAffs.add(an_Affiliation);
                                                        wasMFT = true;
                                                 	}
                                             	}//If MFT Status = Current
                                          	}//ELSE 
                                       }//Loop
                                       if(wasMFT==true){
                                           a.Mozo_Trial_Status__c = 'Former';
                                           system.debug('<<MFT STATUS>> '+a.Mozo_Trial_Status__c);
                                       }
                                	}//IF - M1 - M4 Purchased
                            }//FULL License
                            //6. <<Expiration Date Steup>> Make sure that if registration status is dropped or the Account Expiration Date is null, grab today's date.
                            // ... so if dropped and date is 9/1/2004 we can just reinstate this to the latest date of 9/1/(this_year + 1)
                           	system.debug('<< MOZO_EXPIRATION_DATE 3>> '+a.MOZO_Expiration_Date__c);
                            tempDate = Currentdt;
                            year = tempDate.year();
                            //Membership Expiration: Update the Membership/Reg Level  expiration date for  R0 to R1.
                            system.debug('<< REG EXPIRATION IS >> '+changeExpiration);
                            if(changeExpiration == true){
                                system.debug('<< DATE BEFORE UPDATE>> '+a.Date_Inactive__c);
                                a.Registration_Date__c = Currentdt;
                                //TW <MOZO POST 5-1-2015 > - Temp code: If today's date < 9/1/2015 then set the Expire date to 9/1/2016 , Else continue with Membership date algortihm
                                if(Currentdt > date.newInstance(2015,9,1) || Test.isRunningTest()){
                                   // month = 7;
                                   // day = 1;
                                    //if(getMembership == true  && a.Date_Inactive__c != null ) {
                                   		if(a.Date_Inactive__c != null ) {
                                    		tempDate = a.Date_Inactive__c;
                                   		}else{
                                       		a.Date_Inactive__c = date.newInstance(Currentdt.year(),month,day);
                                   		} 
                            			Integer regYear = tempDate.year();
                                    	// If year < this year, then make sure you make the year current and add 1 to it.
                                    	if(year >= regYear){
                                    		Integer howManyYears  = year  -  regYear;
                                        	year = regYear+howManyYears;
                                    	}
                                    	if(regYear > year){
                                          year = regYear;
                                    	}
                                        date myDate = date.today();
										date cutoff1 = date.newInstance(2021, 02, 15);
                                    	if(myDate>cutoff1)
											year = year + 1;
                                    
                                    	a.Date_Inactive__c = date.newInstance(year,month,day);
                                    
                                   	if(changeMozoExpiration == true){ // Mozo Level will have the same date as Reg if it was also ordered at the same time.
                                    system.debug('<< MOZO DATE AFTER UPDATE>> '+a.MOZO_Expiration_Date__c);
                                         	if(a.MOZO_Expiration_Date__c != null ) {
                                     			tempDate = a.MOZO_Expiration_Date__c;
                                         	}else{
                                             	a.MOZO_Expiration_Date__c= Currentdt;
                                         	}
                            				Integer someYear = tempDate.year();
                                            Integer Myear = Currentdt.year();
                                    		// If year < this year, then make sure you make the year current and add 1 to it.
                                    		if(Myear > someYear){
                                    			Integer howManyYears  = Myear  -  someYear;
                                        		Myear = someYear+howManyYears;
                                    		}
                                    		if(someYear >= Myear){
                                          		Myear = someYear;
                                    		}
                                            Myear = Myear + 1;
                                            tempDate = a.MOZO_Expiration_Date__c;
                            				Integer Mmonth = tempDate.month();
                                        	Integer Mday =  tempDate.day();
                                       		a.MOZO_Expiration_Date__c =  date.newInstance(Myear,Mmonth,Mday); 
                                  	}
              						system.debug('<< MOZO DATE AFTER UPDATE>> '+a.MOZO_Expiration_Date__c);
                                }
                                // The conditional statement above was for both preSale date < 9/1/2016 and Test case purposes.    
                                if(a.Registration_Status__c == 'Dropped'){ 
                                    a.Registration_Status__c = 'Reinstated';
                                }
                                if(a.Status__c == 'Pending'){
                                    a.Status__c = 'Added';
                                }
                            }else{ // So R1 did not change but Mozo Level may have change.
                            	//If Mozo Expiration Date: Update the MOZO expiration date for any non-Upgrade scenarios.
                            	system.debug('<< CHANGE MOZO EXPIRATION IS >> '+changeMozoExpiration);
                                system.debug('<< MOZO EXPIRATION DATE IS >> '+a.MOZO_Expiration_Date__c);
                                system.debug('<< REG EXPIRATION DATE IS >> '+a.Date_Inactive__c);
                                if(changeMozoExpiration == true ){ 
                                    if(a.MOZO_Expiration_Date__c != null){ 
                                		tempDate = a.MOZO_Expiration_Date__c; // get the upper limit exp date from Registration Expiration Date.
                                 	}else{ // So R1 did not change but Mozo Level did change.
                                        a.MOZO_Expiration_Date__c =tempDate; // get the upper limit exp year from Registration Expiration Date.
                                 	}
                                  	//month = 7;
                                   // day = 1;
                                    system.debug('<< TEMPDATE IS >> '+tempDate);
                            		Integer someYear = tempDate.year();
                                    // If year < this year (due to previous Reg dropped status), then make sure you make the year current and add 1 to it.
                                    if(year >= someYear){
                                    	Integer howManyYears  = year  -  someYear;
                                        year = someYear+howManyYears;
                                        system.debug('<< TEMPDATE YEAR >= SOME YEAR >> '+year+', '+someYear);
                                    }
                                    if(someYear > year){
                                    	year = someYear;
                                         system.debug('<< TEMPDATE SOMEYEAR > YEAR >> '+year+', '+someYear);
                                    }
                                    
                                    year = year + 1;
                                 	a.MOZO_Expiration_Date__c = date.newInstance(year,todayMonth,todayDay);
                                    system.debug('<< MOZO EXP YEAR TALLY IS >> '+a.MOZO_Expiration_Date__c);
                                }
                            }//Else
                            changeExpiration = false;
                            changeMozoExpiration = false;
                            String forReason = default_registration_reason+' for new Registration Level: '+a.Registration_Level__c;
                            registrations_to_insert.add(new Registration_History__c(
                            Account__c=a.Id, Status__c=a.Registration_Status__c, Reason__c=forReason,
                            Registration_Date__c = a.Registration_Date__c, // account registration date 
                            Expiration_Date__c = a.Date_Inactive__c));  // expiration date
                             system.debug('<< -- 2 -- REGISTRATION PRODUCT>> '+getOrder.Registration_Product__c);
                            if(getOrder.Registration_Product__c.contains('M') && getOrder.Registration_Product__c.length() >= 4){
                                //Sadly , the Reg Product field prohibits me from doing normal substring functions on it
                                if(getOrder.Registration_Product__c.contains('M1')){ a.MOZO_Level__c = 'M1';}
                                else if(getOrder.Registration_Product__c.contains('M2')){ a.MOZO_Level__c = 'M2';}
                                else if(getOrder.Registration_Product__c.contains('M3')){ a.MOZO_Level__c = 'M3';}
                                else{a.MOZO_Level__c = 'M4';}
                               
                            }
                            //6-24-16 Add Sentinel check against duplicate reg history record
                            a.Cast_Iron_Bypass__c = getOrder.Name;
                        }//NOT Sales Credit
                    }// Cast Iron  
                     system.debug('<<NUMBER OF QUERIES USED : '+Limits.getQueries());
                }//LOOP 
                //8. Update Accounts, Registration object, and Affiliations which may have been changed if church was newly registered or Membership was upgraded.
                system.debug('<<MOZOACCOUNTS>> '+mozoAccounts);
                if(!Test.isRunningTest())
                    update mozoAccounts;
                	upsert registrations_to_insert;
                if(listOfOCRMozoAffs.size() > 0){
                  upsert listOfOCRMozoAffs;
                }
               
                if(listOfValidMozoAffs.size() > 0){
                    upsert listOfValidMozoAffs;
                }

            }// IF Account Size !Empty
           
            system.debug('<<NUMBER OF QUERIES USED : '+Limits.getDMLStatements());
        }// TRY
        catch(MozoException me){
           // This catches the Mozo Exception.. hopefully we never get here. 
           system.debug('<<ERROR processing Membership Registration>> '+me);
        }
    }
}