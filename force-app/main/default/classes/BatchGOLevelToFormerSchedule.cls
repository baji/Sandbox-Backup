/*****************************************
    Programmer:   Tony Williams
    Company:      Awana
    Contact:      tonyw@awana.org
    Project:       Batch GO Level To Former
    Description:  batch Apex Scheduler to set all GO Levels on Account records  to Former on an annual basis
    Original:     1/19/2017
        -- Execute Batch --  
    For this code execute it annualy on June 30th in Dev Console of Production
    BatchGOLevelToFormerSchedule j = new  BatchGOLevelToFormerSchedule();
    String sch = '0 50 15 30 6 ? *';
    String jobID = system.schedule('Remove Level', sch, j);

 *****************************************/
global class BatchGOLevelToFormerSchedule  implements Schedulable{
    global void execute(SchedulableContext SC) {
       BatchGOLevelToFormerAccounts job = new BatchGOLevelToFormerAccounts();
       ID batchprocessid = Database.executeBatch(job, 10);
   }
}