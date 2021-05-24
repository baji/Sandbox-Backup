/*
 * Batch name   : DRMUpdateCodeToHouseHold
 * Developed by : Mayur Soni(mayur@infoglen.com)
 * Usage        : This batch will be used in DRM data migration. This will fetch the household related fields of primary contact and update the same in the Account's fields.
 * Date created : 20-Mar-2018
 * Company      : Infoglen
*/
global class DRMUpdateCodeToHouseHold implements Database.Batchable<sObject>{

   global final String query;

   global DRMUpdateCodeToHouseHold(String q){

       
      query=String.isNotBlank(q) ? q :'SELECT Id,Constituent_Id__c,RE_Constit_Rec_Id__c,Constituent_Code__c ,Constituent_Solicit_Code__c ,Missionary_Salutation__c,Major_Donor_Salutation__c,npo02__Formal_Greeting__c,npo02__Informal_Greeting__c,npe01__One2OneContact__c,npe01__One2OneContact__r.Constituent_Code__c,npe01__One2OneContact__r.Constituent_Solicit_Code__c,npe01__One2OneContact__r.Major_Donor_Salutation__c,npe01__One2OneContact__r.Missionary_Salutation__c,npe01__One2OneContact__r.RE_Primary_Salutation__c,npe01__One2OneContact__r.RE_Primary_Addresee__c,npe01__One2OneContact__r.Constituent_Id__c,npe01__One2OneContact__r.RE_Constit_Rec_Id__c,Mailing_Street_1__c,BillingStreet,Mailing_City__c,BillingCity,Mailing_State_Province__c,BillingState,Mailing_Country__c,BillingCountry,Mailing_Zip_Postal_Code__c,BillingPostalCode,Mailing_County__c,Billing_County__c,npe01__One2OneContact__r.MailingStreet,npe01__One2OneContact__r.MailingCity,npe01__One2OneContact__r.MailingState,npe01__One2OneContact__r.MailingCountry,npe01__One2OneContact__r.MailingPostalCode,npe01__One2OneContact__r.Home_County__c FROM Account WHERE npe01__One2OneContact__c != null AND npe01__One2OneContact__r.RE_Sub_set__c IN (\'A\',\'B\',\'D\')';
      
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
       List<Account> accountList = (List<Account>)scope;
       for(Account act : accountList){
           if(act.npe01__One2OneContact__r.Constituent_Code__c != null){
                act.Constituent_Code__c = act.npe01__One2OneContact__r.Constituent_Code__c;
           }
           if(act.npe01__One2OneContact__r.Constituent_Solicit_Code__c != null){
                act.Constituent_Solicit_Code__c = act.npe01__One2OneContact__r.Constituent_Solicit_Code__c;
           }
           if(act.npe01__One2OneContact__r.Missionary_Salutation__c != null){
                act.Missionary_Salutation__c = act.npe01__One2OneContact__r.Missionary_Salutation__c;
           }
           if(act.npe01__One2OneContact__r.Major_Donor_Salutation__c != null){
                act.Major_Donor_Salutation__c = act.npe01__One2OneContact__r.Major_Donor_Salutation__c; 
           }
           if(act.npe01__One2OneContact__r.RE_Primary_Addresee__c != null){
                act.npo02__Formal_Greeting__c = act.npe01__One2OneContact__r.RE_Primary_Addresee__c;
           }
           if(act.npe01__One2OneContact__r.RE_Primary_Salutation__c != null){
                act.npo02__Informal_Greeting__c = act.npe01__One2OneContact__r.RE_Primary_Salutation__c;
           }
           if(act.npe01__One2OneContact__r.Constituent_Id__c!= null){
                act.Constituent_Id__c= act.npe01__One2OneContact__r.Constituent_Id__c;
           }
           if(act.npe01__One2OneContact__r.RE_Constit_Rec_Id__c!= null){
                act.RE_Constit_Rec_Id__c= act.npe01__One2OneContact__r.RE_Constit_Rec_Id__c;
           }
           //copy Contact's Mailing address to HH Account's Mailing and Billing address
           if(act.npe01__One2OneContact__r.MailingStreet!= null){
                act.Mailing_Street_1__c = act.npe01__One2OneContact__r.MailingStreet;
                act.BillingStreet = act.npe01__One2OneContact__r.MailingStreet;
           }
           if(act.npe01__One2OneContact__r.MailingCity!= null){
                act.Mailing_City__c = act.npe01__One2OneContact__r.MailingCity;
                act.BillingCity = act.npe01__One2OneContact__r.MailingCity;
           }
           if(act.npe01__One2OneContact__r.MailingState != null){
                act.Mailing_State_Province__c  = act.npe01__One2OneContact__r.MailingState;
                act.BillingState  = act.npe01__One2OneContact__r.MailingState;
           }
           if(act.npe01__One2OneContact__r.MailingCountry != null){
                act.Mailing_Country__c = act.npe01__One2OneContact__r.MailingCountry;
                act.BillingCountry  = act.npe01__One2OneContact__r.MailingCountry;
           }
           if(act.npe01__One2OneContact__r.MailingPostalCode != null){
                act.Mailing_Zip_Postal_Code__c = act.npe01__One2OneContact__r.MailingPostalCode;
                act.BillingPostalCode  = act.npe01__One2OneContact__r.MailingPostalCode;
           }
           if(act.npe01__One2OneContact__r.Home_County__c != null){
                act.Mailing_County__c = act.npe01__One2OneContact__r.Home_County__c;
                act.Billing_County__c = act.npe01__One2OneContact__r.Home_County__c;
           }
       }
       update accountList;
    }

   global void finish(Database.BatchableContext BC){
   }
}