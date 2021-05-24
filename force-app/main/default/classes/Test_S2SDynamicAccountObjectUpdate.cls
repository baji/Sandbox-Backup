@isTest
public class Test_S2SDynamicAccountObjectUpdate{
    static testMethod void accountMethod(){
        
        Contact con = new Contact();
            con.LastName = 'Imran';
        Insert con;
        
        CP_Account__c cpAcc = new CP_Account__c();
            cpAcc.Commander__c = con.Id;
        Insert cpAcc;
        
        Account a = new Account();
            a.Name = 'Infoglen1';
        Insert a;
        
        Account acc = new Account();
            acc.Name = 'Infoglen';
            acc.Associated_Church__c = cpAcc.Id;
            acc.Source_Account_Rec_Id__c = a.Id;
            acc.Source_Associated_Church__c = cpAcc.Id;
        Insert acc;
        
        List<PartnerNetworkConnection> connMap = new List<PartnerNetworkConnection>([select Id, ConnectionStatus, ConnectionName from PartnerNetworkConnection where ConnectionStatus = 'Sent']);
        for(PartnerNetworkConnection network : connMap) {    
            
            PartnerNetworkRecordConnection newrecord = new PartnerNetworkRecordConnection();
                newrecord.ConnectionId = cpAcc.Id;
                newrecord.LocalRecordId = acc.Id;
                newrecord.SendClosedTasks = true;
                newrecord.SendOpenTasks = true;
                newrecord.SendEmails = true;   
            insert newrecord;
            
            PartnerNetworkRecordConnection newrecord1 = new PartnerNetworkRecordConnection();
                newrecord1.ConnectionId = network.Id;
                newrecord1.LocalRecordId = acc.Id;
                newrecord1.SendClosedTasks = true;
                newrecord1.SendOpenTasks = true;
                newrecord1.SendEmails = true; 
            insert newrecord1;
        }  
        
        S2SDynamicAccountObjectUpdate ss = new S2SDynamicAccountObjectUpdate();
            Database.ExecuteBatch(ss,10);
    }
}