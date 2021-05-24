/*****************************************************************************************************************************************************
    Programmer:     Tony Williams
    Company:        Awana
    Contact:        tonyw@awana.org
    Project:        Newgistics
    Description:    batch Apex Scheduler for sending orders to Newgsitics web services from SFDC.Gets shipment ID from the response.
    Original:       12/14/2018 - <NEW-25> - Scheduler for sending orders to Newgsitics web services from SFDC.Gets shipment ID from the response.
    Updated: 		01/31/2019 - <NEW-73> - Fixed Pick tickets from  being created when only 1 item is in order items list and is back ordered.
-- Execute Batch -- 
    BatchEmergencyTimeSweepScheduler job = new BatchEmergencyTimeSweepScheduler(); ID batchprocessid = Database.executeBatch(job, 1); 
 ********************************************************************************************************************************************************/

global class BatchEmergencyTimeSweepScheduler implements Schedulable{
 global void execute(SchedulableContext SC) 
   {
       BatchEmergencyTimeSweep job = new BatchEmergencyTimeSweep();
       ID batchprocessid = Test.isRunningTest() ? Database.executeBatch(job, 100) : Database.executeBatch(job, 10);
   }
}