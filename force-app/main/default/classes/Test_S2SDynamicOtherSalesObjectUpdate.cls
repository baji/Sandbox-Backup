@isTest
public class Test_S2SDynamicOtherSalesObjectUpdate{
    static testMethod void otherSales(){
        
        Other_Sales_Document__c osd1 = new Other_Sales_Document__c();
            osd1.Name = 'Test';
        Insert osd1;
        
        Other_Sales_Document__c osd = new Other_Sales_Document__c();
            osd.Name = 'Test Salesforce Document';
            osd.Source_Other_Sales_Doc_Rec_Id__c = osd1.Id;
        Insert osd;
        
        S2SDynamicOtherSalesObjectUpdate ss = new S2SDynamicOtherSalesObjectUpdate();
        Database.ExecuteBatch(ss,10);
    }
}