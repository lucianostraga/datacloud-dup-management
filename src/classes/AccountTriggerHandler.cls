public class AccountTriggerHandler {
    
    public static void manageDuplicates(List<Account> newAccs){
        
        if(newAccs.size() == 1){//ONLY FROM UI
            
            Duplicate_Service.DuplicationServiceResponse res = Duplicate_Service.getDuplicatesBulk(new List<sObject>{newAccs[0]})[0];
            
            if(res.hasDuplicates){
                
                Set<Id> accIds = new Set<Id>();
                
                for(sObject sob : res.exactDups){
                    if(sob.getSObjectType() == Account.sObjectType){
                        accIds.add((Id) sob.get('Id'));
                    }
                }
                
                for(sObject sob : res.fuzzyDups){
                    if(sob.getSObjectType() == Account.sObjectType){
                        accIds.add((Id) sob.get('Id'));
                    }
                }
                
                String dupString = String.valueOf(accIds.size())+' DUPLICATES DETECTED:  ';
                
                List<Account> possibleDupAccounts = [SELECT Id, Name, Owner.Name, OwnerId, BillingCountry FROM Account WHERE Id IN: accIds];
                
                List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
                
                Integer count = 1;
                for(Account a : possibleDupAccounts){
                    ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
                	input.subjectId = a.OwnerId;
                    
                    ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                	mentionSegmentInput.id = UserInfo.getUserId();
                    
                    ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
                    body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            
                    ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
                    textSegment.text = ' Tried to Create a similar Account with Name: \''+newAccs[0].Name+'\' and Country: '+newAccs[0].BillingCountry+'.  Consider granting visibility to the record.';
            
                    body.messageSegments.add(mentionSegmentInput);
                    body.messageSegments.add(textSegment);
                
                	input.body = body;
        
                	ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
                	batchInputs.add(batchInput);
                    
                    dupString += ' ***'+count+')  ->  TYPE: Account, NAME: "'+a.Name+'", CURRENT OWNER: "'+a.Owner.Name+'", COUNTRY: "'+a.BillingCountry+'" | ';
                    count++;
                }

                System.enqueueJob(new PostToChatterQueueable(batchInputs));
            }
        } 
    }
    
    public class PostToChatterQueueable implements Queueable {

        private  List<ConnectApi.BatchInput> batchInputs;

        public PostToChatterQueueable(List<ConnectApi.BatchInput> batchInputs){
            this.batchInputs = batchInputs;
        }

        public void execute(QueueableContext context) { 
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
        }

    }
}