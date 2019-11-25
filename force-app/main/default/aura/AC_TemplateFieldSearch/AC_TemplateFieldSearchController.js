({
    doInit: function(component, event, helper) {
        var isFieldRelated = component.get('v.isFieldRelated');
        var selectedOption = component.get('v.selectedOption');
        // component.set('v.selectedOptionOnCancel', selectedOption );
        if(isFieldRelated) {
            component.set('v.selectedOptionObj', JSON.parse(selectedOption));
        }
    },
    handleFilterFieldChange: function(component, event, helper) {
        console.log('wes caught');
        helper.filterCriteriaFieldChange(component, event, helper, false, '');
    },
    handleSetRelatedFieldEvent: function(component, event, helper) {
        if(! $A.util.isEmpty(event.getParam('eventParamsObj')) ) {
            console.log(event.getParam('eventParamsObj'));
            component.set('v.selectedOption', JSON.stringify(event.getParam('eventParamsObj')));
            component.set('v.selectedOptionObj', event.getParam('eventParamsObj'));
            component.set('v.isFieldRelated', true);
            var eventParamsObj = {
                isFieldRelated: component.get('v.isFieldRelated'),
                selectedOption: component.get('v.selectedOption'),
                selectedOptionObj: component.get('v.selectedOptionObj')
            };
            helper.fireFieldSelectedEvent(component, event, eventParamsObj);
        }else {
            component.set('v.selectedOption',  component.get('v.selectedOptionOnCancel') );
        }
    },
    handleRemoveLookUpField: function(component, event, helper) {
        component.set('v.isFieldRelated', false);
        component.set('v.selectedOption', '');
        component.set('v.selectedOptionObj', null);
        var eventParamsObj = {
            isFieldRelated: component.get('v.isFieldRelated'),
            selectedOption: component.get('v.selectedOption'),
            selectedOptionObj: component.get('v.selectedOptionObj')
        };
        helper.fireFieldSelectedEvent(component, event, eventParamsObj);
    },
    validateComp: function(component, event, helper) {
        helper.validateCompHelper(component, event);
    }
})