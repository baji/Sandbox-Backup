global class AddressControllerExtension {

    public AddressControllerExtension(ApexPages.StandardController controller) {

    }
    
    @RemoteAction
    global static void insertAddressEDQCustomSetting(String recordId,String sessionID)
    {
       System.debug('Line no 10 in AddressControllerExtension ');
        
        AddressEDQPageLoad__c obj = new AddressEDQPageLoad__c(Name = recordId,Value__c=sessionID);
        insert obj;
    }
    
    @RemoteAction
    webservice static void deleteAddressEDQCustomSetting(String recordId)
    {
       System.debug('Line no 10 in AddressControllerExtension ');
        
       AddressEDQPageLoad__c obj = AddressEDQPageLoad__c.getInstance(recordId);
       delete obj;
    }
    
    @RemoteAction
    global  static boolean getAddressEDQCustomSetting(String recordId,String sessionID)
    {
        System.debug('Line no 17 in AddressControllerExtension '+sessionID);
        AddressEDQPageLoad__c obj = AddressEDQPageLoad__c.getInstance(recordId);
        system.debug('obj--'+obj);
        if(obj != null)
        {
          System.debug('Line no 26 '+obj.Value__c);
          /*if(obj.Value__c == sessionID)
           return 2;
           else
           {
               obj.Value__c = sessionID;
               update obj;
               return 3;
           }*/
           return true;
        }
        
         System.debug('Line no 37 '+obj);
        return false;
    }
     
    
}