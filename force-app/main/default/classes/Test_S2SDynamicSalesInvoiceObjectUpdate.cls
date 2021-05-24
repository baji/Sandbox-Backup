@isTest
public class Test_S2SDynamicSalesInvoiceObjectUpdate{
    static testMethod void otherSales(){
        
        Sales_Invoice__c osd1 = new Sales_Invoice__c();
            osd1.Name = 'Test';
        Insert osd1;
        
        Sales_Invoice__c osd = new Sales_Invoice__c();
            osd.Name = 'Test Salesforce Document';
            osd.Source_Sales_Invoice_Rec_Id__c = osd1.Id;
            osd.Source_IntAcct_Entity_OwnerEmailId__c  = 'dadadasdasd';
        Insert osd;
        
        S2SDynamicSalesInvoiceObjectUpdate ss = new S2SDynamicSalesInvoiceObjectUpdate();
        Database.ExecuteBatch(ss,10);
    }
}