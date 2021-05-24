public class ConstituentIDContactNew {
    static Integer serialNo = 0;
    public static void contactInsert(List<Contact> contactList){
        list<contact> conList = new list<contact>();
        Map<String, ConstitIdSeries__c> ConstitSeries= ConstitIdSeries__c.getAll();
        
        ConstitIdSeries__c ctSeries = ConstitSeries.get('ConstitIdStartNumber');
        serialNo =  Integer.valueof(ctSeries.ConstitSeriesNo__c);
        system.debug('*******Old Constituent no*******'+serialNo);
        for(contact con: contactList){
                serialNo = serialNo +1;
                con.Constituent_Id__c = String.valueOf(serialNo);
                conList .add(con);
        }
        ctSeries.ConstitSeriesNo__c = serialNo ;
        system.debug('*******new Constituent no*******'+serialNo);
        try{
            Update ctSeries;
        }
        catch(exception e){
        }   
    }
}