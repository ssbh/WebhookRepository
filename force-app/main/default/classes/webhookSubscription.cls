/**
 * @description       : Class to handle webhooks form GitHub 
 * @author            : Sam Belete
 * @group             : 
 * @last modified on  : 09-14-2021
 * @last modified by  : Sam Belete
**/
@RestResource (urlMapping='/api/Webhook/incoming/pushDetail/*')
//https://samrawit-belete-developer-edition.na163.force.com/Services/apexrest//api/Webhook/incoming/pushDetail
global with sharing class webhookSubscription {
    @HttpPost 
    global static void handleNotification (){
     
     try {
     //request 
    // RestRequest request =RestContext.request;
    // RestResponse response= RestContext.response;
     
     //Blob requestBody = request.requestBody;
    }catch(Exception e){
    system.debug('Exception happend:' + e.getMessage());
    
    }
    
    
    }
}
