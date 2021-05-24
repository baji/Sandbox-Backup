//********************************************************************************************************************************************************************************************************************************************
// Author: Ewa O.
// Created:	7-10-2018 -<ASP-1189> - APEX code to handle basic cleanup tasks for a post Sandbox copy.
//*****************************************************************************************************************************
global class PrepareMySandbox implements SandboxPostCopy{
 	List<Profile> someProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
    //runs the code after sandbox creation 
    global void runApexClass(System.SandboxContext context){
        changeEmailForSFAdmins();
    }
    //changes email addresses for Salesforce admins
    public void changeEmailForSFAdmins(){
       List<User>  adminUsers = [SELECT Id, email FROM User WHERE ProfileId = :someProfileId[0].Id];
        
        for(User emailAddress : adminUsers){
            if(emailAddress.email.indexOf('=')!=-1){
                Integer placeOfAt = emailAddress.email.indexOf('@');
                if(placeOfAt!=-1){
                    // vs using indexOfAny(substring)?
                    String name=emailAddress.email.substring(0, placeOfAt);
                    name=name.replace('=','@');
                    emailAddress.email=name;
                    system.debug(emailAddress.email);
                }
            }
            // else the email is in the correct format and does not need to be reformatted
        }
        //updates the admin email addresses
        update adminUsers;
    }
}