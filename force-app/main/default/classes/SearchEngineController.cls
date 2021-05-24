public class SearchEngineController {
    
    @AuraEnabled
    public static List <Account> fetchAccount(String searchKeyWord) {
        String searchKey = searchKeyWord + '%';
        List <Account> returnList = new List <Account>();
        List <Account> lstOfAccount = [select id, Name, Mailing_Address_Book__c,Type, Phone from account
                                         where Name LIKE: searchKey LIMIT 500];
        
        for (Account acc: lstOfAccount) {
            returnList.add(acc);
        }
        return returnList;
    }
    
    @AuraEnabled
    public static List<Contact> fetchContact(String searchKeyWord) {
        String searchKey = searchKeyWord + '%';
        system.debug('searchKey==>'+searchKey);
        List <Contact> returnList = new List <Contact>();
        List <Contact> lstOfContact = [select id, FirstName,LastName,Email from Contact
                                         where Email LIKE: searchKey LIMIT 500];
        
        for (Contact con: lstOfContact) {
            returnList.add(con);
        }
        return returnList;
    }
}