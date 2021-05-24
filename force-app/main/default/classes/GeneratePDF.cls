public class GeneratePDF {

    public String ContactID {
        get{
            if(ContactID == null && 
            ApexPages.currentPage().getParameters().get('contactId') != null){
                ContactID = ApexPages.currentPage().getParameters().get('contactId');
            }
            return ContactID;
        }
        set;
    }

    public String ContactName {
        get{
            return [SELECT Account.Name  FROM Contact WHERE ID = :ContactID LIMIT 1].Account.Name ;
        }
        set;
    }
    public String CustomerId {
        get{
            return [SELECT Account.Mailing_Address_Book__c  FROM Contact WHERE ID = :ContactID LIMIT 1].Account.Mailing_Address_Book__c ;
        }
        set;
    }
    
}