@isTest
public class ProductRelatedOrdersExtension_Test {
    
    static testMethod void verifyProductRelatedOrdersExtension(){
        List<Product2> productList = TestObjects.NewProducts();
        product2 prd = productList[0];
        Account testAccount = TestObjects.NewCustomAccount();
        insert testAccount;
        ChargentOrders__ChargentOrder__c cn = new ChargentOrders__ChargentOrder__c();
        cn.ChargentOrders__Billing_Country__c = 'United States';
        insert cn;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = productList[0].Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        Order newOrder = TestObjects.NewOrder();
        newOrder.AccountId = testAccount.id;
        newOrder.Pricebook2Id = pricebookId;
        newOrder.Status = 'Order Submitted';
        newOrder.Chargent_Order__c = cn.Id;
        insert newOrder;
        
        OrderItem ordItem = new OrderItem();
        ordItem.Product2Id = productList[0].id;
        ordItem.OrderId = newOrder.Id;
        ordItem.UnitPrice = -7.99;
        ordItem.Quantity = 3.00;
        ordItem.PricebookEntryId = standardPrice.id;
        insert ordItem;
        Test.startTest();
        PageReference pageRef = Page.Product_Orders;
        pageRef .getParameters().put('id',productList[0].Id);
        Test.setCurrentPageReference(pageRef);
        ApexPages.standardSetController sc = new ApexPages.standardSetController(productList);
        ProductRelatedOrdersExtension ae = new ProductRelatedOrdersExtension(sc);
        ae.getOrdItemList();
        ae.Beginning();
        ae.Previous();
        ae.Next();
        ae.End();
        ae.getDisablePrevious();
        ae.getDisableNext();
        ae.getTotal_size();
        ae.getPageNumber();
        ae.getTotalPages();
        Test.stopTest();
    }
    static testMethod void verifyProductRelatedOrdersException(){
        List<Product2> productList1 = TestObjects.NewProducts();
        Test.startTest();
        PageReference pageRef = Page.Product_Orders;
        pageRef .getParameters().put('id',productList1[0].Id);
        Test.setCurrentPageReference(pageRef);
        ApexPages.standardSetController sc = new ApexPages.standardSetController(productList1);
        ProductRelatedOrdersExtension ae = new ProductRelatedOrdersExtension(sc);
        ae.getOrdItemList();
        ae.Beginning();
        ae.Previous();
        ae.Next();
        ae.End();
        ae.getDisablePrevious();
        ae.getDisableNext();
        ae.getTotal_size();
        ae.getPageNumber();
        ae.getTotalPages();
        Test.stopTest();
    }
}