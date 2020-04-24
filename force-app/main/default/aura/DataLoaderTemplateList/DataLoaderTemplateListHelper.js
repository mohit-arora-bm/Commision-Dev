({
	doInitHelper: function(component) {
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
				console.log(response);
				if(! $A.util.isEmpty( response ) ) {
					
					component.set('v.allData', response);
					component.set('v.searchedData', response);

					
					var templateName;
					var firstIndexedRecord = response[0].fieldsList;
					for(var fld in firstIndexedRecord) {
						if( firstIndexedRecord[fld].fieldAPIName == 'Name' ) {
							templateName = firstIndexedRecord[fld].fieldValue;
						}
					}

					component.set('v.selectedRowId', response[0].recordId);
					//component.set('v.selectedRowName', templateName);

					var eventParamsObj = {
						type: 'recordSelect',
						templateId: response[0].recordId,
						templateName: templateName
					};
					$A.get('e.c:AQ_GenericEvent').setParams({
						eventParamsObj: eventParamsObj
					}).fire();
					
				}else {
					component.set('v.selectedRowId', '');
					var eventParamsObj = {
						type: 'recordSelect',
						templateId: '',
						templateName: ''
					};
					$A.get('e.c:AQ_GenericEvent').setParams({
						eventParamsObj: eventParamsObj
					}).fire();
				}

				self.hideSpinner(component);
			})).catch(function (error) {
				self.hideSpinner(component);
				component.find('dataService').logException('AQ_GenericControlList -> doInitHelper ' + error.name, error.message);
			});
		} catch(e) {
			self.hideSpinner(component);
			component.find('dataService').logException('DataLoaderListHelper -> doInitHelper ' + e.name, e.message);
		}
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
				self.doInitHelper(component);
				self.hideSpinner(component);
			})).catch(function (error) {
				self.hideSpinner(component);
				component.find('dataService').logException('DataLoaderListHelper -> deleteRowHelper ' + error.name, error.message);
			});
		} catch(e) {
			self.hideSpinner(component);
			component.find('dataService').logException('DataLoaderListHelper -> deleteRowHelper ' + e.name, e.message);
		}
	},

	showSpinner: function(component) {
		$A.util.removeClass(component.find('spinner'), 'slds-hide');
	},
	hideSpinner: function(component) {
		$A.util.addClass(component.find('spinner'), 'slds-hide');
	},
})