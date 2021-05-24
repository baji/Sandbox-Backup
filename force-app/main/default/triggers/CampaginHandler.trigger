/****************************************************************************************************************************************************************************************************************
Developer:  Imran
Company:    Infoglen
Contact:    imran@Infoglen.com
Project:    Donation Management
Created:    03/19/2018 - <CRM - 130> Campaign trigger to avoid duplicate priority under oe parent campaign 
***************************************************************************************************************************************************************************************************************************************** **************/

trigger CampaginHandler on Campaign(Before Insert,Before Update,Before Delete,After Insert,After Update,After Delete,After UnDelete){
    if(trigger.isBefore && trigger.IsInsert){
        CampaginTriggerHandler.bfiPriorityValidate(trigger.new);
    }
    if(trigger.isBefore && trigger.IsUpdate){
        CampaginTriggerHandler.bfuPriorityValidate(trigger.new,trigger.old,trigger.newMap,trigger.oldMap);
    }
    if(trigger.isBefore && trigger.IsDelete){
    
    }
    if(trigger.isAfter && trigger.isInsert){
    
    }
    if(trigger.isAfter && trigger.isUpdate){
    
    }
    if(trigger.isAfter && trigger.isDelete){
    
    }
    if(trigger.isAfter && trigger.isUndelete){
    
    }
}