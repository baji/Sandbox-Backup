@isTest
public class BatchUpdateProductListPriceTest {
    @isTest static void testBatch(){
        
        test.startTest();   		
        BatchUpdateProductListPrice batch = new BatchUpdateProductListPrice();
        Database.ExecuteBatch(batch);  
        test.stopTest();
        
        List<Product2> prodList = [SELECT Id,List_Price__c FROM Product2];
        system.assertEquals(prodList[0].List_Price__c,12.00);
    }
   
    @testSetup static void createTestData() {
        Id pricebookId = Test.getStandardPricebookId();
        
        List<Product2> prodList = new List<Product2>();
        
        for(integer i=0;i<=5;i++){
            Product2 prod = new Product2();
            prod.Name = 'Pen, Books of the Bible';
            prod.Weight__c = 20.00;
            prod.List_Price__c = 0;
            if(i<=4)
            	prod.IsActive = true;
            else
                prod.IsActive = false;
            prodList.add(prod);
        }
        insert prodList;
        
        
        List<PricebookEntry> standardPbeList = new List<PricebookEntry>();
        
        for(integer i=0;i<=5;i++){
            PricebookEntry standardPrice = new PricebookEntry();
            standardPrice.Pricebook2Id = pricebookId;
            standardPrice.Product2Id = prodList[i].Id;
            standardPrice.IsActive = true;
            standardPrice.UnitPrice = 10.00;                 
            standardPbeList.add(standardPrice);            
        }     
        insert standardPbeList;		        
        
        Pricebook2 customPb = new Pricebook2();
        customPb.Name = 'Catalog Price Book';
        customPb.IsActive = true;        
        
        insert customPb;
        
        List<PricebookEntry> customPbeList = new List<PricebookEntry>();
        
        for(integer i=0;i<=5;i++){
            PricebookEntry customPrice = new PricebookEntry();
            customPrice.Pricebook2Id = customPb.Id;
            customPrice.Product2Id = prodList[i].Id;
            customPrice.UnitPrice = 12.00;
            customPrice.IsActive = true;
            customPbeList.add(customPrice);
        }
        
        insert customPbeList;        
    }     
}