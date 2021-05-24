/****************************************************************************************************************************************
    Programmer: Tony Williams
    Company:    Awana
    Contact:    tonyw@awana.org
    Project:    (Drop Ship casess)
    Description: Performs SFDC handling of Drop Ship issues fro the Store (i.e. checking for Grand Prix Race Dates on opportunities)
    Created:    06/07/2017 - <ASP-214>  - Created SendEmailCheckRaceDate to send email to Ccare notifying the reps  should the date be older than 6 weeks.   
*******************************************************************************************************************************************/
public class DropShipUtility {
    public static void SendEmailCheckRaceDate(List<Order> opps){
        String oppNames = '';
        Integer rowcount = 0;
        final Integer RACEDATEIS  = 13;
        final Integer SIXWEEKS = 42;
        final Integer MAXCOLUMNS = 5;
        for(Order opp : opps){
        
            String saveDateTime = String.valueOf(opp.Order_Submitted__c);
            Integer DATESIZE = opp.Description.length(); 
            system.debug('<< DROP SHIP OPP >> '+opp.Description);
            //Access the Date from the Description "Race Date is ##/##/####" within the full dewscription string.
            String endOfDate = opp.Description;
            system.debug('<< Order Submitted Date>> '+opp.Order_Submitted__c);
            Integer pos = endOfDate.indexOf('Race Date is');
            pos = pos+RACEDATEIS;
            String raceDateStr = opp.Description.substring(pos,DATESIZE);
            pos =  raceDateStr.indexOf('/');
            pos -= 2;
            system.debug('<< RACE DATE IS>> '+raceDateStr);
            system.debug('<< END DATE>> '+raceDateStr);
            String someyear = raceDateStr.substring(6,10);
            system.debug('<<YEAR>> '+someyear);
            String somemonth = raceDateStr.substring(3,5);
            system.debug('<<MONTH>> '+somemonth);
            String someday = raceDateStr.substring(0,2);
            system.debug('<<DAY>> '+someday);
            endOfDate = someyear+'-'+someday+'-'+somemonth;
            // 1. Replace the '/'s with '-'s
            // 2. flip the date around so that it looks like 2017-mo-day
            saveDateTime = saveDateTime.substring(0,10);
            system.debug('<<ORDER SUBMITTED Processed >> '+saveDateTime);
            Date saveDateSubmitted =  Date.valueOf(saveDateTime);
            Date saveDateRace = Date.valueOf(endOfDate);
            system.debug('<<ORDER SUBMITTED FINAL STATE>> '+ saveDateSubmitted +'<<RACE DATEFINAL STATE>> '+saveDateRace );
            //Now check and see if the Race Date is < 
            integer intDays =  saveDateSubmitted.daysBetween(saveDateRace);
            system.debug('<< DAYS REMAINING >> '+ intDays );
            if(intDays < SIXWEEKS){
                if(Math.mod(rowcount,MAXCOLUMNS) == 0){
                    oppnames += '\n';
                }
               oppnames = oppnames + opp.Name+',';
               rowcount++;
            }
            
        }//Loop
        if(oppnames !='' && oppnames != null){
            oppnames = oppnames.substring(0,oppnames.length() -1); // Remove last comma.
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {'marquitab@awana.org','kathyk@awana.org','customercare@awana.org'});
            mail.setSenderDisplayName('Drop Ship Race Date');
            mail.setSubject('Drop Ship Opportunities Needed Sooner Than Six Weeks');
            mail.setPlainTextBody('Here are your opportunities with drop ship items needed sooner than six weeks.'+oppnames);
            // send email
            Messaging.SendEmailResult[] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
  }// SendEmailCheckRaceDate
}