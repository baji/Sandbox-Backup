/*
@Company:Infoglen
@Author:Imran
@Creation date:24/11/2017
Reference:
*/
/**
 * Class S2SBulkRecordDelete
 *
 * This batch class is used to delete records 
 */
global class S2SBulkRecordDelete implements Database.Batchable<sObject>{
    String objectApiName;
    global S2SBulkRecordDelete(String ObjName){
        objectApiName = ObjName;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id,Name FROM '+objectApiName);
    }
    global void execute(Database.BatchableContext BC, List<Sobject>scope){
        Delete scope;       
    }
    global void finish(Database.BatchableContext BC){
    
    }
}