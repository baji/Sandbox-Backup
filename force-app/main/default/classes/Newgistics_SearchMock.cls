/*****************************************************************************************************************************************************
    Programmer:     Tony Williams
    Company:        Awana
    Contact:        tonyw@awana.org
    Project:        Newgistics
    Description:    Http Mock class with methods Called by  orders to Newgsitics web services from  Testing NG Search Shipment Response records.
	Called By: 		BatchSearchNewgisticsShipmentsTest
    Original:       12/14/2018 - <NEW-25> - Called by  orders to Newgsitics web services from  Testing NG Search Shipment Response records.
        -- Execute Batch -- 
    BatchPostShipmentsToNewgisticsSchedule job = new BatchPostShipmentsToNewgisticsSchedule(); ID batchprocessid = Database.executeBatch(job, 1); 
 ********************************************************************************************************************************************************/
@isTest
public class Newgistics_SearchMock implements HttpCalloutMock {
   Boolean  isMockResponseSuccessful;  // set by constructor, used to vary the mockresponse
    //constructor
    public Newgistics_SearchMock(Boolean isMockResponseSuccessful){
        this.isMockResponseSuccessful  = isMockResponseSuccessful;
    }
    public HttpResponse respond(HttpRequest rqst) {
            
        HttpResponse fakeResponse = new HttpResponse();
        if (this.isMockResponseSuccessful) {
            fakeResponse.setHeader('Content-Type', 'application/xml');
           //fakeResponse.setBody('<Shipments><Shipment id="102649539"><ClientName>Newgistics Fulfillment</ClientName><OrderID>01061713</OrderID> <PurchaseOrder></PurchaseOrder> <Name>JOHN DOE</Name> <FirstName>JOHN</FirstName> <LastName>DOE</LastName> <Company></Company> <Address1>2100 E 26TH AVE #100</Address1> <Address2></Address2> <City>AURORA</City><State>CO</State> <PostalCode>80019</PostalCode> <Country>US</Country> <Email>JohnDoe@johndoe.com</Email> <Phone></Phone> <OrderTimestamp>2017-02-08T00:00:00</OrderTimestamp> <ReceivedTimestamp>2017-02-08T16:47:18.59</ReceivedTimestamp> <ShipmentStatus>SHIPPED</ShipmentStatus> <OrderType>Consumer</OrderType> <ShippedDate>2017-02-09T11:52:52</ShippedDate> <ExpectedDeliveryDate>2017-02-12</ExpectedDeliveryDate> <DeliveredTimestamp>2017-02-12T13:47:00</DeliveredTimestamp> <DeliveryException> <Timestamp></Timestamp> <Notes></Notes> </DeliveryException> <Warehouse id="157"> <Name>Reno, NV</Name> <Address>38 Isidor Ct.Suite 130</Address> <City>Sparks</City> <State>NV</State> <PostalCode>89441</PostalCode> <Country>US</Country> </Warehouse> <ShipMethod>USPS Priority Mail</ShipMethod> <ShipMethodCode>POM1M</ShipMethodCode> <Tracking>900005213900000000000</Tracking> <TrackingUrl>http://trkcnfrm1.smi.usps.com/PTSInternetWeb/ InterLabelInquiry.do?origTrackNum=900005213900000000000</TrackingUrl> <Weight>1</Weight> <Postage>4.80</Postage> <GiftWrap>false</GiftWrap> <CustomFields> <AdditionalImportFiles>30336700</AdditionalImportFiles> </CustomFields> <Fees> <Fee> <Type>PICKPACK</Type> <Amount>123.68</Amount> <Notes></Notes> </Fee> <Fee> <Type>PACKAGING</Type> <Amount>3.725</Amount> <Notes></Notes> </Fee> <Fee> <Type>POSTAGE</Type> <Amount>6.123</Amount> <Notes></Notes> </Fee> <Fee> <Type>RETURN</Type> <Amount>3.4</Amount> <Notes></Notes> </Fee> <Fee> <Type>WAREHOUSELABOR</Type> <Amount>36.9000</Amount> <Notes></Notes> </Fee> </Fees> <BackorderedItems>' );                        
             fakeResponse.setBody('<Shipments><Shipment id="102649539"><ClientName>Newgistics Fulfillment</ClientName><OrderID>01999999</OrderID> <PurchaseOrder></PurchaseOrder> <Name>JOHN DOE</Name> <FirstName>JOHN</FirstName> <LastName>DOE</LastName> <Company></Company> <Address1>2100 E 26TH AVE #100</Address1> <Address2></Address2> <City>AURORA</City><State>CO</State> <PostalCode>80019</PostalCode> <Country>US</Country> <Email>JohnDoe@johndoe.com</Email> <Phone></Phone> <OrderTimestamp>2017-02-08T00:00:00</OrderTimestamp> <ReceivedTimestamp>2017-02-08T16:47:18.59</ReceivedTimestamp> <ShipmentStatus>SHIPPED</ShipmentStatus> <OrderType>Consumer</OrderType> <ShippedDate>2017-02-09T11:52:52</ShippedDate> <ExpectedDeliveryDate>2017-02-12</ExpectedDeliveryDate> <DeliveredTimestamp>2017-02-12T13:47:00</DeliveredTimestamp> <DeliveryException> <Timestamp></Timestamp> <Notes></Notes> </DeliveryException> <Warehouse id="157"> <Name>Reno, NV</Name> <Address>38 Isidor Ct.Suite 130</Address> <City>Sparks</City> <State>NV</State> <PostalCode>89441</PostalCode> <Country>US</Country> </Warehouse> <ShipMethod>USPS Priority Mail</ShipMethod> <ShipMethodCode>POM1M</ShipMethodCode> <Tracking>900005213900000000000</Tracking> <TrackingUrl>http://trkcnfrm1.smi.usps.com/PTSInternetWeb/ InterLabelInquiry.do?origTrackNum=900005213900000000000</TrackingUrl> <Weight>1</Weight> <Postage>4.80</Postage> <GiftWrap>false</GiftWrap> <CustomFields> <AdditionalImportFiles>30336700</AdditionalImportFiles> </CustomFields> <Fees> <Fee> <Type>PICKPACK</Type> <Amount>123.68</Amount> <Notes></Notes> </Fee> <Fee> <Type>PACKAGING</Type> <Amount>3.725</Amount> <Notes></Notes> </Fee> <Fee> <Type>POSTAGE</Type> <Amount>6.123</Amount> <Notes></Notes> </Fee> <Fee> <Type>RETURN</Type> <Amount>3.4</Amount> <Notes></Notes> </Fee> <Fee> <Type>WAREHOUSELABOR</Type> <Amount>36.9000</Amount> <Notes></Notes> </Fee> </Fees> <BackorderedItems>' );                        
            fakeResponse.setStatusCode(200);
        }
        else {
            fakeResponse.setStatusCode(400);
            fakeResponse.setStatus('Bad request');
        }
        return fakeResponse;
    }
}