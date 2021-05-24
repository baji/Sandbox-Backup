@isTest
Private class GetDeptFulfillmentOrders_Test{
    private static testMethod void handler(){
        List<Address__c> listAdderess=new List<Address__c>();
        listAdderess.add(new Address__c(City__c='Hyderabad',Country__c='India'));
        listAdderess.add(new Address__c(City__c='Banglore',Country__c='India'));
        listAdderess.add(new Address__c(City__c='Chennai',Country__c='India'));
        insert listAdderess;
        List<Product2> listProduct=new List<Product2>();
        listProduct.add(new Product2(Name = 'Laptop X200',Family = 'Hardware',ProductCode ='97796'));
        listProduct.add(new Product2(Name = 'Mouse',Family = 'Hardware',ProductCode ='97795'));
        insert listProduct;
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(), Product2Id = listProduct[0].Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Catalog Price Book', isActive=true);
        insert customPB;
         PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = listProduct[0].Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        Account objAccount=new Account(Name='awana',Mailing_Address_Book__c='awsed123');
        insert objAccount;
        Contact objContact=new Contact(LastName='Vikas');
        insert objContact;
        npe5__Affiliation__c objAffiliation=new npe5__Affiliation__c(Authorized_Purchaser__c=true,npe5__Organization__c=objAccount.Id,npe5__Contact__c=objContact.Id);
        insert objAffiliation;
        GetDeptFulfillmentOrders.handler(listAdderess,listProduct,'awsed123','projectType','awana@gmail.com');
        system.assertequals('awsed123',objAccount.Mailing_Address_Book__c);
    }
}