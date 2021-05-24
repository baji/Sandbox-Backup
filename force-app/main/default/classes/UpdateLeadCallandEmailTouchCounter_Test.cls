@IsTest(SeeAllData=true)

private class UpdateLeadCallandEmailTouchCounter_Test {
   
    testmethod static void CallandEmailCounter(){
        Lead ld = new Lead();
        ld.FirstName = 'Test';
        ld.LastName = 'Lead';
        ld.Company = 'Test Company';
        ld.Stages__c = 'New Lead';
        ld.Status = 'Completed';
        Insert ld;
        
        List<Awana_Settings__c> aList = [SELECT id,name,value__c from Awana_Settings__c where name='ExecuteTaskTrigger'];
        if(!aList.isEmpty()){
            if(Boolean.valueof(aList[0].value__c)==false){
                aList[0].value__c='true';
                update aList;
                System.debug('after update custom setting : '+[SELECT id,name,value__c from Awana_Settings__c where name='ExecuteTaskTrigger']);
            }
        }
        Task ts = new Task();
        ts.Subject = 'Call Test';
        ts.WhoId = ld.id;
        ts.Priority = 'Normal';
        ts.Status = 'Completed';
        Insert ts;
        
        Task ts1 = new Task();
        ts1.Subject = 'Email Test';
        ts1.WhoId = ld.id;
        ts1.Priority = 'Normal';
        ts1.Status = 'Completed';
        Insert ts1;
        
        Delete ts1;
    }
}