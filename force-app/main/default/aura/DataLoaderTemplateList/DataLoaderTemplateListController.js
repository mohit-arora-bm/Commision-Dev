({
	doInit: function(component, event, helper) {
		helper.doInitHelper(component);
	},
	createNewTemplate:function(component, event, helper) {
		component.set('v.selectedRowId', '');
		var eventParamsObj = {
			type: 'recordSelect',
			templateId: '',
			templateName: ''
		};
		$A.get('e.c:AQ_GenericEvent').setParams({
			eventParamsObj: eventParamsObj
		}).fire();
	},

	handleRowSelect: function(component, event) {
		try {
			var selectedId = event.target.id;
			var templateName =  event.target.innerText;
			component.set('v.selectedRowId', selectedId);
			var eventParamsObj = {
            	type: 'recordSelect',
				templateId: selectedId,
				templateName: templateName
            };
            $A.get('e.c:AQ_GenericEvent').setParams({
            	eventParamsObj: eventParamsObj
            }).fire();
			
			
		} catch(e) {
			helper.hideSpinner(component);
			component.find('dataService').logException('DataLoaderTemplateList -> handleRowSelect ' + e.name, e.message);
		}
	},
	searchProducts: function(component, event, helper) {
		helper.showSpinner(component);
		var searchedText = event.currentTarget.value;
		var allData = component.get('v.allData');
		var searchedData = [];

		if(! $A.util.isEmpty(searchedText) ) {
			for(var dat in allData) {
				var fieldList = allData[dat].fieldsList;
				for( var fld in fieldList) {
					if( ! $A.util.isEmpty( fieldList[fld].fieldValue ) ) {
						var fieldValue = fieldList[fld].fieldValue.toLowerCase();
						if( ( ! $A.util.isEmpty(searchedText) ) && fieldList[fld].fieldAPIName == 'Name' && fieldValue.includes( searchedText.toLowerCase() ) ) {
							searchedData.push(allData[dat]);
						}
					}
				}
			}
			component.set('v.searchedData', searchedData);
			helper.hideSpinner(component);
		}else {
			component.set('v.searchedData', allData);
			helper.hideSpinner(component);
		}	
	},
	deleteRow: function(component, event) {
		component.set('v.showDeleteModal', true);
		var recordId = event.getSource().get('v.alternativeText');
		component.set('v.deleteRecordId', recordId);
	},
	cancelDelete: function(component) {
		component.set('v.showDeleteModal', false);
	},
	deleteTemplate: function(component, event, helper) {
		helper.showSpinner(component);
		var recordId = component.get('v.deleteRecordId');
		helper.deleteRowHelper(component, event, recordId);
	},
})