public class ReportViewController {
    List<dsfs__DocuSign_Recipient_Status__c> docusignList {get;set;}
    
    public ReportViewController(ApexPages.StandardSetController controller) {
        
        docusignList = (List<dsfs__DocuSign_Recipient_Status__c>)controller.getSelected();
        
    }
    
    public Pagereference redirectToReport(){

            String reportFilter;
            List<String> emailList = new List<String>();
            if(!docusignList.isEmpty()){
                for(dsfs__DocuSign_Recipient_Status__c obj : [SELECT Id,dsfs__DocuSign_Recipient_Email__c 
                                                              FROM dsfs__DocuSign_Recipient_Status__c
                                                              WHERE Id IN: docusignList])
                {
                    if(String.isNotEmpty(obj.dsfs__DocuSign_Recipient_Email__c)){
                        emailList.add(obj.dsfs__DocuSign_Recipient_Email__c);
                    }
                    
                }
                if(!emailList.isEmpty()){
                    reportFilter = String.join(emailList,',');
                }
                
                String url = '/00O7h000000huUk?pv0='+reportFilter;
                
                PageReference myVFPage = new PageReference(url);
                myVFPage.setRedirect(true);
                return myVFPage;
            }else{
                
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.Error,'Please select at least one record.'));
                
                
            } 
              
        return null;
        
    }  
    
     public Pagereference redirectToList(){
     
         return new ApexPages.Action('{!List}').invoke();
     }
    
    
}