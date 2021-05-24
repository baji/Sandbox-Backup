/***********************************************************************************************************************************************
    Programmer: Tony Williams
    Updates: Tony WIlliams
    Company:    Awana
    Project:    ASP
    Created:    10/22/2017 - <ASP-481,606>
---------------
Called BY Process Builder: Assign International Inquiries
Test Class: UpdateInternationalInquiryOwner_Test
***********************************************************************************************************************************************/

global class UpdateInternationalInquiryOwner {
     @InvocableMethod
    public static void getInternationalInquiry(List<Id> inquiryIds){
        List<GroupMember> lowner = [Select g.UserOrGroupId From GroupMember g where Group.Name = 'Inquiry International Other'];
        List<GroupMember> lownerPR = [Select g.UserOrGroupId From GroupMember g where Group.Name = 'Inquiry International Puerto Rico'];
        List<GroupMember> lownerCAN = [Select g.UserOrGroupId From GroupMember g where Group.Name = 'Inquiry International Canada'];
        
        for(List<Lead> leads : [Select Id, Physical_Country__c, Status FROM Lead where  Id in: inquiryIds and Physical_Country__c  not in ('United States','US','UNITED STATES','United States of America','U.S.','U.S.A.')] ){
            for(Lead aLead : leads){
                 if( aLead.Physical_Country__c != null && aLead.Physical_Country__c!='' && aLead.Physical_Country__c.toUpperCase() != 'UNITED STATES' && aLead.Physical_Country__c.toUpperCase() != 'US' && aLead.Physical_Country__c.toUpperCase() != 'U.S.' &&  aLead.Physical_Country__c.toUpperCase() != 'UNITED STATES OF AMERICA' &&  aLead.Physical_Country__c.toUpperCase() !='USA'){            
                    aLead.Status = 'International';
                    if( aLead.Physical_Country__c == 'Puerto Rico' || aLead.Physical_Country__c.toLowerCase() == 'puerto rico' || aLead.Physical_Country__c.toUpperCase() == 'PUERTO RICO' || aLead.Physical_Country__c.toUpperCase() == 'PR' || aLead.Physical_Country__c.toLowerCase() == 'pr'){
                        aLead.OwnerId = lownerPR[0].UserOrGroupId;
                    }else if(aLead.Physical_Country__c == 'Canada' || aLead.Physical_Country__c.toLowerCase() == 'canada' || aLead.Physical_Country__c.toUpperCase() == 'CA' || aLead.Physical_Country__c.toLowerCase() == 'ca' || aLead.Physical_Country__c.toUpperCase() == 'CAN' || aLead.Physical_Country__c.toLowerCase() == 'can'){
                        aLead.OwnerId = lownerCAN[0].UserOrGroupId;
                    }else{ 
                        aLead.OwnerId = lowner[0].UserOrGroupId;
                    }
                 }
            }// inner-FOR
            Database.update(leads);
        }// outer FOR
    }
}