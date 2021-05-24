@isTest
public class Test_S2SSalesInvoiceItemUpdate{
    static testMethod void salesInvoiceItem(){
        
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
        
        S2SSalesInvoiceItemUpdate ss = new S2SSalesInvoiceItemUpdate();
            Database.ExecuteBatch(ss,10);
    }
}