/*********************************************************************************************************
    Programmer:         Ayesha
    Company:            Awana
    Contact:            ayesha@infoglen.com
    Project:            TestNewTaskTouchParentObject
    Original:           12/27/2017 - Used to test NewTaskTouchParentObject.
 ***********************************************************************************************************/   
@IsTest(SeeAllData=true)
public class TestNewTaskTouchParentObject {
    public static testMethod void testTTrigger(){

		List<Opportunity> opp = new List<Opportunity>{ new Opportunity(
        name = 'test opp 1',
        StageName = 'Oferecer projeto/orçamento',
        LeadSource = 'Google',
        CloseDate = system.today()) };
                                
        insert opp;
        
        Account ac = TestObjects.FullAccount();
        insert ac;
        contact cn = TestObjects.FullContact();
        insert cn;
        List<Lead> Leads= new List<Lead>();
        Id aqrc = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Acquisition').getRecordTypeId();
        Leads.add(new Lead(RecordTypeId =aqrc, 
                           FirstName='ACQUISITIOn',
                           LastName='Lead',
                           PhysicalStreet1__c ='The Landmark @ One Market',
                           PhysicalStreet2__c = 'Suite 300',
                           PhysicalCity__c =  'San Francisco',
                           PhysicalState__c =  'CA',
                           PhysicalZipCode__c = '94105',
                           Physical_Country__c = 'UNITED STATES',
                           Email = 'acquireleads@mailinator.com',
                           Status = 'New',
                           Company = 'Accion',
                           CurrencyIsoCode = 'USD',
                           LeadSource = 'Advertisement', 
                           PositionRole__c = 'Associate Pastor',
                           Missionary_Source__c = 'Prefered Tester',
                           Phone = '(415) 326-7173' ,
                           Street = 'The Landmark @ One Market',
                           City = 'San Francisco',
                           PostalCode = '94105',
                           Country =  'UNITED STATES'
                          )
                 );
        insert leads;
        Campaign camp1 = new Campaign(Name = 'Test Campaign 1', IsActive = True);
        insert camp1;
        
		List<task> t = new List<task>{ new task(
        WhatID = opp[0].id,
        Subject='Donni',
        Status='New',
        Type='Call',
        CallType = 'inbound',
        Priority='Normal')};
            
		t.add(new task(
        WhatID = ac.id,
        Subject='Donni',
        Status='New',
        Type='Call',
        CallType = 'inbound',
        Priority='Normal'));
            
		t.add(new task(
        WhatID = camp1.id,
        Subject='Donni',
        Status='New',
        Type='Call',
        CallType = 'inbound',
        Priority='Normal'));
        
        t.add(new task(
        WhoID = cn.id,
        Subject='Donni',
        Status='New',
        Type='Call',
        CallType = 'inbound',
        Priority='Normal'));
        
        t.add(new task(
        WhoID = leads[0].id,
        Subject='Donni',
        Status='New',
        Type='Call',
        CallType = 'inbound',
        Priority='Normal'));
        
        insert t; 
    }
}