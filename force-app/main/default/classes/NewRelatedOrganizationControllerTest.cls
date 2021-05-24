/*
* Purpose   : This test class covers the NewRelatedOrganizationController class used in Org-Org affiliation redirection.
* Developer : Mayur Soni(msoni@apttus.com) 
*/
@isTest
public class NewRelatedOrganizationControllerTest {
    
    @TestSetup
    public static void testDataCreate(){
        Awana_Settings__c awanaSettings = new Awana_Settings__c(Name='DRMDuplicateContactUpdate',Value__c='false');
        insert awanaSettings;
        Contact con = new Contact(
            lastName='DO NOT DELETE',
            FirstName='Contact'
        );
        insert con;
        List<RecordType> getUSRecordType = [Select Id from recordType where Name = 'US Organization' limit 1]; 
        Account a2 = new Account();
        a2.Name = 'Account Org 1';
        a2.Status__c = 'Added';
        a2.ShippingStreet = '503 Scruggs St';
        a2.Mailing_Street_1__c ='702 Scruggs St' ;
        a2.ShippingCity = 'Waycross';
        a2.Mailing_City__c = 'Waycross';
        a2.ShippingState = 'GA';
        a2.Mozo_Trial_Status__c = 'Current';
        a2.Mozo_Trial_End_Date__c = system.today() + 90;
        a2.Registration_Level__c = 'R1';
        a2.Mailing_State_Province__c='GA';
        a2.ShippingCountry ='United States';
        a2.Mailing_Country__c='United States';
        a2.ShippingPostalCode = '31501';
        a2.Mailing_Zip_Postal_Code__c = '31501';
        a2.BillingStreet='503 Scruggs St';
        a2.Physical_Street_1__c ='702 Scruggs St';
        a2.BillingCity = 'Waycross';
        a2.Physical_City__c ='Waycross';
        a2.BillingState ='CA';
        a2.Physical_State__c = 'CA';
        a2.BillingCountry = 'United States';
        a2.PhysicalCountry__c = 'United States';
        a2.BillingPostalCode = '31501';
        a2.Physical_Zip__c = '31501';
        a2.RecordType =  getUSRecordType[0];//getRecordType;
        a2.OwnerId=userinfo.getUserId();
        a2.Mozo_Trial_Status__c = 'Current';
        a2.Mozo_Trial_End_Date__c = system.today();
        a2.Mailing_Address_Book__c = '000125'; 
        insert a2;
    }
    @isTest
    public static void testRedirect(){
        
        Contact con = [SELECT Id,name,AccountId,Account.name FROM Contact WHERE lastname='DO NOT DELETE'];
        Account acc = [SELECT Id,name FROM Account WHERE Name='Account Org 1'];
        //ApexPages.StandardController sc = new ApexPages.StandardController(con);
        npe5__Affiliation__c aff = new npe5__Affiliation__c();
        aff.npe5__Contact__c = con.id;
        aff.npe5__Organization__c = con.AccountId;
        insert aff;
        
        PageReference pageRef = Page.NewRelatedOrganization;
        pageRef.getParameters().put('conName',con.name);
        pageRef.getParameters().put('conFieldId','CF00Nf4000005YnsT');
        pageRef.getParameters().put('accLookupFieldId','CF00Nf4000005YnsS');
        pageRef.getParameters().put('accId',acc.Id);
        pageRef.getParameters().put('accName',acc.name);
        
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(aff);
        //SendEmailReceipt testAccPlan = new SendEmailReceipt(sc);
        NewRelatedOrganizationController cont = new NewRelatedOrganizationController(new ApexPages.StandardSetController(new List<npe5__Affiliation__c>{aff}));
        
        cont.theme = 'Theme3';
        Test.startTest();
        Pagereference pg = cont.checkParam();
        System.assert(pg!=null);
        
        cont.theme = 'Theme4t';
        Pagereference pg1 =  cont.checkParam();
        System.assert(pg1==null);
        Test.stopTest();
    }
}