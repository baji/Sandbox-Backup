/*****************************************************************************************************************************************************
    Programmer:     Tony Williams
    Company:        Awana
    Contact:        tonyw@awana.org
    Project:        Newgistics
    Description:    batch Apex Scheduler for sending orders to Newgsitics web services from SFDC.Gets shipment ID from the response.
    Original:       12/14/2018 - <NEW-25> - Scheduler for sending orders to Newgsitics web services from SFDC.Gets shipment ID from the response.
        -- Execute Batch -- 
    BatchPostShipmentsToNewgisticsSchedule job = new BatchPostShipmentsToNewgisticsSchedule(); ID batchprocessid = Database.executeBatch(job, 1); 
 ********************************************************************************************************************************************************/

global class BatchSearchNewgisticsShipmentsScheduler1 implements Schedulable{
 global void execute(SchedulableContext SC) 
   {
       BatchSearchNewgisticsShipmentsBKUP1 job = new BatchSearchNewgisticsShipmentsBKUP1();
       //BatchSearchNewgisticsShipmentsBKUP job = new BatchSearchNewgisticsShipmentsBKUP();
       //BatchSearchNewgisticsShipmentsTimecheck job = new BatchSearchNewgisticsShipmentsTimecheck();
       ID batchprocessid = Test.isRunningTest() ? Database.executeBatch(job, 100) : Database.executeBatch(job, 10);
   }
}