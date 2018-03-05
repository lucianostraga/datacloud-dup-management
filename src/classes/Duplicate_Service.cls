public class Duplicate_Service {
    
    public static List<DuplicationServiceResponse> getDuplicatesBulk(List<sObject> sObjectsToAnalyze){
        
        List<DuplicationServiceResponse> dupResponses = new List<DuplicationServiceResponse>();
        Integer i = 0;

        if(!sObjectsToAnalyze.isEmpty()){
            List<Datacloud.FindDuplicatesResult> results = Datacloud.FindDuplicates.findDuplicates(sObjectsToAnalyze);

            for(Datacloud.FindDuplicatesResult res : results){
                
                DuplicationServiceResponse response = new DuplicationServiceResponse();
                response.analyzedSObject = sObjectsToAnalyze[i];
                
                for(Datacloud.DuplicateResult dupeResult : res.getDuplicateResults()){
                    
                    for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                                           
                        for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                            
                            if(matchResult.getMatchEngine() == 'ExactMatchEngine'){
                                response.exactDups.add(matchRecord.getRecord());
                                response.hasDuplicates = true;
                            }

                            else if(matchResult.getMatchEngine() == 'FuzzyMatchEngine'){
                                response.exactDups.add(matchRecord.getRecord());
                                response.hasDuplicates = true;
                        	}
                        }
                    }
                }
                
                dupResponses.add(response);
                i++;
            }

        }
        return dupResponses;
    }
    
    public class DuplicationServiceResponse{
        @AuraEnabled public sObject analyzedSObject;
               
        @AuraEnabled public List<sObject> exactDups;
        @AuraEnabled public List<sObject> fuzzyDups;
        @AuraEnabled public Boolean hasDuplicates;

        public DuplicationServiceResponse(){
            hasDuplicates = false;
            exactDups = new List<sObject>();
            fuzzyDups = new List<sObject>();
        }
    }

}