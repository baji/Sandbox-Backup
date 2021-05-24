/************************************************************************************************************************************************************
    Programmer: Ayesha Zulkha
    Company:    Awana
    Project:    Donation management
    Original:   4/11/2018  - Create Constituent Id on Contact
    *************************************************************************************************************************************************************/
    public class CreateContactConstitId{
        static Integer serialNo;
        public static void contactUpdate(List<Opportunity> opptyIdList){
        list<contact> conList = new list<contact>();
        Map<String, ConstitIdSeries__c> ConstitSeries= ConstitIdSeries__c.getAll();
        
        set<Id> conSet = new set<Id>();
            for(opportunity opt:opptyIdList){
                if(opt.npsp__Primary_Contact__c!=null){
                    conSet.add(opt.npsp__Primary_Contact__c);
                }
            }
             ConstitIdSeries__c ctSeries = ConstitSeries.get('ConstitIdStartNumber');
             serialNo =  Integer.valueof(ctSeries.ConstitSeriesNo__c);
            for(contact con:[select id,Constituent_Id__c from contact where id in:conSet]){
                if(con.Constituent_Id__c==null){
                     serialNo = serialNo +1;
                     con.Constituent_Id__c = String.valueOf(serialNo);
                     conList .add(con);
                }
            }
            ctSeries.ConstitSeriesNo__c = serialNo ;
            try{
                Update ctSeries;
            }
            catch(exception e){
            }
            if(conList !=null && conList .size()>0){
                    try{
                           Database.update(conList,false);
                       }
                       catch(exception e){
                       }
            }
           }
    }