({ 
    doInit : function(component, event, helper) {
        let action = component.get("c.fetchTeam");
        action.setParams({
            teamId : component.get("v.teamId")
        });
        action.setCallback(this,function(res) {
            let data = res.getReturnValue();
            component.set('v.team',data[0]);
        });
        $A.enqueueAction(action);
    },
    handleSubmit : function(component, event, helper) {
        // component.set('v.disabled', true);   
        event.preventDefault(); // stop form submission
        let eventFields = event.getParam("fields");
        if (!eventFields.agileComp__Adjustment_Description__c) {
            helper.showToast(component, 'Error', 'error', 'Description field is required'); 
            return;
        }
        var externalTeanAdjId = '';
        if(!$A.util.isEmpty(component.get("v.oldRecord"))){
            externalTeanAdjId = component.get("v.oldRecord.agileComp__Team_Adjustment_Id__c")
        }
        console.log('component.get("v.periodId")'+component.get("v.periodId"));
        let action = component.get('c.createAdj');
        action.setParams({
            teamId : component.get("v.team").Id,
            objJSON : JSON.stringify(eventFields),
            periodId : component.get("v.periodId"),
            externalId : externalTeanAdjId
        });
        action.setCallback(this,function(res) {
            console.log('in callback');
            setTimeout(function(){ component.destroy(); }, 1);
            
            component.getEvent("refreshEmp").fire();
        });
        $A.enqueueAction(action);
        
    },
    Cancel : function(component, event, helper) {
        component.destroy();
    } 
})