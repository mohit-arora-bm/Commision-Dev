({
    validateComp: function(component, event, helper) {
        let templateForm = component.find('templateForm');
        if(!$A.util.isEmpty(templateForm)) {
            templateForm = Array.isArray(templateForm) ? templateForm : [templateForm];
            let errorList = templateForm.filter(obj => {
                return $A.util.isEmpty(obj.get('v.value'))
            });
            for(let index in errorList) {
                errorList[index].showHelpMessageIfInvalid();
            }
            component.set('v.hasError', !$A.util.isEmpty(errorList) && errorList.length > 0 ? true : false);
        }
    }
})