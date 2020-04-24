({
    handleSubmit : function(component, event, helper) {
        // component.set('v.disabled', true);
        event.preventDefault(); // stop form submission
        let eventFields = event.getParam("fields");
        let oldRecord = component.get("v.oldRecord");
        if(component.get("v.recordId")) {
            eventFields.Id = component.get("v.recordId");
        }
        else {
            eventFields.Id = oldRecord.Id;
        }
        // else {
        //     eventFields.Id = component.get("v.newRowId");
        // }
        if(oldRecord && oldRecord.Name) {
            eventFields.Name = oldRecord.Name;
        }
        console.log(JSON.stringify(eventFields));
        component.set("v.record",eventFields);
        component.destroy();
    },
    Cancel : function(component, event, helper) {
        component.destroy();
    }
})