@isTest(SeeAllData = True)
public class BatchProductQuantityReservedTest{
    static testMethod void QuantityReserved_TestMethod (){
         
         String query = 'SELECT Id, Name,Quantity_Reserved__c,PSI_Status_Indicator__c'
                +' FROM Product2 '
                +'where (PSI_Status_Indicator__c = \'1\' or PSI_Status_Indicator__c = \'2\' or PSI_Status_Indicator__c = \'3\')'
                +' And (IsActive = true)';
                
        //system.debug('<< QUERY  >> '+query);
        BatchProductQuantityReserved batchObjBSNS = new BatchProductQuantityReserved();
        batchObjBSNS.query = query;
        Test.startTest();
        Database.executeBatch(batchObjBSNS,100);
        Test.stopTest();
       
      
    }
}