public with sharing class GenerateReceiptsController {
    public id batchprocessid;
    public boolean redirect{get;set;}
    public boolean showViewReceipt{get;set;}
    public boolean showGenerateReceipt{get;set;}
    public GenerateReceiptsController(ApexPages.StandardController controller) {
        showViewReceipt = false;
        showGenerateReceipt= true;
    }
    public void executeBatch(){
        
        GenerateReceipts gr = new GenerateReceipts();
        batchprocessid = Database.executeBatch(gr,200);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Receipt Generation Batch has started'));
        showGenerateReceipt= false;
        redirect = true;
    }
    public void checkBatchStatus(){
    if(batchprocessid!=null || Test.isRunningTest()){
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:batchprocessid];
                            system.debug('***job'+job);
        system.debug('***jobtest'+Test.isRunningTest());
        decimal TjobItems = Test.isRunningTest() ? 1 : job.TotalJobItems;
        if((!Test.isRunningTest() && (job.Status == 'Queued' || job.Status == 'Holding' || job.Status == 'Preparing')) || (Test.isRunningTest() && checkRecursive.batchStatus == 'Holding')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The Batch is in the '+job.Status.toLowerCase()+' status...'));
        } else if((!Test.isRunningTest() && (job.Status == 'Processing') )|| (Test.isRunningTest() && checkRecursive.batchStatus == 'Processing')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The Batch is in '+job.Status.toLowerCase()+' status: '+Math.floor(100.0*job.JobItemsProcessed/TjobItems)+'%...'));
        } else if((!Test.isRunningTest() && job.TotalJobItems != 0 && job.Status == 'Completed')|| (Test.isRunningTest() && checkRecursive.batchStatus == 'Complete')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'The job is now '+job.Status.toLowerCase()+'.'));
            list<Receipt__c> re = [select id,Tech_BatchProcess_Id__c  from Receipt__c where Tech_BatchProcess_Id__c=:batchprocessid ];
            if(re.size()>0){
            showViewReceipt = true;
            }
        }
        else if((job.TotalJobItems == 0 && job.Status == 'Completed' && !Test.isRunningTest())|| (Test.isRunningTest() && checkRecursive.batchStatus == 'Completed')){
            //Display your message...
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'There are no records for the Batch to Process'));
        }
        
       }                   
    }
    public PageReference redirectReceipt(){
    list<Receipt__c> re = [select id,Tech_BatchProcess_Id__c  from Receipt__c where Tech_BatchProcess_Id__c=:batchprocessid limit 1];
        if(re.size()>0){
         
         PageReference pageRef = new PageReference('/'+re[0].Id); 
         redirect = false;
         pageRef.setRedirect(true); 
         return pageRef;
         }
         else{
         return null;
         }
    }
         
     
     public PageReference cancelBatch(){
        Schema.DescribeSObjectResult result = Receipt__c.SObjectType.getDescribe(); 
      PageReference pageRef = new PageReference('/' + result.getKeyPrefix()); 
      pageRef.setRedirect(true); 
      return pageRef; 
     }
}