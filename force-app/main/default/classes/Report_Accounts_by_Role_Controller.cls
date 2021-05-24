public class Report_Accounts_by_Role_Controller
{

    public String overrideStatus { get; set; }

    public String pickedValue1 { get; set; }

    public Id usrid { get; set; }
    
    public User usr{get;set;}
    public Account aUser{get;set;}
    public String pickedChurchRole { get; set; }

    public String pickedAwanaRole { get; set; }
      
    public CampaignMember cm{get;set;}
    
    
    public boolean isExport {get;set;}
    
    public string pickedValue{get;set;}
    
    //List<Account> aList;
    
    String baseQuery;
    String finalQuery;
      
    public ApexPages.StandardSetController con{get; set;}
        
    public String u {get; set;}
    
        public Report_Accounts_by_Role_Controller()
        {
            usr = new User();
            aUser = new Account();
            cm = new CampaignMember();
            //aList = new List<Account>();
            overrideStatus = 'yes';
            if(Apexpages.currentPage().getParameters().get('Export') != null){
                isExport = true;
              }
              else{
                isExport = false;
              }
   
        }
        public List<Account> searchResults
        {
            get
            {
                if(con != null)
                    return (List<Account>)con.getRecords();
                else
                    return null ;
            }
            set;
        }
    
        public pagereference reportResults(){
            
            //String state='Physical_State__c = \''+pickedValue+'\' ';
            String qr_roles = '';
            String qr_atm = '';
            String state='';
            
            system.debug('---------------State--------------------'+state); 
            system.debug('---------------Primary Missionary--------------------'+usr.ManagerId);
            system.debug('---------------Primary Missionary Account OwnerID--------------------'+aUser.OwnerId);    
            if(pickedAwanaRole != 'test' && pickedChurchRole != 'test'){
                qr_roles += ' where (Awana_Role__c INCLUDES (\''+pickedAwanaRole+'\') OR Church_Role__c = \''+pickedChurchRole+'\') AND ';
            }
            else if(pickedAwanaRole != 'test'){
                 qr_roles += ' where Awana_Role__c INCLUDES (\''+pickedAwanaRole+'\') AND ';     
            }   
            else if(pickedChurchRole != 'test'){
                qr_roles += ' where Church_Role__c = \''+pickedChurchRole+'\'  AND ';
            }
            else{
                qr_roles += ' where ';
                system.debug('*********Roles are Empty************');
            }
            /*-----------------------------------------------------------------------*/
            if(pickedValue != 'test' && aUser.OwnerId == null){
            //if(pickedValue != 'test' && usr.ManagerId == null){
                system.debug('----------------One-------------------');
                system.debug('----------------TeamMember-------------------'+qr_atm);
                system.debug('----------------State-------------------'+pickedValue);
                state='Physical_State__c = \''+pickedValue+'\' AND';
                qr_atm += 'where TeamMemberRole = \'Primary Missionary\'';
                baseQuery = 'Select Id,Name,Mailing_Address_Book__c,Physical_State__c,Physical_City__c,Owner.Name,(select UserId,user.name,TeamMemberRole from accountTeamMemberS '+qr_atm+'),(select npe5__Contact__r.Email,npe5__Contact__r.Name,Church_Role__c,Awana_Role__c,npe5__Status__c from npe5__Affiliations__r' + qr_roles +'npe5__Status__c = \'Current\') from Account';
                finalQuery = baseQuery +' where '+state+' recordType.Name = \'US Organization\' AND (Registration_Level__c =\'R1\' or Registration_Level__c =\'R2\') AND (Registration_Status__c = \'New\' or Registration_Status__c = \'Renewed\' or Registration_Status__c = \'Reinstated\') AND Type = \'Church\' AND Id IN (select npe5__Organization__c from npe5__Affiliation__c' + qr_roles +'npe5__Status__c = \'Current\') Order By Name ';
            
            }
            if(pickedValue == 'test' && aUser.OwnerId != null){
            //if(pickedValue == 'test' && usr.ManagerId != null){
                system.debug('----------------Two-------------------');
                state = '';
                //qr_atm += 'where UserId = \''+usr.ManagerId+'\'';
                qr_atm += 'where UserId = \''+aUser.OwnerId+'\'';
                baseQuery = 'Select Id,Name,Mailing_Address_Book__c,Physical_State__c,Physical_City__c,Owner.Name,(select UserId,user.name,TeamMemberRole from accountTeamMemberS '+qr_atm+'),(select npe5__Contact__r.Email,npe5__Contact__r.Name,Church_Role__c,Awana_Role__c,npe5__Status__c from npe5__Affiliations__r' + qr_roles +'npe5__Status__c = \'Current\') from Account';
                finalQuery = baseQuery +' where '+state+' recordType.Name = \'US Organization\' AND (Registration_Level__c =\'R1\' or Registration_Level__c =\'R2\') AND (Registration_Status__c = \'New\' or Registration_Status__c = \'Renewed\' or Registration_Status__c = \'Reinstated\') AND Type = \'Church\' AND Id IN (select npe5__Organization__c from npe5__Affiliation__c' + qr_roles +'npe5__Status__c = \'Current\') AND Id IN (select AccountId from accountTeamMember '+qr_atm+') Order By Name ';
            
            }
            if(pickedValue != 'test' && aUser.OwnerId != null){
            //if(pickedValue != 'test' && usr.ManagerId != null){
                system.debug('----------------Three-------------------');
                state='Physical_State__c = \''+pickedValue+'\' AND';
                //qr_atm += 'where UserId = \''+usr.ManagerId+'\'';
                qr_atm += 'where UserId = \''+aUser.OwnerId+'\'';
                baseQuery = 'Select Id,Name,Mailing_Address_Book__c,Physical_State__c,Physical_City__c,Owner.Name,(select UserId,user.name,TeamMemberRole from accountTeamMemberS '+qr_atm+'),(select npe5__Contact__r.Email,npe5__Contact__r.Name,Church_Role__c,Awana_Role__c,npe5__Status__c from npe5__Affiliations__r' + qr_roles +'npe5__Status__c = \'Current\') from Account';
                finalQuery = baseQuery +' where '+state+' recordType.Name = \'US Organization\' AND (Registration_Level__c =\'R1\' or Registration_Level__c =\'R2\') AND (Registration_Status__c = \'New\' or Registration_Status__c = \'Renewed\' or Registration_Status__c = \'Reinstated\') AND Type = \'Church\' AND Id IN (select npe5__Organization__c from npe5__Affiliation__c' + qr_roles +'npe5__Status__c = \'Current\') AND Id IN (select AccountId from accountTeamMember '+qr_atm+') Order By Name ';
                           
            }
            
            /*-------------------------------------------------------------------------*/
            
            system.debug('-----------------'+finalQuery);
      
            con = new ApexPages.StandardSetController(Database.getQueryLocator(finalQuery));
                          
            con.setPageSize(100);         

            //aList = Database.Query(finalQuery);            
            //system.debug('--------Accounts List Size---------'+aList.size());
            
            return null;
        
        }
        
             public PageReference addCampaign() {
                  
                system.debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'+cm);
                String aState;
                String aRole;
                String cState;
                String cRole;
                String usrId;
                String baseQuery;
                String finalQuery;        
                
                aState = Apexpages.currentPage().getParameters().get('aState');
                aRole = Apexpages.currentPage().getParameters().get('aRole');
                cState = Apexpages.currentPage().getParameters().get('cState');
                cRole = Apexpages.currentPage().getParameters().get('cRole');
                usrId = Apexpages.currentPage().getParameters().get('usrId');
                
                system.debug('************************'+aState);
                system.debug('************************'+aRole);
                system.debug('************************'+cState);
                system.debug('************************'+cRole);
                system.debug('************************'+usrId);
                
                List<Account> aList; 
                List<npe5__Affiliation__c> conList;
                Set<Id> contactList = new Set<Id>();
                Set<Id> campaignInsertIdlist = new Set<Id>();
                List<CampaignMember> newCMs = new List<CampaignMember>();
                List<CampaignMember> cmlist;
                Set<Id> insertIds = new Set<Id>();
                
                String qr_roles = '';
                String qr_atm = '';
                String state='';
                
                system.debug('---------------State--------------------'+aState);
                system.debug('---------------State--------------------'+qr_roles);
                system.debug('---------------State--------------------'+qr_atm); 
                system.debug('---------------Primary Missionary--------------------'+usr.ManagerId);    
                system.debug('---------------Primary Missionary User Id--------------------'+aUser.OwnerId);
                
                if(aRole != 'test' && cRole != 'test'){
                    qr_roles += ' where (Awana_Role__c INCLUDES (\''+aRole+'\') OR Church_Role__c = \''+cRole+'\') AND ';
                }
                else if(aRole != 'test'){
                     qr_roles += ' where Awana_Role__c INCLUDES (\''+aRole+'\') AND ';     
                }   
                else if(cRole != 'test'){
                    qr_roles += ' where Church_Role__c = \''+cRole+'\'  AND ';
                }
                else{
                    qr_roles += ' where ';
                    system.debug('*********Roles are Empty************');
                }
                /*-----------------------------------------------------------------------*/
                //if(aState != 'test' && usr.ManagerId == null){
                if(aState != 'test' && usrId == null){                
                    system.debug('----------------One-------------------');
                    state='Physical_State__c = \''+aState+'\' AND';
                    baseQuery = 'Select Id,Name,Mailing_Address_Book__c,Physical_State__c,Physical_City__c,Owner.Name,(select UserId,user.name,TeamMemberRole from accountTeamMemberS '+qr_atm+'),(select npe5__Contact__r.Email,npe5__Contact__r.Name,Church_Role__c,Awana_Role__c,npe5__Status__c from npe5__Affiliations__r' + qr_roles +'npe5__Status__c = \'Current\') from Account';
                    finalQuery = baseQuery +' where '+state+' recordType.Name = \'US Organization\' AND (Registration_Level__c =\'R1\' or Registration_Level__c =\'R2\') AND (Registration_Status__c = \'New\' or Registration_Status__c = \'Renewed\' or Registration_Status__c = \'Reinstated\') AND Type = \'Church\' AND Id IN (select npe5__Organization__c from npe5__Affiliation__c' + qr_roles +'npe5__Status__c = \'Current\') Order By Name ';
                
                }
                //if(aState == 'test' && usr.ManagerId != null){
                if(aState == 'test' && usrId != null){
                    system.debug('----------------Two-------------------');
                    state = '';
                    //qr_atm += 'where UserId = \''+usr.ManagerId+'\'';
                    qr_atm += 'where UserId = \''+usrId+'\'';
                    baseQuery = 'Select Id,Name,Mailing_Address_Book__c,Physical_State__c,Physical_City__c,Owner.Name,(select UserId,user.name,TeamMemberRole from accountTeamMemberS '+qr_atm+'),(select npe5__Contact__r.Email,npe5__Contact__r.Name,Church_Role__c,Awana_Role__c,npe5__Status__c from npe5__Affiliations__r' + qr_roles +'npe5__Status__c = \'Current\') from Account';
                    finalQuery = baseQuery +' where '+state+' recordType.Name = \'US Organization\' AND (Registration_Level__c =\'R1\' or Registration_Level__c =\'R2\') AND (Registration_Status__c = \'New\' or Registration_Status__c = \'Renewed\' or Registration_Status__c = \'Reinstated\') AND Type = \'Church\' AND Id IN (select npe5__Organization__c from npe5__Affiliation__c' + qr_roles +'npe5__Status__c = \'Current\') AND Id IN (select AccountId from accountTeamMember '+qr_atm+') Order By Name ';
                
                }
                //if(aState != 'test' && usr.ManagerId != null){
                if(aState != 'test' && usrId != null){
                    system.debug('----------------Three-------------------');
                    state='Physical_State__c = \''+aState+'\' AND';
                    //qr_atm += 'where UserId = \''+usr.ManagerId+'\'';
                    qr_atm += 'where UserId = \''+usrId+'\'';
                    baseQuery = 'Select Id,Name,Mailing_Address_Book__c,Physical_State__c,Physical_City__c,Owner.Name,(select UserId,user.name,TeamMemberRole from accountTeamMemberS '+qr_atm+'),(select npe5__Contact__r.Email,npe5__Contact__r.Name,Church_Role__c,Awana_Role__c,npe5__Status__c from npe5__Affiliations__r' + qr_roles +'npe5__Status__c = \'Current\') from Account';
                    finalQuery = baseQuery +' where '+state+' recordType.Name = \'US Organization\' AND (Registration_Level__c =\'R1\' or Registration_Level__c =\'R2\') AND (Registration_Status__c = \'New\' or Registration_Status__c = \'Renewed\' or Registration_Status__c = \'Reinstated\') AND Type = \'Church\' AND Id IN (select npe5__Organization__c from npe5__Affiliation__c' + qr_roles +'npe5__Status__c = \'Current\') AND Id IN (select AccountId from accountTeamMember '+qr_atm+') Order By Name ';
                
                }
                
                /*-------------------------------------------------------------------------*/
                               
                system.debug('-----------------'+finalQuery);
                
                aList = Database.Query(finalQuery);
                
                /*-----------------------------Code to fetch the affiliated contacts ids from the account list--------------------------*/
                if(aRole != 'test' && cRole != 'test'){
                    
                    conList = [SELECT npe5__Contact__r.Id from npe5__Affiliation__c where (Awana_Role__c INCLUDES (:aRole) OR Church_Role__c = :cRole) AND npe5__Affiliation__c.npe5__Organization__r.Id IN :aList];
                }
                else if(aRole != 'test'){
                    conList = [SELECT npe5__Contact__r.Id from npe5__Affiliation__c where Awana_Role__c INCLUDES (:aRole) AND npe5__Affiliation__c.npe5__Organization__r.Id IN :aList];    
                }   
                else if(cRole != 'test'){
                    conList = [SELECT npe5__Contact__r.Id from npe5__Affiliation__c where Church_Role__c = :cRole AND npe5__Affiliation__c.npe5__Organization__r.Id IN :aList];
                }
                else{
                    conList = [SELECT npe5__Contact__r.Id from npe5__Affiliation__c where npe5__Affiliation__c.npe5__Organization__r.Id IN :aList];
                }                
                   
                system.debug('*********************Contact Ids List*******************'+conList.size()); 
                system.debug('*********************Account List*******************'+aList.size());
                /*-------------------------End of contact ids -----------------------------------------------------*/
                
                /*-------------------------Code for Adding contacts to Campaign(Add to Campaign)-------------------*/
                    for(npe5__Affiliation__c aff:conList){
                        contactList.add(aff.npe5__Contact__c);
                    }
                    
                    cmlist = [select ContactId from CampaignMember where CampaignId =: cm.CampaignId AND ContactId IN:contactList];
                    if(cmlist != null){
                        for(CampaignMember cmem: cmlist){
                            campaignInsertIdlist.add(cmem.ContactId);
                        }
                    }
                    if(campaignInsertIdlist.size() == 0){                                            
                        for(Id myid: contactList){
                            newCMs.add(new CampaignMember(CampaignId = cm.CampaignId, ContactId = myid, Status = cm.Status));
                        }
                        insert newCMs;                    
                    }
                    if(campaignInsertIdlist.size() != 0){
                        if(contactList.removeAll(campaignInsertIdlist)){
                            system.debug('-------------------Contact List After Parsing-----------------'+contactList.size());
                                for(Id myid: contactList){
                                    newCMs.add(new CampaignMember(CampaignId = cm.CampaignId, ContactId = myid, Status = cm.Status));
                                }
                                insert newCMs;                      
                        }
                        else{
                            system.debug('-------Contacts are not assigned to campaign before------');
                        }
                    }
                /*------------------------------End of Add to Campaign ------------------------------------------*/    
                    
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Records updated with Campaign Successfully!');
                ApexPages.addMessage(myMsg);
                
                PageReference editPageRef = new PageReference('https://login.salesforce.com/'+cm.CampaignId);
                editPageRef.setRedirect(true);
                cm = new CampaignMember();
                return editPageRef;
                //return null;
            }

            public void PREVIOUS() 
            {
                 con.previous();
            }
            public void NEXT() 
            {
                 con.next();
            }
            public Boolean hasNext
            {
            get
            {
            return con.getHasNext();
            }
            set;
            }           
            public Boolean hasPrevious
            {
            get
            {
            return con.getHasPrevious();
            }
            set;
            }
            public PageReference export(){
                isExport = true;
                return null;
            } 
            
}