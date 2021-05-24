@isTest
public class Test_S2SDynamicOwnerIDUpdate{
    
    static testMethod void OwnerIdUpdateMethod(){
        QueuesObject testQueue;
        User u =  [SELECT Id,Email from User where Name = 'Awana Applications' limit 1];
        
        Group testGroup = new Group(Name='QUEUE NAME', Type='Queue');
        insert testGroup;
        
        //Creating QUEUE
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            //Associating queue with group AND to the Case object
            testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }
        
        
        Honorarium_Request__c hr = new Honorarium_Request__c();
        hr.Source_OwnerId__c = u.Email;
        
        Honorarium_Request__c hr1 = new Honorarium_Request__c();
        hr1.Source_OwnerId__c = testQueue.Queue.Name;
        
        try{
            insert hr;
            insert hr1;
        }catch(Exception e){
            system.debug('exception in inserting--'+e.getmessage());
        }
        
        S2SDynamicOwnerIDUpdate ss = new S2SDynamicOwnerIDUpdate('Honorarium_Request__c','Source_OwnerId__c');
            Database.ExecuteBatch(ss,10);
    }
    
    static testMethod void OwnerIdwithQueueIdUpdateMethod(){
        QueuesObject testQueue;
        Group testGroup = new Group(Name='QUEUE NAME', Type='Queue');
        insert testGroup;
        
        //Creating QUEUE
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            //Associating queue with group AND to the Case object
            testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Honorarium_Request__c');
            insert testQueue;
        }
        
        //String queueName = select Id from Group where  Type = 'Queue' AND NAME = 'QUEUE NAME'

        Honorarium_Request__c hr1 = new Honorarium_Request__c();
        hr1.Source_OwnerId__c = testGroup.Name;
        
        try{
            insert hr1;
        }catch(Exception e){
            system.debug('exception in inserting--'+e.getmessage());
        }
        
        S2SDynamicOwnerIDUpdate ss = new S2SDynamicOwnerIDUpdate('Honorarium_Request__c','Source_OwnerId__c');
            Database.ExecuteBatch(ss,10);
    }
}