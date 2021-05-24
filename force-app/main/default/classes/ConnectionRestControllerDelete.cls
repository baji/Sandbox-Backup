@RestResource(urlMapping='/DeleteConnection/*')
global class ConnectionRestControllerDelete{
    
    @HttpPost
    global static String deleteConnection(String affiliationId){
        try{            
            npe5__Affiliation__c affiliationDelete;
            if(affiliationId != null){
               affiliationDelete = [select ID,Awana_Role__c,Church_Role__c,npe5__Contact__r.Name,npe5__Organization__r.Name,Other_Role__c,npe5__Status__c  From npe5__Affiliation__c where ID=:affiliationId];            
               
               affiliationDelete.npe5__Status__c = 'Former'; 
               
               update affiliationDelete;
            }
            return 'success';
        }//try
         catch(Exception e){
              return String.valueOf(e);
          }      
    }//deleteConnection
}//class