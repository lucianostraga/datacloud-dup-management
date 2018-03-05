trigger AccountTrigger on Account (before insert, after insert, 
                                                  before update, after update, 
                                                  before delete, after delete) {
    
    //INSERT
    if(Trigger.isBefore && Trigger.isInsert){
		AccountTriggerHandler.manageDuplicates(trigger.new);
    }
      
}