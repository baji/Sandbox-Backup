public class Report_Accounts_by_Role_Export {

    public String aState;
    public String aRole;
    public String cState;
    public String cRole;
    public String usrId;
    String baseQuery;
    String finalQuery;
    
    public Report_Accounts_by_Role_Export(){
        
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
        
    }
    public List<Account> getAllResults()
    {
        List<Account> aList; 
       
        String state='';
        String qr_roles = '';
        String qr_atm = '';
        
        system.debug('-----------------------------------'+aState);
        system.debug('-----------------------------------'+usrId);    
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
        if(aState != 'test' && (usrId == '' && usrId.trim().equals('')) ){
            system.debug('----------------One-------------------');
            state='Physical_State__c = \''+aState+'\' AND';
            qr_atm += 'where TeamMemberRole = \'Primary Missionary\'';
            baseQuery = 'Select Id,Name,Mailing_Address_Book__c,Physical_State__c,Physical_City__c,Owner.Name,(select UserId,user.name,TeamMemberRole from accountTeamMemberS '+qr_atm+'),(select npe5__Contact__r.Email,npe5__Contact__r.Name,Church_Role__c,Awana_Role__c,npe5__Status__c from npe5__Affiliations__r' + qr_roles +'npe5__Status__c = \'Current\') from Account';
            finalQuery = baseQuery +' where '+state+' recordType.Name = \'US Organization\' AND (Registration_Level__c =\'R1\' or Registration_Level__c =\'R2\') AND (Registration_Status__c = \'New\' or Registration_Status__c = \'Renewed\' or Registration_Status__c = \'Reinstated\') AND Type = \'Church\' AND Id IN (select npe5__Organization__c from npe5__Affiliation__c' + qr_roles +'npe5__Status__c = \'Current\') Order By Name ';
        
        }
        if(aState == 'test' && (usrId != '' && !usrId.trim().equals('')) ){
            system.debug('----------------Two-------------------');
            state = '';
            qr_atm += 'where UserId = \''+usrId+'\'';
            
            baseQuery = 'Select Id,Name,Mailing_Address_Book__c,Physical_State__c,Physical_City__c,Owner.Name,(select UserId,user.name,TeamMemberRole from accountTeamMemberS '+qr_atm+'),(select npe5__Contact__r.Email,npe5__Contact__r.Name,Church_Role__c,Awana_Role__c,npe5__Status__c from npe5__Affiliations__r' + qr_roles +'npe5__Status__c = \'Current\') from Account';
            finalQuery = baseQuery +' where '+state+' recordType.Name = \'US Organization\' AND (Registration_Level__c =\'R1\' or Registration_Level__c =\'R2\') AND (Registration_Status__c = \'New\' or Registration_Status__c = \'Renewed\' or Registration_Status__c = \'Reinstated\') AND Type = \'Church\' AND Id IN (select npe5__Organization__c from npe5__Affiliation__c' + qr_roles +'npe5__Status__c = \'Current\') AND Id IN (select AccountId from accountTeamMember '+qr_atm+') Order By Name ';
        
        }
        if(aState != 'test' && (usrId != '' && !usrId.trim().equals('')) ){
            system.debug('----------------Three-------------------');
            state='Physical_State__c = \''+aState+'\' AND';
            qr_atm += 'where UserId = \''+usrId+'\'';
            
            baseQuery = 'Select Id,Name,Mailing_Address_Book__c,Physical_State__c,Physical_City__c,Owner.Name,(select UserId,user.name,TeamMemberRole from accountTeamMemberS '+qr_atm+'),(select npe5__Contact__r.Email,npe5__Contact__r.Name,Church_Role__c,Awana_Role__c,npe5__Status__c from npe5__Affiliations__r' + qr_roles +'npe5__Status__c = \'Current\') from Account';
            finalQuery = baseQuery +' where '+state+' recordType.Name = \'US Organization\' AND (Registration_Level__c =\'R1\' or Registration_Level__c =\'R2\') AND (Registration_Status__c = \'New\' or Registration_Status__c = \'Renewed\' or Registration_Status__c = \'Reinstated\') AND Type = \'Church\' AND Id IN (select npe5__Organization__c from npe5__Affiliation__c' + qr_roles +'npe5__Status__c = \'Current\') AND Id IN (select AccountId from accountTeamMember '+qr_atm+') Order By Name ';
        
        }
        /*-----------------------------------------------------------------------*/
        
        system.debug('-----------------'+finalQuery);
        
        aList = Database.Query(finalQuery);

       /*
       
       if(aRole != 'test' && aState != 'test'){
            String qry_str='';
            String qr_roles='';
           
            if(aState != 'test'){
                qry_str+='Physical_State__c = \''+aState+'\' AND ';
                
            }
            
            if(aRole != 'test'){

                 qr_roles += ' where Awana_Role__c INCLUDES (\''+aRole+'\')  ';
                 
            }
                           
            baseQuery = 'Select Id,Name,Mailing_Address_Book__c,Physical_State__c,Physical_City__c,Owner.Name,(select UserId,user.name,TeamMemberRole from accountTeamMemberS where TeamMemberRole= \'Primary Missionary\'),(select npe5__Contact__r.Email,npe5__Contact__r.Name,Church_Role__c,Awana_Role__c,npe5__Status__c from npe5__Affiliations__r' + qr_roles +' And npe5__Status__c = \'Current\') from Account';
            finalQuery = baseQuery +' where '+qry_str+'RecordType.Name = \'US Organization\' AND (Registration_Level__c =\'R1\' or Registration_Level__c =\'R2\') AND (Registration_Status__c = \'New\' or Registration_Status__c = \'Renewed\' or Registration_Status__c = \'Reinstated\') AND Type = \'Church\' AND Id IN (select npe5__Organization__c from npe5__Affiliation__c' + qr_roles +' And npe5__Status__c = \'Current\') Order By Name ';
            
            aList = Database.Query(finalQuery);
            system.debug('****************************************'+aList.size());
       }
       if(cRole != 'test' && cState != 'test'){
            String qry_str1='';
            String qr_chRole='';
            
            if(cState != 'test'){
                qry_str1+='Physical_State__c = \''+cState+'\' AND ';
                
            }
            if(cRole != 'test'){
                                
                qr_chRole += ' where Church_Role__c = \''+cRole+'\'  ';
            }
        
            baseQuery = 'Select Id,Name,Mailing_Address_Book__c,Physical_State__c,Physical_City__c,Owner.Name,(select UserId,user.name,TeamMemberRole from accountTeamMemberS where TeamMemberRole= \'Primary Missionary\'),(select npe5__Contact__r.Email,npe5__Contact__r.Name,Church_Role__c,Awana_Role__c,npe5__Status__c from npe5__Affiliations__r' + qr_chRole +' And npe5__Status__c = \'Current\') from Account';
            finalQuery = baseQuery +' where '+qry_str1+'RecordType.Name = \'US Organization\' AND (Registration_Level__c =\'R1\' or Registration_Level__c =\'R2\') AND (Registration_Status__c = \'New\' or Registration_Status__c = \'Renewed\' or Registration_Status__c = \'Reinstated\') AND Type = \'Church\' AND Id IN (select npe5__Organization__c from npe5__Affiliation__c' + qr_chRole +' And npe5__Status__c = \'Current\') Order By Name ';
            
            aList = Database.Query(finalQuery);
            system.debug('****************************************'+aList.size());
       }   
       if(usrId != '' && !usrId.trim().equals('')){
            String qr_atm='';
            
            if(usrId != null){
                 qr_atm += 'where UserId = \''+usrId+'\'';
            }
            
            baseQuery = 'Select Id,Name,Mailing_Address_Book__c,Physical_State__c,Physical_City__c,Owner.Name,(select UserId,user.name,TeamMemberRole from accountTeamMemberS '+qr_atm+'),(select npe5__Contact__r.Email,npe5__Contact__r.Name,Church_Role__c,Awana_Role__c,npe5__Status__c from npe5__Affiliations__r where npe5__Status__c = \'Current\') from Account';

            finalQuery = baseQuery +' where RecordType.Name = \'US Organization\' AND (Registration_Level__c =\'R1\' or Registration_Level__c =\'R2\') AND (Registration_Status__c = \'New\' or Registration_Status__c = \'Renewed\' or Registration_Status__c = \'Reinstated\') AND Type = \'Church\' AND Id IN (select npe5__Organization__c from npe5__Affiliation__c where npe5__Status__c = \'Current\') AND Id IN (select AccountId from accountTeamMember '+qr_atm+') Order By Name ';
            aList = Database.Query(finalQuery);
            system.debug('****************************************'+aList.size());
       } 
       */
            return aList;
       
    }  
}