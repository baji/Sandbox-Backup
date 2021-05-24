/*****************************************************************************************************************************************************
    Programmer:     Tony Williams
    Company:        Awana
    Contact:        tonyw@awana.org
    Project:        Newgistics
    Description:    batch Apex Scheduler for sending orders to Newgsitics web services from SFDC.Gets shipment ID from the response.
    Original:       12/14/2018 - <NEW-29> - Scheduler for gettng orders from Newgsitics web services.
        -- Execute Batch -- 
    BatchPostShipmentsToNewgisticsSchedule job = new BatchPostShipmentsToNewgisticsSchedule(); ID batchprocessid = Database.executeBatch(job, 1); 
 ********************************************************************************************************************************************************/

@isTest(SeeAllData = True)
public class BatchSearchNewgisticsShipmentsTest {
    static testMethod void SearchShipments1_TestMethod (){
        //1. Create an order with no pick tickets for first test of stock OLIs
         // Set mock callout class 
        List<String> orderIds = new List<String>();
        Order Ord = TestObjects.FullOrder();
        Account a = TestObjects.NewGenericAccount();
        a.Name = 'AFF-Test';
        a.Registration_Number__c='123';
        a.Mailing_Address_Book__c='000123';
        insert a;
        Contact c = TestObjects.NewGenericContact();
        c.accountid = a.id;
        insert c;
        npe5__Affiliation__c aff = new npe5__Affiliation__c( npe5__Organization__c  = a.Id,npe5__Contact__c = c.Id);
        
        insert aff;
        // Create Order
        Id priceBookId = Test.getStandardPricebookId();
        Ord.AccountId  = a.Id;
        Ord.Pricebook2Id = pricebookId;
        Ord.ExtraEmail__c = 'someone@someone.com,test@test.com';
        // sETUP oRDER sOURCE
        system.debug('##ORDER'+Ord);
        insert Ord;
        insert new Order_Contact_Role__c(Contact__c = c.Id, Order__c = Ord.Id);
        // Add Shipping Firstname, Lastname and all else on the PostShipmentRequest class.
        Ord.Ship_to_First_Name__c = c.FirstName;
        Ord.Ship_to_Last_Name__c = c.LastName;
        Ord.Shipping_Street__c ='1415 Casa Dr';
        Ord.Shipping_City__c = 'Austin';
        Ord.Shipping_State__c = 'TX';
        Ord.Shipping_Zip_Code__c = '78745';
        Ord.Shipping_Country__c = 'United States';
        Ord.Billing_Email__c = 'someone@mailinator.com';
        update Ord;
        
        List<OrderItem> orderItems = new List<OrderItem>();
        //=-======================================================================
         List<PriceBookEntry> OrderPriceBookEntryList = TestObjects.NewPriceBookEntries();
       
        Ord.Pricebook2Id = OrderPriceBookEntryList[0].PriceBook2Id;
        Ord.Payment_Terms__c = 'Net 30';
        upsert Ord;
        
        List<PriceBookEntry> ProductsToAdd = [Select Product2.ProductCode From PriceBookEntry Where Product2.Name like 'Trek 4-Way Tug Rope%' Limit 1];
        List<PriceBookEntry> ProductsToAdd2 = [Select Product2.ProductCode From PriceBookEntry Where  Product2.Name like 'Classic Membership%' Limit 1];
       
      for(PricebookEntry Item : ProductsToAdd)
        {
            system.debug('***** PriceBookEntry ***** '+Item);
            OrderEntryServices.Result AddResult = OrderEntryServices.AddProduct(Ord.Id, Item.Product2.Id, 1, 5.95, 2.95,'Sales Promotion', 'S - Stock Inventory Item');
             
            system.debug('***** AddResult ***** '+AddResult);
        }
         for(PricebookEntry Item : ProductsToAdd2)
        {
            system.debug('***** PriceBookEntry ***** '+Item);
            OrderEntryServices.Result AddResult2 = OrderEntryServices.AddProduct(Ord.Id, Item.Product2.Id, 1, 5.95, 2.95,'Sales Promotion', 'N - Non-Stock');
            system.debug('***** AddResult ***** '+AddResult2);
        }  
        
        OrderEntryServices.GetOrderAmounts1(Ord.Id);
        
        orderItems= [Select Id,Quantity,UnitPrice From OrderItem Where OrderId = :Ord.Id];
        system.debug('<< QUERIED ORDER ITEMS >> '+orderItems);
        //Ord.OrderNumber = '01999999';
        //===================================================================================
        Ord.Status = 'Order Being Fulfilled';
        update Ord;
        BatchSearchNewgisticsShipments batchObjBSNS = new BatchSearchNewgisticsShipments();
        Newgistics_Settings__c custSettings = Newgistics_Settings__c.getValues('NewgsticsAPIFields');
        batchObjBSNS.custSettings= [SELECT id,End_Shipped_Time__c,Start_Shipped_Time__c,NG_API_Key__c,Added_Hours__c,NG_Endpoint__c,FRT_Code__c,TAX_Code__c from  Newgistics_Settings__c Limit 1];
        batchObjBSNS.custSettings.End_Shipped_Time__c  = String.valueOf(DateTime.now());
        batchObjBSNS.custSettings.Start_Shipped_Time__c = String.valueOf(DateTime.now().addHours(-2));
        //String query = 'SELECT Id FROM Order Limit 1';      
        //system.debug('<< QUERY  >> '+query);
        Set<String> NGShippedOrderNumbers = new Set<String>();
        List<Order> os = [select Id,OrderNumber from Order where Id =: null Limit 10];
         for(Order o: os){
             NGShippedOrderNumbers.add(o.OrderNumber);
         }
         String query 
              = 'SELECT Id, Shipping_Street__c,Shipping_City__c,Name,EffectiveDate,Shipping_Type__c,Shipping_Code__c,'
                +'Shipping_State__c,Shipping_Zip_Code__c,Shipping_Country__c,Shipping_Carrier__c,Company__c,Estimated_Weight__c,' 
                +'Ship_to_First_Name__c,Ship_to_Last_Name__c,Billing_Email__c,Tax__c,Shipment_Cost__c,Payment_Terms__c,'
                +'AccountId, Account.Name, OrderNumber, Status, TotalAmount, CreatedDate, CreatedById, CreatedBy.Name,'
                +'HasOrderLineItem__c, LastModifiedDate, LastModifiedById, LastModifiedBy.Name, TotalOrderQuantity__c,'
                +'Total_Pick_Quantity__c, Total_Pick_Tickets__c, Inventory_Items__c, Non_inventory_Items__c, Error_Log__c,'
                +'Order.NG_Shipment_ID__c, (Select Id, Name From Pick_Tickets__r) '
                +'FROM Order '
                +'where (Status = \'Order Being Fulfilled\' or Status like \'%Partially%\')'
                +' And (NOT Status like \'%Cancelled%\')'
                +' And OrderNumber IN: NGShippedOrderNumbers';
               
        system.debug('<< QUERY  >> '+query);
        
        Test.startTest();
        batchObjBSNS.query = query;
        Test.setMock(HttpCalloutMock.class, new Newgistics_SearchMock(true));
        HttpRequest req;
        Database.executeBatch(batchObjBSNS);
        BatchSearchNewgisticsShipments job = new BatchSearchNewgisticsShipments();
      
        Test.stopTest();
       
      
    }
  public static testMethod void SearchShipments2_TestMethod (){
        //2. Add open Pick Ticket and shipmen object for second test (New method) 
        BatchSearchNewgisticsShipments batchObjBSNS = new BatchSearchNewgisticsShipments();
         String query 
              = 'SELECT Id FROM Order Limit 1' ;
               
        system.debug('<< QUERY  >> '+query);
        Test.startTest();
        batchObjBSNS.query = query;
        Test.setMock(HttpCalloutMock.class, new Newgistics_SearchMock(true));
        Database.executeBatch(batchObjBSNS);
        BatchSearchNewgisticsShipments job = new BatchSearchNewgisticsShipments();
      
        Test.stopTest();
    }  
  public static testMethod String CreateSHipments_TestMethod(){
      Order Ord = [SELECT Id, Shipping_Street__c,Shipping_City__c,Name,EffectiveDate,Shipping_Type__c,Shipping_Code__c,
                Shipping_State__c,Shipping_Zip_Code__c,Shipping_Country__c,Shipping_Carrier__c,Company__c, 
                Ship_to_First_Name__c,Ship_to_Last_Name__c,Billing_Email__c,Shipment_Cost__c, 
                AccountId, Account.Name, OrderNumber,
                Status, TotalAmount, CreatedDate, CreatedById, CreatedBy.Name, HasOrderLineItem__c, LastModifiedDate, 
                LastModifiedById, LastModifiedBy.Name, TotalOrderQuantity__c, Total_Pick_Quantity__c, 
                Total_Pick_Tickets__c, Inventory_Items__c, Non_inventory_Items__c, Error_Log__c,Order.NG_Shipment_ID__c, 
                (Select Id, Name From Pick_Tickets__r)
                FROM Order WHERE (Status = 'Order Being Fulfilled' or Status like '%Partially%') 
                And (NOT Status like '%Cancelled%') LIMIT 1];
                   
        Xmlstreamwriter xmlW = new Xmlstreamwriter();
        xmlW.writeStartDocument('utf-8','1.0');
              xmlW.writeStartElement(null,'Shipments',null);
              xmlW.writeStartElement(null,'Shipment',null);
                xmlW.writeAttribute(null, null,'id','102649539');
                xmlW.writeStartElement(null,'ClientName',null);
                  xmlW.writeCharacters('Newgistics FulFillment');
                xmlW.writeEndElement();// ClientName
                xmlW.writeStartElement(null,'OrderID',null);
                    xmlW.writeCharacters(Ord.OrderNumber);
                xmlW.writeEndElement();//OrderID
                xmlW.writeStartElement(null,'PurchaseOrder',null);
                xmlW.writeEndElement();//PurchaseOrder
                xmlW.writeStartElement(null,'NAME',null);
                  xmlW.writeCharacters('JUSTINE AUGENSTERN');
                xmlW.writeEndElement();//NAME
                xmlW.writeStartElement(null,'FirstName',null);
                  xmlW.writeCharacters('JUSTINE');
                xmlW.writeEndElement();//FirstName
                xmlW.writeStartElement(null,'LastName',null);
                  xmlW.writeCharacters('AUGENSTERN');
                xmlW.writeEndElement();//LastName
                xmlW.writeStartElement(null,'Company',null);
                xmlW.writeEndElement();//Company
                xmlW.writeStartElement(null,'Address1',null);
                  xmlW.writeCharacters('34 MARINA DR');
                xmlW.writeEndElement();//Address1
                xmlW.writeStartElement(null,'Address2',null);
                xmlW.writeEndElement();//Address2
                xmlW.writeStartElement(null,'City',null);
                  xmlW.writeCharacters('HULL');
                xmlW.writeEndElement();//City
                xmlW.writeStartElement(null,'State',null);
                  xmlW.writeCharacters('MA');
                xmlW.writeEndElement();//State
                xmlW.writeStartElement(null,'PostalCode',null);
                  xmlW.writeCharacters('02045-1322');
                xmlW.writeEndElement();//PostalCode
                xmlW.writeStartElement(null,'Country',null);
                  xmlW.writeCharacters('UNITED STATES');
                xmlW.writeEndElement();//Country
                xmlW.writeStartElement(null,'Email',null);
                  xmlW.writeCharacters('justineaugie@mailinator.com');
                xmlW.writeEndElement();//Email
                xmlW.writeStartElement(null,'Phone',null);
                  xmlW.writeCharacters('(847)-568-2471');  
                xmlW.writeEndElement();//Phone
                xmlW.writeStartElement(null,'OrderTimestamp',null);
                  xmlW.writeCharacters('2019-01-03T00:00:00');
                xmlW.writeEndElement();//OrderTimestamp
                xmlW.writeStartElement(null,'ReceivedTimestamp',null);
                  xmlW.writeCharacters('2019-01-03T09:20:35.537');
                xmlW.writeEndElement();//ReceivedTimestamp
                xmlW.writeStartElement(null,'ShipmentStatus',null);
                  xmlW.writeCharacters('SHIPPED');
                xmlW.writeEndElement();//ShipmentStatus
                xmlW.writeStartElement(null,'OrderType',null);
                  xmlW.writeCharacters('Consumer<');
                xmlW.writeEndElement();//OrderType
                xmlW.writeStartElement(null,'ShippedDate',null);
                  xmlW.writeCharacters('2019-01-03T09:41:24.633');
                xmlW.writeEndElement();//ShippedDate
                xmlW.writeStartElement(null,'ExpectedDeliveryDate',null);
                  xmlW.writeCharacters('2019-01-08T00:00:00');
                xmlW.writeEndElement();//ExpectedDeliveryDate
                xmlW.writeStartElement(null,'DeliveredTimestamp',null);
                xmlW.writeEndElement();//DeliveredTimestamp
                xmlW.writeStartElement(null,'DeliveryException',null);
                    xmlW.writeStartElement(null,'Timestamp',null);
                    xmlW.writeEndElement();//Timestamp
                    xmlW.writeStartElement(null,'Notes',null);
                      xmlW.writeCharacters('No excpetion time needed.');
                    xmlW.writeEndElement();//Notes  
                xmlW.writeEndElement();//DeliveryException
                xmlW.writeStartElement(null,'Warehouse',null);
                    xmlW.writeAttribute(null, null,'id','160');
                    xmlW.writeStartElement(null,'Name',null);
                      xmlW.writeCharacters('Greenwood, IN');
                    xmlW.writeEndElement();//Name
                    xmlW.writeStartElement(null,'Address',null);
                      xmlW.writeCharacters('1415 Collins Rd');
                    xmlW.writeEndElement();//Address
                    xmlW.writeStartElement(null,'City',null);
                      xmlW.writeCharacters('Greenwood');
                    xmlW.writeEndElement();//City  
                    xmlW.writeStartElement(null,'State',null);
                      xmlW.writeCharacters('IN');
                    xmlW.writeEndElement();//State  
                    xmlW.writeStartElement(null,'PostalCode',null);
                      xmlW.writeCharacters('46143');
                    xmlW.writeEndElement();//PostalCode  
                    xmlW.writeStartElement(null,'Country',null);
                      xmlW.writeCharacters('US');
                    xmlW.writeEndElement();//Country  
                xmlW.writeEndElement();// Warehouse
                  xmlW.writeStartElement(null,'ShipMethod',null);
                      xmlW.writeCharacters('USPS Priority Mail');
                  xmlW.writeEndElement();//ShipMethod
                  xmlW.writeStartElement(null,'ShipMethodCode',null);
                      xmlW.writeCharacters('PBUPM');
                  xmlW.writeEndElement();//ShipMethodCode
                  xmlW.writeStartElement(null,'Tracking',null);
                      xmlW.writeCharacters('900005213900000000000');
                  xmlW.writeEndElement();//Tracking
                  xmlW.writeStartElement(null,'TrackingUrl',null);
                      xmlW.writeCharacters('TrackingUrl>http://trkcnfrm1.smi.usps.com/PTSInternetWeb/ InterLabelInquiry.do?origTrackNum=900005213900000000000');
                  xmlW.writeEndElement();//TrackingUrl
                  xmlW.writeStartElement(null,'Weight',null);
                      xmlW.writeCharacters('3.000000');
                  xmlW.writeEndElement();//Weight
                  xmlW.writeStartElement(null,'Postage',null);
                  xmlW.writeEndElement();//Postage
                  xmlW.writeStartElement(null,'GiftWrap',null);
                      xmlW.writeCharacters('false');
                  xmlW.writeEndElement();//GiftWrap
                  xmlW.writeStartElement(null,'CustomFields',null);
                    xmlW.writeStartElement(null,'BillingAddress1',null);
                      xmlW.writeCharacters('34 Marina D');
                    xmlW.writeEndElement();//BillingAddress1
                    xmlW.writeStartElement(null,'BillingCity',null);
                      xmlW.writeCharacters('Hull');
                    xmlW.writeEndElement();//BillingCity
                    xmlW.writeStartElement(null,'BillingCompany',null);
                      xmlW.writeCharacters('Marina Reformed Church');
                    xmlW.writeEndElement();//BillingCompany
                    xmlW.writeStartElement(null,'BillingCountry',null);
                      xmlW.writeCharacters('UNITED STATES');
                    xmlW.writeEndElement();//BillingCountry
                    xmlW.writeStartElement(null,'BillingEmail',null);
                      xmlW.writeCharacters('justineaugie@mailinator.com');
                    xmlW.writeEndElement();//BillingEmail
                    xmlW.writeStartElement(null,'BillingFirstName',null);
                      xmlW.writeCharacters('Justin');
                    xmlW.writeEndElement();//BillingFirstName
                    xmlW.writeStartElement(null,'BillingLastName',null);
                      xmlW.writeCharacters('Augenstern');
                    xmlW.writeEndElement();//BillingLastName
                    xmlW.writeStartElement(null,'BillingState',null);
                      xmlW.writeCharacters('MA');
                    xmlW.writeEndElement();//BillingState
                    xmlW.writeStartElement(null,'BillingZip',null);
                      xmlW.writeCharacters('02045');
                    xmlW.writeEndElement();//BillingZip
                    xmlW.writeStartElement(null,'SalesTax',null);
                      xmlW.writeCharacters('2.57');
                    xmlW.writeEndElement();//SalesTax
                    xmlW.writeStartElement(null,'Total',null);
                      xmlW.writeCharacters('22.12');
                    xmlW.writeEndElement();//Total
                  xmlW.writeEndElement();//CustomFields
                  xmlW.writeStartElement(null,'BackorderedItems',null);
                  xmlW.writeEndElement();//BackorderedItems
                  xmlW.writeStartElement(null,'Items',null);
                    xmlW.writeStartElement(null,'Item',null);
                      xmlW.writeAttribute(null, null,'id','1807578');
                      xmlW.writeStartElement(null,'SKU',null);
                        xmlW.writeCharacters('94892');
                      xmlW.writeEndElement();//SKU
                      xmlW.writeStartElement(null,'UPC',null);
                      xmlW.writeEndElement();//UPC
                      xmlW.writeStartElement(null,'Description',null);
                        xmlW.writeCharacters('Cubbies AppleSeed Handbook Music CD NKJV');
                      xmlW.writeEndElement();//Description
                      xmlW.writeStartElement(null,'Lot',null);
                      xmlW.writeEndElement();//Lot
                      xmlW.writeStartElement(null,'Qty',null);
                        xmlW.writeCharacters('2');
                      xmlW.writeEndElement();//Qty
                    xmlW.writeEndElement();//Item
                  xmlW.writeEndElement();//Items
        
                  xmlW.writeStartElement(null,'Packages',null);
                    xmlW.writeStartElement(null,'Package',null);
                      xmlW.writeAttribute(null, null,'id','86486642');
                      xmlW.writeStartElement(null,'TrackingNumber',null);
                        xmlW.writeCharacters('1Z59663F0307896537<');
                      xmlW.writeEndElement();//TrackingNumber
                      xmlW.writeStartElement(null,'Weight',null);
                        xmlW.writeCharacters('2.63093');
                      xmlW.writeEndElement();//Weight
                      xmlW.writeStartElement(null,'BillableWeight',null);
                        xmlW.writeCharacters('3.00000');
                      xmlW.writeEndElement();//BillableWeight
                      xmlW.writeStartElement(null,'Height',null);
                        xmlW.writeCharacters('4.00000');
                      xmlW.writeEndElement();//Height
                      xmlW.writeStartElement(null,'Width',null);
                        xmlW.writeCharacters('6.00000');
                      xmlW.writeEndElement();//Width
                      xmlW.writeStartElement(null,'Width',null);
                        xmlW.writeCharacters('1.00000');
                      xmlW.writeEndElement();//Width
                      xmlW.writeStartElement(null,'Depth',null);
                        xmlW.writeCharacters('10.00000');
                      xmlW.writeEndElement();//Depth
                      xmlW.writeStartElement(null,'Items',null);
                        xmlW.writeStartElement(null,'Item',null);
                          xmlW.writeAttribute(null, null,'id','1807578');  
                          xmlW.writeStartElement(null,'SKU',null);
                            xmlW.writeCharacters('94892');
                          xmlW.writeEndElement();//SKU
                          xmlW.writeStartElement(null,'Qty',null);
                          xmlW.writeEndElement();//Qty
                        xmlW.writeEndElement();//Item  
                      xmlW.writeEndElement();//Items
                    xmlW.writeEndElement();//Package
                  xmlW.writeEndElement();//Packages
              xmlW.writeEndElement();// Shipment
            xmlW.writeEndElement(); //Shipments
        xmlW.writeEndDocument(); //Close XML document
        // Run the order Items list in a loop  and include the xmlW info in a loop 
        String xmlStringxmlResult = xmlW.getXmlString(); 
        xmlW.close();
        SearchShipmentRequest sr = new SearchShipmentRequest(xmlStringxmlResult);
        Test.setMock(HttpCalloutMock.class, new Newgistics_SearchMock(true));
        return xmlStringxmlResult;  
    }
}