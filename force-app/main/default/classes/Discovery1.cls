public class Discovery1 {
    public static void countProfiles(){
        List<Profile> profileList =  new List<Profile>();
        profileList  = [Select id, Name from profile];
        Set<String> profileNameList = new Set<String>();
        for(Profile p : profileList){
            System.debug('profileName->'+p.Name);
            profileNameList.add(p.Name);
        }
        System.debug('profileNameList->'+profileNameList);
        for(String ss : profileNameList){
            System.debug('profileNameList********->'+ss);
            
        }
    }
    
}