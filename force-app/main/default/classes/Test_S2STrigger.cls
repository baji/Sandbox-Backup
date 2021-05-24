@isTest
public class Test_S2STrigger{
    static testMethod void Data(){
        List<Account> listAcc = new List<Account>();
        for(RecordType obj : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType='Account' AND Name='Business']){
            Account acc = new Account();
                acc.Name = 'TestAcc';
                acc.RecordTypeId = obj.Id;
            listAcc.add(acc);
        }
        Insert listAcc;
        
        Contact con = new Contact();
            con.LastName = 'Imran';
            con.AccountId = listAcc[0].Id;
        Insert con;
            
        List<npe5__Affiliation__c> listAffiliation = new List<npe5__Affiliation__c>();
        for(RecordType obj : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType='Account' AND Name='Business']){
            npe5__Affiliation__c aff = new npe5__Affiliation__c();
                aff.npe5__Contact__c = con.Id;
                aff.npe5__Organization__c = listAcc[0].Id;
            listAffiliation.add(aff);
        }
        Insert listAffiliation;
        
        List<Honorarium_Request__c> hrList = new List<Honorarium_Request__c>();
        for(RecordType obj : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType='Honorarium_Request__c']){
            Honorarium_Request__c hr = new Honorarium_Request__c();
                hr.City__c = 'Hyderabad';
                hr.Phone__c = '8121448600';
                hr.RecordTypeId = obj.Id;
            hrList.add(hr);
            
        }
        Insert hrList;

        List<Check_Request__c> crList = new List<Check_Request__c>();
        for(RecordType obj : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType='Check_Request__c']){
            Check_Request__c cr = new Check_Request__c();
                cr.City__c = 'Hyderabad';
                cr.State__c = 'AP';
                cr.RecordTypeId = obj.Id;
                cr.Address_Line_1__c = 'Ongole';
                cr.Business_Purpose_for_Check_Request__c ='Test Busines Process';
                cr.Department_Number__c ='y7ec1038';
                cr.Full_Name__c ='Imran Shaik';
                cr.Requester_Name__c ='Kumar';
                cr.Zip_Code__c ='50018';
            crList.add(cr);
            
        }
        Insert crList;
    }
    
    static testMethod void Data1(){
        
        Account fullAcc = Test_S2SObjects.S2S_FullAccount();
        Insert fullAcc;
        
        Order ord = Test_S2SObjects.S2S_FullOrder();
            ord.AccountId = fullAcc.Id;
            ord.Source_Opportunity_Id__c = '0065000000ha3XjAAI';
        Insert ord;
        Sales_Invoice__c ssi = new Sales_Invoice__c();
            ssi.Name = 'TestInvocie';           
        Insert ssi;
        
        Sales_Invoice_Item__c si = new Sales_Invoice_Item__c();
            si.Name = 'TestInvoiceItem';
            si.Sales_Invoice__c = ssi.Id;
            si.Source_Opportunity_Id__c = '0065000000ha3XjAAI';
        Insert si;
        
        RITT_Courses__c rtc = new RITT_Courses__c();
            rtc.Name = 'TestCourse';
            rtc.RIU__c = 20;
        Insert rtc;
        
        US_Counties__c us = new US_Counties__c();
            us.Name = 'Name';
            us.State_Name__c = 'Kerala';
        Insert us;
        
    }   
    static testMethod void testAddress(){
        Account fullAcc = Test_S2SObjects.S2S_FullAccount();
        Insert fullAcc;       
        Address__c Add= new Address__c();
        Add.Account__c = fullAcc.id;
        Add.First_Name__c = 'Test 1';
        Add.Last_Name__c = 'Address 1'; 
        Add.Address_Line_1__c = '123 Street';
        Add.Address_Line_2__c = '123 Street'; 
        Add.City__c = 'Streamwood'; 
        Add.State__c='IL';
        Add.Zip_Code__c='60107';
        Add.County__c='Cook';
        Add.Country__c='UNITED STATES';
        insert Add;
    }
    
    static testMethod void testOtherSalesDocument(){
        Account fullAcc = Test_S2SObjects.S2S_FullAccount();
        Insert fullAcc;       
        Other_Sales_Document__c otherSales= new Other_Sales_Document__c();
        otherSales.Account__c = fullAcc.id;
        otherSales.Name = 'Other Sales 1'; 
        otherSales.Bill_to_Address_1__c= '123 Street';
        otherSales.Bill_to_Address_2__c= '1234 Street'; 
        otherSales.Bill_to_City__c = 'Streamwood'; 
        
        insert otherSales;
    }
}