/*****************************************************************************
    Programmer:         Anvesh Kanneganti
    Company:            Awana
    Contact:            anveshk@awana.org
    Project:            Test Classes
    Original:           9/6/2020 - Used to test ShipmentAPI.cls
****************************************************************************************************/ 
@isTest(seeAllData=true)
public class ShipmentAPI_test {

    public static testmethod void testAPI1(){
        Test.startTest();
        Test.setCurrentPage(Page.ShipmentAPIPage);
        ApexPages.currentPage().getParameters().put('WbOrder','3312979');
        ShipmentAPI Ship = new ShipmentAPI();
        Test.setMock(HttpCalloutMock.class, new WB_SearchMock(true));
        ship.export();
        Test.stopTest();
    }  
}