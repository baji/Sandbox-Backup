public class FileUploaderController {
    
    @AuraEnabled
    public static Map<String,String> savecsvFile(String fileData,String fileName) { 
        
        Map<String,String> returnMap = new Map<String,String>();
        try{
            system.debug('apex called>>>');
            fileData = EncodingUtil.urlDecode(fileData, 'UTF-8');            
            returnMap = (handleDealerSiteLockout(fileData,fileName));
        }catch(exception e){
            returnMap.put('error','Please upload a valid CSV file.');
        }            
        
        return returnMap;
        
    }
    
    
    private static Map<String,String> handleDealerSiteLockout(String fileData,String fileName) {
        
        Map<String,String> returnMap = new Map<String,String>();
        
        List<String> csvRows = fileData.split('\n');
        System.debug('csvRows==>'+csvRows.size());
        
        if (csvRows.size() > 1) {            
            updateContactBatch batch = new updateContactBatch();
            batch.fileData = csvRows;  
            batch.fileName = fileName;
            batch.file = fileData;
            Database.executeBatch(batch,20);            
            returnMap.put('success','File is uploaded successfully.');
            
        } else {            
            system.debug('error>>>');
            returnMap.put('error','There is no data in file. Please upload CSV file with data to process.');
        }
        return returnMap;
    }
}