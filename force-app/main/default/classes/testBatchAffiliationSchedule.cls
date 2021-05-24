/*****************************************
    Programmer:   Ayesha Zulkha
    Company:      Awana
    Contact:      ayesha@infoglen.com
    Project:       Mozo Free Trail
    Description:  test class batch Apex Scheduler to push Affiliation to Demandware.
    Original:     12/28/2017
        -- Execute Batch -- 
     
 *****************************************/
@istest
public class testBatchAffiliationSchedule{
public static testmethod void first1(){
        Test.startTest();
            BatchAffiliationSchedule j = new  BatchAffiliationSchedule();
            String sch = '0 50 15 30 6 ? *';
            String jobID = system.schedule('BatchAffiliationSchedule', sch, j);
        Test.stopTest();
    }  
}