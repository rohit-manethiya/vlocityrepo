global with sharing class XOMRetryFailSupplementalOrderLifeCycle implements vlocity_cmt.VlocityOpenInterface {

    global Boolean invokeMethod(String methodName,
                                Map<String, Object> input,
                                Map<String, Object> output,
                                Map<String, Object> options)
    {
        Id cartId = (Id)input.get('cartId');
        if (methodName == 'preValidate'){
            preValidate(input, output, options);
            return true;
        }
        else if(methodName == 'checkSubmitStatus'){
            checkSubmitStatus(input, output, options);
            return true;
        }
        else if(methodName == 'submit'){
            submit(input, output, options);
            return true;
        }
        else if(methodName == 'submitCancelOrder'){
            submitCancelOrder(input, output, options);
            return true;
        }
        else if(methodName == 'cancelSupplementalOrder'){
            cancelSupplementalOrder(input, output, options);
            return true;
        }
        return false;
    }
    
    /*
    The XOM implementation to prevalidate the order to decide whether we can do cancel order or not.
    In the default implementation it will return PONRStatus as false so we can do cancel order.
    */
    public void preValidate(Map<String, Object> input,
                                Map<String, Object> output,
                                Map<String, Object> options){
        Boolean ponrStatus = false;
        Id cartId = (Id)input.get('cartId');
        SObject cartObj = [SELECT vlocity_cmt__OrderStatus__c, vlocity_cmt__IsChangesAllowed__c FROM Order WHERE ID =: cartId];
        String orderStatus = (String)cartObj.get('vlocity_cmt__OrderStatus__c');
        Boolean changesAllowed = (Boolean)cartObj.get('vlocity_cmt__IsChangesAllowed__c');
        if(orderStatus != null && orderStatus.equalsIgnoreCase('In Progress') && changesAllowed == true)
            ponrStatus = false;
        else
            ponrStatus = true;            
        /*Temp*/
        if(input.get('PONRStatus') != null){
            ponrStatus = (Boolean)input.get('PONRStatus');
        }
        if(input.get('SubmitStatus') != null && (String)input.get('SubmitStatus') == 'PONR'){
            ponrStatus = true;
        }
        /*Temp*/
        output.put('PONRStatus', ponrStatus);
        return;
    }

    /*
    The XOM implementation to submit the Cancel Order
    In the default implementation the cancel is always successful.
    */
    public void checkSubmitStatus(Map<String, Object> input,
                                Map<String, Object> output,
                                Map<String, Object> options){
        output.put('submitStatus', 'Failed');
        return;
    }

    public void submit(Map<String, Object> input,
                                Map<String, Object> output,
                                Map<String, Object> options){
        output.put('submitStatus', 'Complete');
        return;
    }
    /*
    The XOM implementation to submit the Cancel Order
    In the default implementation the cancel is always successful.
    */
    public void submitCancelOrder(Map<String, Object> input,
                                Map<String, Object> output,
                                Map<String, Object> options){
        Id cartId = (Id)input.get('cartId');
        SObject cartObj = new Order();
        cartObj.put('Id', cartId);
        cartObj.put('vlocity_cmt__IsChangesAllowed__c', false);
        cartObj.put('vlocity_cmt__IsChangesAccepted__c', true);
        update cartObj;
        output.put('submitStatus', 'Retry');
        output.put('submitMessage', 'Waiting for cancellation');
        output.put('retryStatus', 'Failed');
        output.put('retryMessage', 'Cancel Failed');
        return;
    }
    public void cancelSupplementalOrder(Map<String, Object> input,
                                Map<String, Object> output,
                                Map<String, Object> options){
        return;
    }
}