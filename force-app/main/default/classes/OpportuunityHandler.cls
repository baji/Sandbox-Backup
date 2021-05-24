/************************************************************************************************************************************************************
    Programmer: Imran
    Company:    Awana
    Project:    Donation management
    Original:   2/16/2018  - Auto Number for Opportunity
    *************************************************************************************************************************************************************/
public class OpportuunityHandler{
    //This method creates auto number for gift id
    public static void giftId(List<Opportunity> newListOpp){
        Integer lastInsertRecord;
       List<opportunity> oppList = [SELECT Id FROM Opportunity Order By CreatedDate Desc LIMIT 1];
        if(oppList!= null && oppList.size()>0){
            //lastInsertRecord = 109871;
        }
        else{
            //lastInsertRecord = 109870;
        }               
        
    }
}