/*
Author - Darshan Chhajed
Description - This class is used for Test Methods of various Classes used for RE Migration. 
*/
@isTest
Public Class ReMigrationTestClass{

@testSetup
public static void setupData(){
     
     list<Awana_Settings__c> CustomSettingsLst =  new list<Awana_Settings__c>();
     list<string> customSettingNames =  new list<string>{'EnableDeDupCheck','ExecuteNotesTrigger','ExecuteREMigrationAction','ExecuteOpptyTriggerForREMigration'};
     for(String Name : customSettingNames){
             Awana_Settings__c setting = new Awana_Settings__c();
             setting.Name = Name;
             setting.Value__c = 'true';
             CustomSettingsLst.add(setting);
     }
     insert CustomSettingsLst;   
     //RENotesMigrationParentObjectName>
}

public static testMethod void TestREMigrationActions(){
    
     Test.StartTest();
     Awana_Settings__c CustomSetting =  new Awana_Settings__c();
     CustomSetting.Name= 'ExecuteTaskTrigger';
     CustomSetting.Value__c = 'false';
     insert CustomSetting;
     
     Contact duplicate = new contact();
     duplicate.FirstName = 'Nickol#';
     duplicate.LastName = 'Jackson#';    
     duplicate.Email = 'testClasses@salesforce.com';
     duplicate.RE_Constit_Rec_Id__c='123456'; 
     insert duplicate;
      
     Campaign C = new Campaign();
     C.name = 'Test';
     C.RE_Appeal_ID__c = 'TestCampaign';
     insert C;
     Task T = new Task();
     T.Source_WhoId__c = '123456';
     T.Source_WhatId__c = 'TestCampaign';
     T.Source_RE_ID__c= '1010101';
     T.Subject = 'test Subject';
     T.Status = 'Not Started';
     T.Priority = 'Normal';
     T.ActivityDate = System.Today();
     Insert T;
     Test.StopTest();
     system.debug('T'+T.whoId+'    '+T.Id);
     Task tak = [SELECT WhoId FROM Task WHERE Id = :T.Id];
     list<Contact> contLst = [SELECT id FROM Contact WHERE RE_Constit_Rec_Id__c = '123456'];
     system.AssertEquals(contLst.get(0).Id,Tak.WhoId);
    
} 

public static testMethod void TestTaskNotePad(){
    
     
     Awana_Settings__c CustomSetting =  new Awana_Settings__c();
     CustomSetting.Name= 'ExecuteTaskTrigger';
     CustomSetting.Value__c = 'false';
     insert CustomSetting;
     
     Task T = new Task();
     T.Source_WhoId__c = '123456';
     T.Source_WhatId__c = 'TestCampaign';
     T.Source_RE_ID__c= '101';
     T.Subject = 'test Subject';
     T.Status = 'Not Started';
     T.Priority = 'Normal';
     T.ActivityDate = System.Today();
     Insert T;
     TaskNotes__c TN = new TaskNotes__c();
     TN.ParentId__c = '101';
     TN.NoteBody__c = 'This is test body';
     TN.Title__c   = '01/01/2012 Test Title';
     Insert TN;
     Test.StartTest();
         ContentNoteBatch B1 = new ContentNoteBatch();
         Database.ExecuteBatch(B1,1);
     Test.StopTest();
    
     list<TaskNotes__c> TNLst =  [SELECT ContentNoteId__c FROM TaskNotes__c WHERE ParentId__c = '101'];
     system.AssertNotEquals(TNLst.get(0).ContentNoteId__c,null);
    
}

public static testMethod void TestTaskNotePadContentLink(){
     Awana_Settings__c CustomSetting =  new Awana_Settings__c();
     CustomSetting.Name= 'ExecuteTaskTrigger';
     CustomSetting.Value__c = 'false';
     insert CustomSetting;
     
     Task T = new Task();
     T.Source_WhoId__c = '123456';
     T.Source_WhatId__c = 'TestCampaign';
     T.Source_RE_ID__c= '101';
     T.Subject = 'test Subject';
     T.Status = 'Not Started';
     T.Priority = 'Normal';
     T.ActivityDate = System.Today();
     Insert T;
     TaskNotes__c TN = new TaskNotes__c();
     TN.ParentId__c = '101';
     TN.NoteBody__c = 'This is test body';
     TN.Title__c   = '01/01/2012 Test Title';
     Insert TN;
     ContentNote cn  = new ContentNote();
     cn.Title = TN.Title__c.trim();
     string contentBody = TN.NoteBody__c.trim();
     contentBody = contentBody.escapeHTML4();  
     insert cn;
     TN.ContentNoteId__c = cn.Id;
     Update TN;
     Test.StartTest();
         ContentDocumentLinkBatch B1 = new ContentDocumentLinkBatch();
         Database.ExecuteBatch(B1,1);
     Test.StopTest();
       
}
}