({
    proceed : function(component, event, helper) {
        let selectedPeriod = component.get("v.selectedPeriod");
        let includeDetails = component.get("v.includeDetails");
        if(!selectedPeriod) {
            helper.showToast(component, 'Error', 'error', 'Please select period!');
            return;
        }
        helper.checkEmployee(component,selectedPeriod.Id,includeDetails); 
    }
})