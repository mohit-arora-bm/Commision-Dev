/* eslint-disable no-unused-vars */
/* eslint-disable vars-on-top */
/* eslint-disable no-unused-expressions */
({
	handleFieldChange: function(component, event, helper) {
		try {
			helper.handleFieldChangeHelper(component, event, event.getParam('eventParamsObj'));  
		} catch (e) {
			helper.logError(component, 'handleFieldChange', e.name, e.message);
		}
	},
	handleFilterCombo: function(component,event,helper){
		let data = component.get("v.data");

        if( data.selectedFilterCombo == 'Custom' ) {
            data.isCustom = true;
        }else{
            data.isCustom = false;
        }
		component.set("v.data",data);
    },
    validateComponent: function(component, event, helper) {
        helper.validateComponentHelper(component, event, helper);
    },
    closeAcc: function(component, event, helper) {
        let data = component.get('v.data');
        data.isOpen = false;
        component.set('v.data', data);
    },
    openAcc: function(component, event, helper) {
        let data = component.get('v.data'); 
        data.isOpen = true;
        component.set('v.data', data);
    },
    addDataRow: function(component, event, helper) {
        component.getEvent('dataRowEvent').setParams({
            eventParamsObj: {
                addDataRow: true
            }
        }).fire();
    },
    removeDataRow: function(component, event, helper) {
		component.getEvent('dataRowEvent').setParams({
            eventParamsObj: {
				addDataRow: false,
				rowNo: component.get('v.rowNo')
            }
        }).fire();
        component.destroy();
    },
    addFieldRow: function(component, event, helper) {
        try {
            let data = component.get('v.data');
			let fieldPayload = helper.getFieldPayload(component);
			data.selectedFieldOptions.push(fieldPayload);
			component.set('v.data', data);
		} catch (e) {
			helper.logError(component, 'addFieldRow', e.name, e.message);
		}
    },
    removeFieldRow: function(component, event, helper) {
        try {
			let index = event.getSource().get('v.name');
			let data = component.get('v.data');
			let removedFld = data.selectedFieldOptions.splice(index, 1);
			let filterOptions = data.filterOptions;
			if (filterOptions.length > index) {
				data.filterOptions.splice(index, 1);
			}
			component.set('v.data', data);
		} catch (e) {
			helper.logError(component, 'removeFieldRow', e.name, e.message);
		}
    },
    
    addFilterRow: function(component, event, helper) {
        try {
			let data = component.get('v.data');
			let filterPayload = helper.getFilterPayload(component);
			data.selectedFilters.push(filterPayload);
			component.set('v.data', data);
		} catch (e) {
			helper.logError(component, 'addFilterRow', e.name, e.message);
		}
    },
    removeFilterRow: function(component, event, helper) {
        try {
			let index = event.getSource().get("v.name");
			let data = component.get('v.data');
			data.selectedFilters.splice(index, 1);
			component.set('v.data', data);
		} catch (e) {
			helper.logError(component, 'removeFilterRow', e.name, e.message);
		}
	},
	cloneSection: function(component, event, helper) {
		try {
			console.log('clone called');
			let data = component.get('v.data');
			component.getEvent('cloneSectionEvent').setParams({
				eventParamsObj: {
					data: data
				}
			}).fire();
		} catch (e) {
			helper.logError(component, 'cloneSection', e.name, e.message);
		}
	},
	useLastSuccess : function(component, event, helper) {
		try {
			let index = event.getSource().get('v.name');
			let data = component.get("v.data");
			console.log(data.selectedFilters[index].useLastSuccessDate);
			if (!data.selectedFilters[index].useLastSuccessDate) {
				data.selectedFilters[index].filterValue = ' ';
			}
			else {
				data.selectedFilters[index].filterValue = 'lastSuccessDate';
			}
			console.log(data.selectedFilters[index].filterValue);
			component.set("v.data",data);
		} catch (e) {
			helper.logError(component, 'useLastSuccess', e.name, e.message);
		}
	}
})