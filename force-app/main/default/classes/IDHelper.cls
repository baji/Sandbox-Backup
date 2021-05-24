/***********************************************************************************************************************************************
    Programmer: Tony Williams
    Company:    Awana
    Project:    Newgistics
    Original:   11/21/2018 <NEW -28> Used to serialize IDs for future call outs.
    Called BY: PostShipmentRequest
 ***********************************************************************************************************************************************/
public with sharing class IDHelper {
    
    public String Id {set; get;}

    public IDHelper(String someId) {
        Id = someId;
    }
}