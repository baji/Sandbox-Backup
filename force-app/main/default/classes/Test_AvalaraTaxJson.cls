@isTest (seeAllData = True)
Global Class Test_AvalaraTaxJson{
     public static testmethod  void TestAvalara(){   
        list<Order> orderLst =  [SELECT Id FROM Order WHERE TotalAmount>0 AND 
        Shipping_Street__c!=null and Shipping_City__c!=null and Shipping_State__c!=null and Shipping_Zip_Code__c!=null and Shipping_Country__c!=null and TempOrderNumber__c!=null and Account.IntacctID__c!=null and Company__c!=null LIMIT 1];
        system.debug(orderLst );
        AvalaraTaxJSON Obj = new AvalaraTaxJSON(orderLst[0].id);
        
    }
}