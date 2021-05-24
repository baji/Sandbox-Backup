@isTest
public class Test_WsNote{
    static testMethod void noteCreate(){
        Account fullAcc = Test_S2SObjects.S2S_FullAccount();
        Insert fullAcc;
        Order ord = Test_S2SObjects.S2S_FullOrder();
            system.debug('oo------'+ord);
            ord.AccountId = fullAcc.Id;
            ord.Source_Opportunity_Id__c = '0015000001R4u9YAAR';
        Insert ord;
        RestRequest request = new RestRequest();
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/SSNotes';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.params.put('objName', 'Opportunity');
        request.requestBody = Blob.valueOf('[{"attributes":{"type":"Note","url":"/services/data/v41.0/sobjects/Note/0025000000XCAnCAAX"},"Id":"0025000000XCAnCAAX","Title":"Clubs","Body":"grade","ParentId":"0015000001R4u9YAAR"},{"attributes":{"type":"Note","url":"/services/data/v41.0/sobjects/Note/0025000000XDOz9AAH"},"Id":"0025000000XDOz9AAH","Title":"Pending to conversion process","Body":"He called backBP","ParentId":"0015000001RaeSbAAJ"}]');
        RestContext.request = request;
        WsNotes.doPost();
    }
    static testMethod void noteCreate1(){
        RestRequest request = new RestRequest();
        request.requestUri = 'https://awanasandbox--awananpsp3.cs91.my.salesforce.com/services/apexrest/SSNotes';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.params.put('objName', 'Account');
        request.requestBody = Blob.valueOf('[{"attributes":{"type":"Note","url":"/services/data/v41.0/sobjects/Note/0025000000XCAnCAAX"},"Id":"0025000000XCAnCAAX","Title":"Clubs","Body":"grade","ParentId":"0015000001R4u9YAAR"},{"attributes":{"type":"Note","url":"/services/data/v41.0/sobjects/Note/0025000000XDOz9AAH"},"Id":"0025000000XDOz9AAH","Title":"Pending to conversion process","Body":"He called backBP","ParentId":"0015000001RaeSbAAJ"}]');       
        RestContext.request = request;
        WsNotes.doPost();
    }
}