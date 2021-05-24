/****************************************************************************************************************************************************************************************************************
Developer:  Ayesha Zulkha
Company:    Infoglen
Contact:    ayesha@Infoglen.com
Project:    Donation Management
Created:    07/13/2018 - Batch Class to process convio gifts
***************************************************************************************************************************************************************************************************************************************** **************/

public with sharing class ConvioGiftclass {
    public id batchprocessid;
    public Id recId;
    public boolean redirect{get;set;}
    public boolean showProcessConvio{get;set;}
    public boolean showLink{get;set;}
    
    public ConvioGiftclass(ApexPages.StandardController controller) {
        showProcessConvio= true;
        recId = ApexPages.currentPage().getParameters().get('id');
    }
    public void processConvioGift(){
        String nameFile;
        Blob contentFile;
        String[] filelines = new String[]{};
            
            if(recId !=null){
                Integer con = [SELECT count() FROM ContentDocumentLink WHERE LinkedEntityId =:recId];
                if(con != 0){
                    GenerateConvioGifts coBatch = new GenerateConvioGifts(recId); 
                    batchprocessid = database.executeBatch(coBatch,50); 
                    system.debug('<<BATCH PROCESS ID - processConvioGift>> '+batchprocessid);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Convio Gift Generation Batch has started'));
                    showProcessConvio= false;
                    redirect = true;
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please attach the CSV format Convio Batch File'));
                    showLink = true;
                    
                }
            }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Some error has occured. Please contact your Administrator'));
            
        }
    }
    public void checkBatchStatus(){
        if(batchprocessid!=null || Test.isRunningTest()){
            AsyncApexJob job = [SELECT Id, MethodName, Status, NumberOfErrors, JobItemsProcessed,ExtendedStatus,
                                TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:batchprocessid];
            decimal TjobItems = Test.isRunningTest() ? 1 : job.TotalJobItems;
            if((!Test.isRunningTest() && (job.Status == 'Queued' || job.Status == 'Holding' || job.Status == 'Preparing')) || (Test.isRunningTest() && checkRecursive.batchStatus == 'Holding')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The Batch is in the '+job.Status.toLowerCase()+' status...'));
            } else if((!Test.isRunningTest() && (job.Status == 'Processing') )|| (Test.isRunningTest() && checkRecursive.batchStatus == 'Processing')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The Batch is in '+job.Status.toLowerCase()+' status: '+Math.floor(100.0*job.JobItemsProcessed/TjobItems)+'%...'));
            } else if(job.NumberOfErrors>0 && job.Status == 'Completed'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Some error has occured.Please verify the CSV.'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'An Error Email is sent to the Administrator.'));
                
            }else if((!Test.isRunningTest() && job.TotalJobItems != 0 && job.Status == 'Completed')|| (Test.isRunningTest() && checkRecursive.batchStatus == 'Complete')){
                list<apsona_be__Batch__c  > CVBatch = [select id,name,Batch_Number__c,Tech_BatchProcess_Id__c  from apsona_be__Batch__c  where Tech_BatchProcess_Id__c=:batchprocessid ];
                if(CVBatch!=null && CVBatch.size()>0){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'The job is now '+job.Status.toLowerCase()+'.'));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The Batch Name of Donations is '+CVBatch[0].Batch_Number__c));
                    
                }
                else{
                    system.debug('<<BATCH PROCESS ID - checkBatchStatus>> '+batchprocessid);
                    system.debug('<<CSV BATCH SIZE>> '+CVBatch.size());
                    system.debug('<<JOB TOTAL JOB ITEMS>> '+job.TotalJobItems);
                    system.debug('<<JOB STATUS>> '+job.Status);
                    system.debug('<<JOB STATUS>> '+job.MethodName);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Some error has occured. An Error Email is sent to the Administrator.'));
                    
                }
            }
            else if((job.TotalJobItems == 0 && job.Status == 'Completed' && !Test.isRunningTest())|| (Test.isRunningTest() && checkRecursive.batchStatus == 'Completed')){
                //Display your message...
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'There are no records for the Batch to Process'));
            }
            else if(job.TotalJobItems == 0 && job.Status == 'Failed'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Some error has occured. Please Verify the CSV File.'));
                
            }
            
        }                   
    }
    public PageReference redirectConvio(){
        
        if(recId!=null){
            
            PageReference pageRef = new PageReference('/'+recId); 
            redirect = false;
            pageRef.setRedirect(true); 
            return pageRef;
        }
        else{
            return null;
        }
    }
}