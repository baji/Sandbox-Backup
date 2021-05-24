@isTest
public class Test_WsEvent{
    static testMethod void createEvent(){
        Account fullAcc = Test_S2SObjects.S2S_FullAccount();
        Insert fullAcc;
        Order ord = Test_S2SObjects.S2S_FullOrder();
            ord.AccountId = fullAcc.Id;
            ord.Source_Opportunity_Id__c = '0065000000ha3XjAAI';
        Insert ord;
        RestRequest request = new RestRequest();
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/Events';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.params.put('objName', 'Opportunity');
        request.requestBody = Blob.valueOf('[{"attributes":{"type":"Event","url":"/services/data/v41.0/sobjects/Event/00U0x000001086TEAQ"},"Id":"00U0x000001086TEAQ","WhatId":"0065000000ha3XjAAI","Subject":"Meeting","IsAllDayEvent":false,"ActivityDateTime":"2017-12-28T14:00:00.000+0000","ActivityDate":"2017-12-28","DurationInMinutes":60,"StartDateTime":"2017-12-28T14:00:00.000+0000","EndDateTime":"2017-12-28T15:00:00.000+0000","Type":"Pastor Connection","IsPrivate":false,"EventSubtype":"Event","Formula_WhatId__c":"0065000000ha3XjAAI","Formula_OwnerId__c":"imran@infoglen.com"}]');
        RestContext.request = request;
        WsEvent.doPost();
    }
    static testMethod void createEvent1(){
        Account fullAcc = Test_S2SObjects.S2S_FullAccount();
        Insert fullAcc;
        Order ord = Test_S2SObjects.S2S_FullOrder();
            ord.AccountId = fullAcc.Id;
            ord.Source_Opportunity_Id__c = '0065000000ha3XjAAI';
        Insert ord;
        RestRequest request = new RestRequest();
        request.requestUri = 'https://awanasandbox--awananpsp3.cs91.my.salesforce.com/services/apexrest/Events';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.params.put('objName', 'Account');
        request.requestBody = Blob.valueOf('[{"attributes":{"type":"Event","url":"/services/data/v41.0/sobjects/Event/00U0x000001086TEAQ"},"Id":"00U0x000001086TEAQ","WhatId":"0065000000ha3XjAAI","Subject":"Meeting","IsAllDayEvent":false,"ActivityDateTime":"2017-12-28T14:00:00.000+0000","ActivityDate":"2017-12-28","DurationInMinutes":60,"StartDateTime":"2017-12-28T14:00:00.000+0000","EndDateTime":"2017-12-28T15:00:00.000+0000","Type":"Pastor Connection","IsPrivate":false,"EventSubtype":"Event","Formula_WhatId__c":"0065000000ha3XjAAI","Formula_OwnerId__c":"imran@infoglen.com"}]');
        RestContext.request = request;
        WsEvent.doPost();
    }
}