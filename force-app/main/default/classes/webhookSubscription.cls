/**
 * @description       : Class to handle webhooks form GitHub 
 * @author            : Sam Belete
 * @group             : 
 * @last modified on  : 09-17-2021
 * @last modified by  : Sam Belete
**/
@RestResource (urlMapping='/api/Webhook/incoming/pushDetail/*')

// this is the url you put in the github webhook payload url - then whenever a commit happend it push the json for you in this url.
//https://samrawit-belete-developer-edition.na163.force.com/services/apexrest/api/Webhook/incoming/pushDetail
global with sharing class webhookSubscription {
    @HttpPost 
    global static void handleNotification (){
     
     try {
     //request 
     RestRequest request =RestContext.request;
     RestResponse response= RestContext.response; 
     //fetching the body 
     //get hash value from header 
     String hashingHeadValue = request.headers.get('X-Hub-Signature-256');
     Blob requestedBody = request.requestBody;
     system.debug(requestedBody.toString());
     //secreateKey is the secret value I put in the Secret filed of github webhook 
     // when you do that Github added X-Hub-Signature-256e: hasing detail in its Headers of the webhook
     Blob hashMACData = Crypto.generateMac('hmacSHA256', requestedBody, Blob.valueOf('secreateKey'));
     //crypto is a predefined apex class in salesforce to genearte a hash value 
     String hashMACString = 'sha256='+EncodingUtil.convertToHex(hashMACData);
     // we are appending sha256 is b/c in github the value is apped with this string.

     if(hashingHeadValue == hashMACString){
         system.debug('secret value matched and source can be trued');
         JSONParser parser =JSON.createParser(requestedBody.toString());
         pusher pusherDetail;
         head_commit headCommitDetail;
         String repository;
         while(parser.nextToken() != null){
             if(parser.getText() == 'pusher'){
                 system.debug('inside pusher');
                 parser.nextToken();
                 pusherDetail=(pusher)parser.readValueAs(pusher.class);
                 system.debug(pusherDetail);
             }

             if(parser.getText() == 'head_commit'){
                 system.debug('inside head_commit');
                 parser.nextToken();
                 headCommitDetail = (head_commit)parser.readValueAs(head_commit.class);
                 System.debug(headCommitDetail);

             }

             if (parser.getText() =='full_name'){
                 system.debug('inside full_name');
                 parser.nextToken();
                 repository = parser.getText();
                 system.debug(repository);
             }


         }


    //create github push detail record based on the recevied detail 
    Github_Push_Detail__c  githubPushedDetail = new Github_Push_Detail__c();
    githubPushedDetail.Name = pusherDetail != null ? pusherDetail.name: null ;
    githubPushedDetail.Email__c = pusherDetail != null ? pusherDetail.email: null ;
    githubPushedDetail.Commit_Message__c = headCommitDetail != null ? headCommitDetail.message: null ;
    githubPushedDetail.Timestamp__c = headCommitDetail != null ? DateTime.parse(headCommitDetail.timestamp): null ;
    githubPushedDetail.Commited_URL__c = headCommitDetail != null ? headCommitDetail.url: null ;
    githubPushedDetail.Repository_Name__c = repository;
    githubPushedDetail.Added_Components__c = headCommitDetail != null && headCommitDetail.added != null ? String.join(headCommitDetail.added,','): null ;
    githubPushedDetail.Removed_Components__c=  headCommitDetail != null && headCommitDetail.removed != null ? String.join(headCommitDetail.removed,','): null ;
    githubPushedDetail.Modified_Components__c=  headCommitDetail != null && headCommitDetail.modified != null ? String.join(headCommitDetail.modified,','): null ;
     
    insert githubPushedDetail;
    response.statusCode = 200;
    response.responseBody = Blob.valueOf(JSON.serialize(new SFDCResponse('Success','Processed Successfully')));
    
} //end  outer if 

    else {
        //set response unauthorized 
        response.statusCode = 401;
        response.responseBody = Blob.valueOf(JSON.serialize(new SFDCResponse('Failure','Not a valid Sender')));  

    }
     
    
    }catch(Exception e){
    system.debug('Exception happend:' + e.getMessage());
    
    }
    
    
    } // end of the method.
    
    //innner wrapper class to hold the Pusher detail 
    class pusher {
		public String name;	//ssbh
		public String email;	//ssb.formal@gmail.com
        public pusher(String name, String email){
            name = name;
            email = email;
        }
	}

     // innner class to hold the head commit detail 
    class head_commit {
		public String id;	//b3d1c514f886bfb10a2a444f729a2cf98e47ba33
		public String tree_id;	//c90e00792f93f0dfea09541fb510c9bdb489bc41
		public boolean distinct;
		public String message;	//Third around commit
		public String timestamp;	//2021-09-14T18:00:36-04:00
		public String url;	//https://github.com/ssbh/WebhookRepository/commit/b3d1c514f886bfb10a2a444f729a2cf98e47ba33
	    public cls_author author;
		public cls_committer committer;
		public List<String> added;
		public List<String> removed;
		public List<String> modified;

       public  head_commit (String id, String tree_id, Boolean distinct, String message,String timestamp, String url ,cls_author author, cls_committer committer,List<String> added,List<String> removed,List<String> modified){
           id = id; 
           tree_id = tree_id;
           distinct = distinct;
           message = message;
           timestamp = timestamp;
           url = url;
           author = author ;
           committer = committer ;
           added = added ;
           removed = removed;
           modified = modified;
       }
	}

    class cls_author {
		public String name;	//Sam
		public String email;	//ssb.formal@gmail.com
		public String username;	//ssbh
	} 
    class cls_committer {
		public String name;	//Sam
		public String email;	//ssb.formal@gmail.com
		public String username;	//ssbh
	}

    /*class cls_added {
	}
	class cls_removed {
	}
	class cls_modified {
    } */
    // wrapper class to send the sucess or failure message to Github 
    public class SFDCResponse {
        public String key ;
        public String value ;
        public SFDCResponse(String key, String value){
            key = key;
            value = value;
        }
      }

}
