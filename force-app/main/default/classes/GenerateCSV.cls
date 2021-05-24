public class GenerateCSV {

    public static void GenerateCSV(){                           

            AggregateResult[] CMs = [select count(id),email from contact group by email having count(id)>1];

            system.debug('CMs = '+CMs);

            String csv = 'Email\n';

            for(AggregateResult CM: CMs){
                csv += CM.get('email') + '\n';       
            }                      

            Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
                Blob csvBlob = blob.valueOf(csv);
                String csvName = 'CMs CSV';
                csvAttachment.setFileName(csvName);

                csvAttachment.setBody(csvBlob);

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[]{'nikhil@infoglen.com'};
                String subject = 'CMs CSV';
                email.setSubject(subject);
                email.setToAddresses(toAddresses);
                email.setPlainTextBody('CMs CSV');
                email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        }  
    }