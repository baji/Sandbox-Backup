@isTest
public class Test_S2SShipmentObjectUpdate{
    static testMethod void shipment(){
        Account fullAcc = Test_S2SObjects.S2S_FullAccount();
        Insert fullAcc;
        Order ord = Test_S2SObjects.S2S_FullOrder();
            ord.AccountId = fullAcc.Id;
            ord.Source_Opportunity_Id__c = '0015000001R4u9YAAR';
        Insert ord;
        
        Pick_Ticket__c pick1 = new Pick_Ticket__c();
            pick1.Order__c = ord.Id;
        Insert pick1;
        
        Pick_Ticket__c pick2 = new Pick_Ticket__c();
            pick2.Order__c = ord.Id;
            pick2.Source_Shipment_Rec_Id__c = pick1.Id;
        Insert pick2;
        
        S2SShipmentObjectUpdate ss = new S2SShipmentObjectUpdate();
        Database.ExecuteBatch(ss,10);
    }
}