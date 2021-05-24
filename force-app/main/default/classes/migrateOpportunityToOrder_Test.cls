/*********************************************************************************************************
    Programmer:         Sowmya
    Company:            Awana
    Contact:            sowmya@infoglen.com
    Project:            <SFDC-26> 
    Original:           10/14/2016 - Used to test Opportunity to Order
    
 ***********************************************************************************************************/ 

@IsTest(SeeAllData = true)
private class migrateOpportunityToOrder_Test {
   private static testMethod void OpportunityToOrder_Test(){
       Test.startTest();
           RecordType  acctRecordType= [Select Id from RecordType where Name = 'US Organization' and SObjectType = 'Account'];
            Account Acct =  new Account(Name='Christian Test Church Canada', Description='Test Church');
            system.debug('<<GOT ACCT VALUE?>> '+Acct.Description);
            Acct.RecordTypeId = acctRecordType.Id;
            system.debug('<<ENTERING INTO  acct>> '+Acct );
            Acct.ShippingStreet = '5921 Walnut Hill Ln';
            Acct.ShippingState = 'TX';
            Acct.ShippingPostalCode = '75230';
            Acct.ShippingCountry = 'UNITED STATES';
            Acct.ShippingCity = 'Waco';
            insert Acct;
            
            Opportunity opp = new Opportunity(Safe_to_delete__c = true,Name='O-TEST-0',Payment_Terms__c='Net30',StageName='Order Error',CloseDate=Date.Today());
            insert opp;    
            
            Test_S2SObjects.TestInquiries();
            Lead ld = [Select id,Name From Lead Where FirstName = 'ACQUISITIOn' Limit 1];
            
            List<Address__c> AddList = Test_S2SObjects.NewAddresses();
            
            Intacct_Entity__c Ine = new Intacct_Entity__c(Name = 'Intacct 1',CurrencyIsoCode = 'USD'); 
            insert Ine;
            
            Id pricebookId = Test.getStandardPricebookId();
            
            Opportunity opp1 = new Opportunity(Description = 'Awana Description',Club_Interest__c = 'AwanaKids',Delivery_Mode__c = 'Cash',Account_Updated__c = false,Shipping_Type__c = 'Standard',Company__c='Awana',CurrencyIsoCode = 'USD' ,Safe_to_delete__c = false,Source_Record_Id__c = opp.id,Source_Record_Type_Name__c='Orders',Name='O-TEST-0',Payment_Terms__c='To Be Filled',StageName='Order Error',CloseDate=Date.Today(),Source_Inquiry_Id__c=ld.id,Source_Account_Id__c=Acct.Id,Source_Billing_Address_Id__c=AddList[0].id,Source_Country_Id__c = '1234',Source_Shipping_Address_Id__c=AddList[0].id,Source_Intacct_Entity_Id__c=Ine.Id,Source_Campaign_Id__c='3432',Source_Pricebook_Id__c =pricebookId);
            insert opp1;
            
            system.debug('Opp1 ---'+opp1);
            
            Campaign cm = new Campaign(IsActive = true,Name = 'Campaign 1'); 
            
            //List<PartnerNetworkConnection> connMap = new List<PartnerNetworkConnection>([select Id, ConnectionStatus, ConnectionName from PartnerNetworkConnection where ConnectionStatus = 'Sent' OR ConnectionStatus = 'Received']);
            
            /*List<PartnerNetworkRecordConnection> connMap = new List<PartnerNetworkRecordConnection>([Select Id, ConnectionId, PartnerRecordId, LocalRecordId from PartnerNetworkRecordConnection where Status = 'Received' limit 10]);
            system.debug('con map --'+connMap );

            for(PartnerNetworkRecordConnection network : connMap) {    
                
                PartnerNetworkRecordConnection newrecord1 = new PartnerNetworkRecordConnection();
                    newrecord1.ConnectionId = network.ConnectionId;
                    newrecord1.LocalRecordId = opp1.Id;
                    newrecord1.Status ='Received';
                    //newrecord1.SendOpenTasks = true;
                    //newrecord1.SendEmails = true; 
                insert newrecord1;
                
                system.debug('newrecord1---'+newrecord1);
            }  
            */
            migrateOpportunityToOrder batchObj = new migrateOpportunityToOrder();
            Database.executeBatch(batchObj,200);
       Test.stopTest();
   }
}