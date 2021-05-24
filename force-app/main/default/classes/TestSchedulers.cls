/*****************************************************************************
    Programmer:         Tony WIlliams
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            Test Classes
    Original:           2/19/2015 - Used to test Schedulers for all Batch classes for code coverage.
****************************************************************************************************/ 
@isTest(seeAllData=true)
public class TestSchedulers {
    
    public static testmethod void testBatchUpdateRegistrationScheduler(){
        BatchUpdateRegistrationOnSchedule buros= new BatchUpdateRegistrationOnSchedule();
        String sch = '0 0 1 * * ? ';
        String jobID = system.schedule('Registration Update  Job', sch, buros);
        
    }  
    
    //Need to create CronExpression to set class scheduling time
    static String cronExpression = '0 5 1 * * ? ';

    public static testmethod void testBatchEndMozoFreeTrialSchedule(){
        //Below is the Class which implements schedulable interface(already batch apex will be called in the schedulable class )
        BatchEndMozoFreeTrialSchedule bgu = new BatchEndMozoFreeTrialSchedule();

        //And than we need to pass the JOB name , CRON expression and schedulabel instance.
        String jobID = system.schedule('MozoEndBatchJob',cronExpression,bgu);
        
        cronExpression = '0 10 1 * * ?';
        //Below is the Class which implements schedulable interface(already batch apex will be called in the schedulable class )
        BatchAffiliationSchedule bgu1 = new BatchAffiliationSchedule();
        
        //And than we need to pass the JOB name , CRON expression and schedulabel instance.
        jobID = system.schedule('AffiliationUpdateJob',cronExpression,bgu1);
          
         cronExpression = '0 15 1 * * ? ';
         BatchGOLevelToFormerSchedule bgtfs = new BatchGOLevelToFormerSchedule();
          //And than we need to pass the JOB name , CRON expression and schedulabel instance.
        jobID = system.schedule('GOLevelToFormer',cronExpression,bgtfs);
        
        cronExpression = '0 45 1 * * ? ';
        BatchDeleteStuckWooOrdersScheduler j = new  BatchDeleteStuckWooOrdersScheduler();
        jobID = system.schedule('Remove WOO Orders', cronExpression, j);    
        
        cronExpression = '0 50 1 * * ? ';
        BatchDowngradeToM0Scheduler dtm0 = new BatchDowngradeToM0Scheduler(); 
        jobID = system.schedule('Downgrade To M0', cronExpression, dtm0);
        
        cronExpression = '0 55 1 * * ? ';
        BatchSearchNewgisticsShipmentsScheduler snss = new BatchSearchNewgisticsShipmentsScheduler(); 
        jobID = system.schedule('Search NG Shipments', cronExpression, snss);
        
        cronExpression = '0 57 1 * * ? ';
            BatchEmergencyTimeSweepScheduler betws = new BatchEmergencyTimeSweepScheduler(); 
        jobID = system.schedule('Emergency Search NG Shipments', cronExpression, betws);   
        
        cronExpression = '0 10 2 * * ? ';
        BatchSearchWBShipmentsScheduler snsswb = new BatchSearchWBShipmentsScheduler(); 
        jobID = system.schedule('Search WB Shipments', cronExpression, snsswb);
        
        cronExpression = '0 15 2 * * ? ';
        BatchProductQuantityReservedScheduler bpqrj = new BatchProductQuantityReservedScheduler(); 
        jobID = system.schedule('Reset Quantity Reserved Job', cronExpression, bpqrj);

    }

    public static testmethod void testBriteBatches(){

        cronExpression = '0 05 0 * * ? ';
        BatchBriteExpirations br = new BatchBriteExpirations(); 
        List<Digital_Curriculum_Expiration__c> DCD = new List<Digital_Curriculum_Expiration__c>();
        DCD.add(new Digital_Curriculum_Expiration__c(Curriculum_Expiration_Status__c='Active',Curriculum_Expiration_Date__c=Date.today().addDays(-5),brite_Product__c='brite-test',Product_Code__c='70000',Subscription_Period__c='Annual'));
        insert DCD;
        String jobID = system.schedule('Batch brite', cronExpression, br);

        cronExpression = '0 30 0 * * ? ';
        BatchBriteTaxExemptions brtx = new BatchBriteTaxExemptions(); 
        Account acc = new Account(name='Test Account',Sales_Tax_Exemption_Hold_Expiration_Date__c=date.today().addDays(-2),Sales_Tax_Exemption_Hold__c=true);
        insert acc;
        Order o1 = new Order(name='O-123-0',Status='Order on Hold', effectiveDate=Date.Today(), AccountId=acc.id, Has_Brite__c=true); 
        insert o1;
        jobID = system.schedule('Batch brite tax', cronExpression, brtx);
    }
}