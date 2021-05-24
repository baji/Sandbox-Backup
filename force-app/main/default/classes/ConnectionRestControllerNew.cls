@RestResource(urlMapping='/NewConnection/*')
global class ConnectionRestControllerNew{
    @HttpPost
    global static String insertConnection(String organizationId,String contactId,String awanaRole,String churchRole)
    {
         try{
             npe5__Affiliation__c affiliationInsert = new npe5__Affiliation__c();
            
                if(organizationId != null){                                 
                    affiliationInsert.npe5__Organization__c = organizationId;
                    if(contactId != null){
                    affiliationInsert.npe5__Contact__c = contactId;    
                    
                    if(awanaRole != null){
                    affiliationInsert.Awana_Role__c = awanaRole;
                    }       
                    if(churchRole != null){
                        affiliationInsert.Church_Role__c = churchRole;
                    }        
                                       
                      affiliationInsert.npe5__Status__c = 'Current';
                      affiliationInsert.npe5__StartDate__c = SYSTEM.TODAY();                   
                   
                }      
                insert affiliationInsert;       
            }                                              
             return 'SUCCESS';
          }//try
          catch(Exception e){
              return String.valueOf(e);
          }      
    }//insert connections
    
}//class