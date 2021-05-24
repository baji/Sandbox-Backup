/************************************************************************************************************************************************************
Programmer: Imran
Company:    Awana
Project:    Donation management
Original:   2/16/2018  - Auto Number for Opportunity
*************************************************************************************************************************************************************/
public class OpportunityHandler{
    //This method creates auto number for gift id
    static Integer serialNo;
    public static void giftId(List<Opportunity> newListOpp){
        Map<String, GiftIdSeries__c> GiftSeries= GiftIdSeries__c.getAll();
        GiftIdSeries__c gtSeries = GiftSeries.get('GiftIdStartNumber');
        serialNo =  Integer.valueof(gtSeries.GiftIdSeriesNo__c);
        for(Opportunity obj : newListOpp){
            }
        
    }
    // This method updates the custom setting value in Gift Id Series
    public static void giftIdSeriesUpdate(List<Opportunity> newListOpp){
        Integer GiftSerialNo;
        Map<String, GiftIdSeries__c> GiftSeries= GiftIdSeries__c.getAll();
        GiftIdSeries__c gtSeries = GiftSeries.get('GiftIdStartNumber');
        GiftSerialNo =  Integer.valueof(gtSeries.GiftIdSeriesNo__c)+newListOpp.size();
        gtSeries.GiftIdSeriesNo__c = GiftSerialNo;
        /*try{
        Update gtSeries;
        }
        catch(exception e){
        }*/
     }
    
}