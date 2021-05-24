/*
Purpose - A batch which wil create Order from migrated opportunity and update this old opprtunity for deletion. 
Author - Darshan Chhajed.
*/

Global Class MigrateOpportunityToOrder implements Database.Batchable<sObject>{
    
    string query;
    string orderRecordTypeName = 'Orders';
    map<Id,Opportunity> opprtunityDataMap = new map<Id,Opportunity>();
    list<String> Accounts_Address_Country_IdsToFetch = new list<String>();
    list<String> CampaignsToFetch = new list<String>();
    list<String> OwnersToFetch = new list<String>();
    list<String> PriceBooksToFetch = new list<String>();
    // this map is used to to fond out what orderItem had an error while inserting 
     map<integer,string> OrderToOppty = new map<integer,String>();
    integer key=0;
      
    
    global migrateOpportunityToOrder(){
        query = 'SELECT ';
        query += 'CurrencyIsoCode,';
        query += 'Source_Account_Id__c,';
        query += 'Source_Record_Id__c,';
        query += 'Source_Billing_Address_Id__c,';
        query += 'Source_Campaign_Id__c,';
        query += 'Source_Country_Id__c,';
        query += 'Source_Inquiry_Id__c,';
        query += 'Source_Owner_Email_Id__c,';
        query += 'Source_Pricebook_Id__c,';
        query += 'Source_Record_Type_Name__c,';
        query += 'Source_Shipping_Address_Id__c,';
        query += 'Source_Intacct_Entity_Id__c,';
        query += 'Amount,';
        query += 'CloseDate,';
        query += 'StageName,';
        query +='Account_Updated__c,';
        query +='Billing_County__c,';
        query +='Campaign_Related_Account__c,';
        query +='Cancel_Log__c,';
        query +='Club_Interest__c,';
        query +='Company__c,';
        query +='Corp_Currency_Amount__c,';
        query +='Created_Date_Time__c,';
        query +='Delivery_Mode__c,';
        query +='Description,';
        query +='Direct_Ship_Flag__c,';
        query +='Discounts__c,';
        //query +='Donation_Amount__c,';
        query +='Error_Log__c,';
        query +='First_Shipment__c,';
        query +='Has_Discounts__c,';
        query +='Id,';
        query +='Interest__c,';
        query +='Invoice_Number__c,';
        query +='Last_Activity_Datetime__c,';
        query +='MA_Opportunity_Notes__c,';
        query +='Name,';
        query +='Notes__c,';
        query +='Opportunity_Source__c,';
        query +='Order_Being_Fulfilled__c,';
        query +='Order_Number__c,';
        query +='Order_Submitted__c,';
        query +='Order_Type__c,';
        query +='Original_Order_Date__c,';
        query +='Override_Order_Type__c,';
        query +='Package_Shipped__c,';
        query +='Payment_Terms__c,';
        query +='Pick_Number__c,';
        query +='Pick_Ticket_Not_Fulfillable__c,';
        query +='PriceBook2Id,';
        query +='Price_Group__c,';
        query +='Priority__c,';
        query +='Project_Code__c,';
        query +='Promo_code__c,';
        query +='Purchase_Order__c,';
        query +='Region__c,';
        query +='Registration_Product__c,';
        query +='Rush_Order__c,';
        query +='Shipping_Address__c,';
        query +='Shipping_Carrier__c,';
        query +='Shipping_City__c,';
        query +='Shipping_Code__c,';
        query +='Shipping_Country__c,';
        query +='Shipping_County__c,';
        query +='Shipping_GeoCode__c,';
        query +='Shipping_State__c,';
        query +='Shipping_Street__c,';
        query +='Shipping_Type__c,';
        query +='Shipping_Zip_Code__c,';
        query +='Ship_to_First_Name__c,';
        query +='Ship_to_Last_Name__c,';
        query +='Ship_to_Name__c,';
        query +='Tax_Area__c,';
        query +='TempOrderNumber__c,';
        query +='UTM_Campaign__c,';
        query +='UTM_Content__c,';
        query +='UTM_Medium__c,';
        query +='UTM_Source__c,';
        query +='UTM_Term__c ';
       /* //Adding ChargentSFA fields 
        query +='Chargent_Bank_Account_Name__c,';
		query +='Chargent_Bank_Account_Type__c,';
		query +='Chargent_Bank_Name__c,';
		query +='Chargent_Billing_Address__c,';
		query +='Chargent_Billing_Company__c,';
		query +='Chargent_Billing_Country__c,';
		query +='Chargent_Billing_Email__c,';
		query +='Chargent_Billing_Fax__c,';
		query +='Chargent_Billing_First__c,';
		query +='Chargent_Billing_Last__c,';
		query +='Chargent_Billing_Phone__c,';
		query +='Chargent_Billing_Postcode__c,';
		query +='Chargent_Billing_State__c,';
		query +='Chargent_Billing_Zip__c,';
		query +='Chargent_Card_Name__c,';
		query +='Chargent_Card_Type__c,';
		query +='Chargent_Charge_Amount__c,';
		query +='Chargent_Currency__c,';
		query +='Chargent_Customer_IP__c,';
		query +='Chargent_Invoice_Number__c,';
		query +='Chargent_Manual_Charge__c,';
		query +='Chargent_OrderNumber__c,';
		query +='Chargent_OrderSource__c,';
		query +='Chargent_Payment_Count__c,';
		query +='Chargent_Payment_End_Date__c,';
		query +='Chargent_Payment_Frequency__c,';
		query +='Chargent_Payment_Method__c,';
		query +='Chargent_Payment_Received__c,';
		query +='Chargent_Payment_Start_Date__c,';
		query +='Chargent_Payment_Status__c,';
		query +='Chargent_Payment_Stop__c,';
		query +='Chargent_PO_Number__c,';
		query +='Chargent_Shipping_Address__c,';
		query +='Chargent_Shipping_Amount__c,';
		query +='Chargent_Shipping_City__c,';
		query +='Chargent_Shipping_Company__c,';
		query +='Chargent_Shipping_Country__c,';
		query +='Chargent_Shipping_Duty__c,';
		query +='Chargent_Shipping_First__c,';
		query +='Chargent_Shipping_Last__c,';
		query +='Chargent_Shipping_State__c,';
		query +='Chargent_Shipping_Zip__c,';
		query +='Chargent_Tax_Exempt__c,';
		query +='Chargent_Token__c	'; */       
        query = query +' FROM Opportunity WHERE Safe_to_delete__c =false AND Source_Record_Id__c!=null AND Source_Record_Type_Name__c = '+ '\''+orderRecordTypeName + '\' ';    
    }
    global Database.querylocator start(Database.BatchableContext BC){
          return Database.getQueryLocator(query);  //get Opportunity Data which is migrated from Old instance.
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        list<Order> ordersToBeInserted = new list<Order>();
        list<Error_Log__c> errorLogsTobeInserted = new list<Error_Log__c>();
        /*Collecting Old Ids for all lookups*/
        for(sObject sObj : scope){
            Opportunity Opty = (Opportunity)sObj;
            opprtunityDataMap.put(Opty.Source_Record_Id__c,Opty);
            if(opty.Source_Inquiry_Id__c!=null && opty.Source_Inquiry_Id__c!='')
                Accounts_Address_Country_IdsToFetch.add(opty.Source_Inquiry_Id__c);
            if(opty.Source_Account_Id__c!=null && opty.Source_Account_Id__c!='')
                Accounts_Address_Country_IdsToFetch.add(opty.Source_Account_Id__c);
            if(opty.Source_Billing_Address_Id__c!=null && opty.Source_Billing_Address_Id__c!='')
                Accounts_Address_Country_IdsToFetch.add(opty.Source_Billing_Address_Id__c);
            if(opty.Source_Country_Id__c!=null && opty.Source_Country_Id__c!='')
                Accounts_Address_Country_IdsToFetch.add(opty.Source_Country_Id__c);
            if(opty.Source_Shipping_Address_Id__c!=null && opty.Source_Shipping_Address_Id__c!='')
                Accounts_Address_Country_IdsToFetch.add(opty.Source_Shipping_Address_Id__c);
            if(opty.Source_Intacct_Entity_Id__c!=null && opty.Source_Intacct_Entity_Id__c!='')
                Accounts_Address_Country_IdsToFetch.add(opty.Source_Intacct_Entity_Id__c);
            if(opty.Source_Campaign_Id__c!=null && opty.Source_Campaign_Id__c!='')
                CampaignsToFetch.add(opty.Source_Campaign_Id__c);           
            OwnersToFetch.add(opty.Source_Owner_Email_Id__c);
            if(opty.Source_Pricebook_Id__c!=null && opty.Source_Pricebook_Id__c!='')
                PriceBooksToFetch.add(opty.Source_Pricebook_Id__c);
            
        }
        system.debug('Accounts_Address_Country_IdsToFetch---'+Accounts_Address_Country_IdsToFetch);
        /*fetch New Data for lookups with map of old and new Id*/
        map<Id,Id> oldToNewIdMap = S2SPartnerNetworkRecordUtility.getData(Accounts_Address_Country_IdsToFetch);
        map<string,string> campaignOldIdToNewId =  MigrationUtility.getCampaignData(CampaignsToFetch);
        map<String,String>userEmailToIdMap = MigrationUtility.getUserData(OwnersToFetch);
        map<string,string> priceBookOldIdToNewId =  MigrationUtility.getPriceBookData(PriceBooksToFetch);
 		map<Integer, Opportunity> OpportunityToUpdate = new map<Integer,Opportunity>();
        /*Creating New Order Records*/
        map<Integer,ChargentOrders__ChargentOrder__c> ChargentOrderMap = new map<Integer,ChargentOrders__ChargentOrder__c>();
        map<Integer, Order> ordersTobeInsertMap = new map<Integer,Order>();
        key=0; //initialise KEY as 0 as list will start from 0;
        system.debug('oldToNewIdMap---'+JSON.serialize(oldToNewIdMap));
        for(Opportunity opp : opprtunityDataMap.Values()){
            
            system.debug('opp---'+opp);
            if(oldToNewIdMap.containsKey(opp.Source_Account_Id__c) && oldToNewIdMap.get(opp.Source_Account_Id__c)!=null){ // Account is Madetory
                Order Ord = new Order();
                /*Mapping fields from Opportunity to Order*/
                Ord.Name = opp.Name;
                Ord.effectiveDate = opp.closeDate;
                Ord.Status = opp.StageName;
                Ord.Source_Opportunity_Id__c = opp.Source_Record_Id__c;
                
                Ord.CurrencyIsoCode=opp.CurrencyIsoCode;
                Ord.Company__c = opp.Company__c;
                Ord.Payment_Terms__c = opp.Payment_Terms__c;
                Ord.Shipping_Type__c = opp.Shipping_Type__c;
                Ord.Account_Updated__c = opp.Account_Updated__c;
                Ord.Club_Interest__c = opp.Club_Interest__c;
                Ord.Delivery_Mode__c = opp.Delivery_Mode__c;
                Ord.Description = opp.Description;
                Ord.Direct_Ship_Flag__c = opp.Direct_Ship_Flag__c;
                Ord.Discounts__c = opp.Discounts__c  ;
                Ord.First_Shipment__c = opp.First_Shipment__c  ;
                Ord.Has_Discounts__c = opp.Has_Discounts__c  ;
                Ord.Interest__c  = opp.Interest__c   ;
                Ord.Invoice_Number__c = opp.Invoice_Number__c;
                Ord.Last_Activity_Datetime__c = opp.Last_Activity_Datetime__c;
                Ord.MA_Opportunity_Notes__c = opp.MA_Opportunity_Notes__c;
                Ord.Notes__c = opp.Notes__c ;
                Ord.Order_Being_Fulfilled__c = opp.Order_Being_Fulfilled__c ;
                Ord.Order_Submitted__c = opp.Order_Submitted__c;
                Ord.Override_Order_Type__c = opp.Override_Order_Type__c;
                Ord.Package_Shipped__c = opp.Package_Shipped__c;
                Ord.Pick_Number__c = opp.Pick_Number__c;
                Ord.Pick_Ticket_Not_Fulfillable__c = opp.Pick_Ticket_Not_Fulfillable__c;
                Ord.Price_Group__c = opp.Price_Group__c;
                Ord.Priority__c = opp.Priority__c;
                Ord.Promo_code__c = opp.Promo_code__c;
                Ord.Purchase_Order__c = opp.Purchase_Order__c;
                Ord.Region__c = opp.Region__c;
                Ord.Registration_Product__c = opp.Registration_Product__c;
                Ord.Rush_Order__c = opp.Rush_Order__c;
                Ord.Shipping_Carrier__c = opp.Shipping_Carrier__c;
                Ord.Tax_Area__c = opp.Tax_Area__c;
                Ord.Order_Number__c = opp.Order_Number__c;
                Ord.UTM_Campaign__c = opp.UTM_Campaign__c ;
                Ord.UTM_Content__c = opp.UTM_Content__c;
                Ord.UTM_Medium__c = opp.UTM_Medium__c;
                Ord.UTM_Source__c = opp.UTM_Source__c;
                Ord.UTM_Term__c = opp.UTM_Term__c;
                Ord.Order_Type__c = opp.Order_Type__c;
                Ord.Original_Order_Date__c = opp.Original_Order_Date__c;
                Ord.Corp_Currency_Amount__c = opp.Corp_Currency_Amount__c ;
                Ord.Created_Date_Time__c = opp.Created_Date_Time__c;
                Ord.Ship_to_First_Name__c = opp.Ship_to_First_Name__c;
                Ord.Ship_to_Last_Name__c = opp.Ship_to_Last_Name__c;
                Ord.Error_Log__c = opp.Error_Log__c;
                Ord.Shipping_Street__c = opp.Shipping_Street__c ;
                Ord.Shipping_City__c = opp.Shipping_City__c;
                Ord.Shipping_State__c = opp.Shipping_State__c;
                Ord.Shipping_Zip_Code__c = opp.Shipping_Zip_Code__c;
                Ord.Shipping_County__c = opp.Shipping_County__c;
                Ord.Shipping_Country__c = opp.Shipping_Country__c;
                Ord.Opportunity_Source__c = opp.Opportunity_Source__c;
                Ord.Campaign_Related_Account__c = opp.Campaign_Related_Account__c;
                
                /*Mapping All Lookups*/
               if(campaignOldIdToNewId.containsKey(opp.Source_Campaign_Id__c) && campaignOldIdToNewId.get(opp.Source_Campaign_Id__c)!=null)    
                    Ord.Campaign__c = campaignOldIdToNewId.get(opp.Source_Campaign_Id__c);
                if(priceBookOldIdToNewId.containsKey(opp.Source_Pricebook_Id__c) && priceBookOldIdToNewId.get(opp.Source_Pricebook_Id__c)!=null)
                    Ord.PriceBook2Id =  priceBookOldIdToNewId.get(opp.Source_Pricebook_Id__c);  
                if(oldToNewIdMap.containsKey(opp.Source_Account_Id__c) && oldToNewIdMap.get(opp.Source_Account_Id__c)!=null)
                    Ord.AccountId = oldToNewIdMap.get(opp.Source_Account_Id__c);
                if(oldToNewIdMap.containsKey(opp.Source_Billing_Address_Id__c) && oldToNewIdMap.get(opp.Source_Billing_Address_Id__c)!=NULL)
                    Ord.Billing_Address__c = oldToNewIdMap.get(opp.Source_Billing_Address_Id__c);
                if(oldToNewIdMap.containsKey(opp.Source_Shipping_Address_Id__c) && oldToNewIdMap.get(opp.Source_Shipping_Address_Id__c)!=null)
                    Ord.Shipping_Address__c = oldToNewIdMap.get(opp.Source_Shipping_Address_Id__c);
                if(oldToNewIdMap.containsKey(opp.Source_Inquiry_Id__c) && oldToNewIdMap.get(opp.Source_Inquiry_Id__c)!=null)
                    Ord.Inquiry_ID2__c = oldToNewIdMap.get(opp.Source_Inquiry_Id__c);
                if(oldToNewIdMap.containsKey(opp.Source_Intacct_Entity_Id__c) && oldToNewIdMap.get(opp.Source_Intacct_Entity_Id__c)!=null)
                    Ord.Intacct_Entity__c = oldToNewIdMap.get(opp.Source_Intacct_Entity_Id__c); 
                if(oldToNewIdMap.containsKey(opp.Source_Country_Id__c) &&  oldToNewIdMap.get(opp.Source_Country_Id__c)!=null)
                    Ord.Country__c = oldToNewIdMap.get(opp.Source_Country_Id__c);       
                //system.debug('**Oppty Id**'+opp.Id+'    value**'+oldToNewIdMap.get(opp.Source_Account_Id__c));          
               
                //hardcode id 
                if(!Test.isRunningTest()){
                	Ord.ownerId = userEmailToIdMap.containsKey(opp.Source_Owner_Email_Id__c) ? userEmailToIdMap.get(opp.Source_Owner_Email_Id__c) : '005f4000000ZJhT';
    			}
               
                
                opp.Safe_to_delete__c = true;
                //add values in following map for insertion/updation 
                OpportunityToUpdate.put(key,opp);
                OrderToOppty.put(key,opp.Id);
                //creatin chargent Orders with Chargent SFA flds
                ChargentOrders__ChargentOrder__c ChargentOrder = new ChargentOrders__ChargentOrder__c();
                /*ChargentOrder.ChargentOrders__Bank_Account_Name__c = opp.Chargent_Bank_Account_Name__c;
				ChargentOrder.ChargentOrders__Bank_Account_Type__c = opp.Chargent_Bank_Account_Type__c;
				ChargentOrder.ChargentOrders__Bank_Name__c = opp.Chargent_Bank_Name__c;
				ChargentOrder.ChargentOrders__Billing_Address__c = opp.Chargent_Billing_Address__c;
				ChargentOrder.ChargentOrders__Billing_City__c = opp.Chargent_Billing_City__c;
				ChargentOrder.ChargentOrders__Billing_Company__c = opp.Chargent_Billing_Company__c;
				ChargentOrder.ChargentOrders__Billing_Country__c = opp.Chargent_Billing_Country__c;
				ChargentOrder.ChargentOrders__Billing_Email__c = opp.Chargent_Billing_Email__c;
				ChargentOrder.ChargentOrders__Billing_Fax__c = opp.Chargent_Billing_Fax__c;
				ChargentOrder.ChargentOrders__Billing_First_Name__c = opp.Chargent_Billing_First__c;
				ChargentOrder.ChargentOrders__Billing_Last_Name__c = opp.Chargent_Billing_Last__c;
				ChargentOrder.ChargentOrders__Billing_Phone__c = opp.Chargent_Billing_Phone__c;
				ChargentOrder.ChargentOrders__Billing_State__c = opp.Chargent_Billing_State__c;
				ChargentOrder.ChargentOrders__Billing_Zip_Postal__c = opp.Chargent_Billing_Postcode__c;
				ChargentOrder.ChargentOrders__Card_Type__c = opp.Chargent_Card_Type__c;
				ChargentOrder.ChargentOrders__Charge_Amount__c = opp.Chargent_Charge_Amount__c;
				ChargentOrder.ChargentOrders__Currency__c = opp.Chargent_Currency__c;
				ChargentOrder.ChargentOrders__Customer_IP__c = opp.Chargent_Customer_IP__c;
				ChargentOrder.ChargentOrders__Invoice_Number__c = opp.Chargent_Invoice_Number__c;
				ChargentOrder.ChargentOrders__Manual_Charge__c = opp.Chargent_Manual_Charge__c;
				ChargentOrder.ChargentOrders__OrderNumber__c = opp.Chargent_OrderNumber__c;
				ChargentOrder.ChargentOrders__OrderSource__c = opp.Chargent_OrderSource__c;
				ChargentOrder.ChargentOrders__Order_Information__c = opp.Chargent_Order_Information__c;
				ChargentOrder.ChargentOrders__Payment_Count__c = opp.Chargent_Payment_Count__c;
				ChargentOrder.ChargentOrders__Payment_End_Date__c = opp.Chargent_Payment_End_Date__c;
				ChargentOrder.ChargentOrders__Payment_Frequency__c = opp.Chargent_Payment_Frequency__c;
				ChargentOrder.ChargentOrders__Payment_Method__c = opp.Chargent_Payment_Method__c;
				ChargentOrder.ChargentOrders__Payment_Received__c = opp.Chargent_Payment_Received__c;
				ChargentOrder.ChargentOrders__Payment_Start_Date__c = opp.Chargent_Payment_Start_Date__c;
				ChargentOrder.ChargentOrders__Payment_Status__c = opp.Chargent_Payment_Status__c;
				ChargentOrder.ChargentOrders__Payment_Stop__c = opp.Chargent_Payment_Stop__c;
				ChargentOrder.ChargentOrders__Shipping_Address__c = opp.Chargent_Shipping_Address__c;
				ChargentOrder.ChargentOrders__Shipping_City__c = opp.Chargent_Shipping_City__c;
				ChargentOrder.ChargentOrders__Shipping_Company__c = opp.Chargent_Shipping_Company__c;
				ChargentOrder.ChargentOrders__Shipping_Country__c = opp.Chargent_Shipping_Country__c;
				ChargentOrder.ChargentOrders__Shipping_Duty__c = opp.Chargent_Shipping_Duty__c;
				ChargentOrder.ChargentOrders__Shipping_First_Name__c = opp.Chargent_Shipping_First__c;
				ChargentOrder.ChargentOrders__Shipping_Name__c = opp.Chargent_Shipping_Last__c;
				ChargentOrder.ChargentOrders__Shipping_State__c = opp.Chargent_Shipping_State__c;
				ChargentOrder.ChargentOrders__Shipping_Zip_Postal__c = opp.Chargent_Shipping_Zip__c;
				ChargentOrder.ChargentOrders__Tax_Exempt__c = opp.Chargent_Tax_Exempt__c;
				ChargentOrder.ChargentOrders__Tokenization__c = opp.Chargent_Token__c;*/
                ChargentOrder.Source_Opportunity_Id__c = opp.Source_Record_Id__c;
                ChargentOrder.OwnerId =  Ord.ownerId;
                ChargentOrderMap.put(key,ChargentOrder);
                ordersToBeInserted.add(Ord);
                ordersTobeInsertMap.put(key,Ord);
                key++;
            }else{
            		Error_Log__c errLog = new Error_Log__c();
            		errLog.Trace__C = 'Account is not present for Source_Account_Id__c';
		            errLog.Object_Name__c = 'MigrateOpportunityOrder';
		            errLog.Record_Id__c = Opp.Id;
		            errorLogsTobeInserted.add(errLog);
            }
        }
        try{
        	insert ChargentOrderMap.values(); //insert all new chargent Values [2 SOQL and 2 DML]
           	for(integer i=0;i<ordersTobeInsertMap.size();i++)
           		OrdersTobeInsertMap.get(i).Chargent_Order__c = ChargentOrderMap.get(i).Id;
           	Database.SaveResult[] srList = Database.insert(ordersToBeInserted, false);
            for(integer itr=0; itr<srList.size(); itr++){
            	if(srList[itr].isSuccess()){
            		ChargentOrderMap.remove(itr);
            	}
            	else{
            		Error_Log__c errLog = new Error_Log__c();
            		errLog.Trace__C = '';
		            for(Database.Error err : srList[itr].getErrors())
		            	errLog.Trace__C = errLog.Trace__C + 'Error -' + string.valueOf(err.getMessage()) + ' Feilds - '+ string.valueOf(err.getFields()) + '\n';
		            errLog.Object_Name__c = 'MigrateOpportunityOrder';
		            errLog.Record_Id__c = OrderToOppty.get(itr);
		            errorLogsTobeInserted.add(errLog);
		            OpportunityToUpdate.remove(itr);  
            	}
            	
            }
            insert errorLogsTobeInserted;
            delete ChargentOrderMap.Values(); //delete chargent order for which Order has not created.
            update OpportunityToUpdate.Values(); //update oppty for 
        }catch(Exception e){
            system.debug('**Exception**'+e+'    MSG-'+e.getStackTraceString());
            Error_Log__c err = new Error_Log__c();
            err.Trace__C = e.getStackTraceString() + String.valueOf(e);
            err.Object_Name__c = 'Exception IN MigrateOpportunityToOrder';
            insert err;
            //notify the exception. 
        }
        
    }
    global void finish(Database.BatchableContext BC){
    }

}