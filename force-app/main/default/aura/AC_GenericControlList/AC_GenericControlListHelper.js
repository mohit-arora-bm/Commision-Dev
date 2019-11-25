({
	doInitHelper: function(component, fireNewTemplateEvent, selectedRecordId) {
		var self = this;
		try {
			self.showSpinner(component);
			var dataService = component.find('dataService');
			var action = component.get('c.fetchRecords');
			action.setParams({
				objectAPIName: component.get('v.objectAPIName'),
				fieldsListJSON: JSON.stringify(component.get('v.fieldsList'))
			});
			dataService.fetch(action).then($A.getCallback(function (response) {
				component.set('v.allData', response);
				if(!$A.util.isEmpty(response)) {
					if(!$A.util.isEmpty(response).length && !$A.util.isEmpty(response[0]) && component.get('v.isProductSearch')) {
						component.set('v.disableNewButtion', true);
					}
					
					var columns = [];
					for(var index in response[0].fieldsList) {
						columns.push(response[0].fieldsList[index].fieldLabel);
					}
					component.set('v.columns', columns);

					// Get templates for Uniqueness
					var templates = [];
					for(var res in response ) {
						var recordId = response[res].recordId;
						var fieldsList = response[res].fieldsList;
						for(var fld in fieldsList ) {
							templates.push(fieldsList[fld].fieldValue+'#'+recordId);
						}
					}
					self.searchInit(component, fireNewTemplateEvent, selectedRecordId, templates);
					
					
				}
				self.hideSpinner(component);
			})).catch(function (error) {
				self.hideSpinner(component);
				component.find('dataService').logException('AC_GenericControlList -> doInitHelper ' + error.name, error.message);
			});
		} catch(e) {
			self.hideSpinner(component);
			component.find('dataService').logException('AC_GenericControlList -> doInitHelper ' + e.name, e.message);
		}
	},
	showSpinner: function(component) {
		$A.util.removeClass(component.find('spinner'), 'slds-hide');
	},
	hideSpinner: function(component) {
		$A.util.addClass(component.find('spinner'), 'slds-hide');
	},
	deleteRowHelper: function(component, event, recordId) {
		var self = this;
		try {
			var dataService = component.find('dataService');
			var action = component.get('c.deleteRowApex');
			action.setParams({
				recordId: recordId
			});
			dataService.fetch(action).then($A.getCallback(function (response) {
				component.set('v.selectedRowId', '');
				component.set('v.showDeleteModal', false);
				$A.get('e.force:refreshView').fire();
				self.doInitHelper(component, true);
				self.hideSpinner(component);
			})).catch(function (error) {
				self.hideSpinner(component);
                component.set('v.showDeleteModal', false);
				//component.find('dataService').logException('AQ_GenericControlList -> deleteRowHelper ' + error.name, error.message);
			});
		} catch(e) {
			self.hideSpinner(component);
			//component.find('dataService').logException('AQ_GenericControlList -> deleteRowHelper ' + e.name, e.message);
		}
	},
	searchInit: function(component, fireNewTemplateEvent, recordId, templates ) {
		var allData = component.get('v.allData');
		if(!$A.util.isEmpty(allData)) {
			if($A.util.isEmpty(recordId)) {
				recordId = !$A.util.isEmpty(allData) && !$A.util.isEmpty(allData[0]) && !$A.util.isEmpty(allData[0].recordId) ? allData[0].recordId : '' ;
			}
			$A.get('e.c:AC_GenericControlRecordSelectEvt').setParams({
				eventParamsObj: {
					type: 'recordSelect',
					recordId: fireNewTemplateEvent ? '' : recordId
				}
			}).fire();

			$A.get('e.c:AC_GenericControlRecordSelectEvt').setParams({
				eventParamsObj: {
					type: 'templateNames',
					templates: templates
				}
			}).fire();

		
			component.set('v.selectedRowId', fireNewTemplateEvent ? '' : ($A.util.isEmpty(recordId) ? '' : recordId));
		}
	}
})