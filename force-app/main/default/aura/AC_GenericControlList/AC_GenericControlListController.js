({
	doInit: function(component, event, helper) {
		helper.doInitHelper(component);
	},
	handleRowSelect: function(component, event) {
		try {
            var selectedId = event.target.id;
            var eventParamsObj = {
            	type: 'recordSelect',
            	recordId: selectedId
            };
            $A.get('e.c:AC_GenericControlRecordSelectEvt').setParams({
            	eventParamsObj: eventParamsObj
            }).fire();
            component.set('v.selectedRowId', selectedId);
		} catch(e) {
			helper.hideSpinner(component);
			component.find('dataService').logException('AC_GenericControlList -> handleRowSelect ' + e.name, e.message);
		}
	},
	handlRefreshEvent: function(component, event, helper) {
		try {
			var eventParamsObj = event.getParam('eventParamsObj');
			if(eventParamsObj.type === 'refresh') {
				helper.doInitHelper(component, false, eventParamsObj.recordId);
			}
		} catch(e) {
			helper.hideSpinner(component);
			component.find('dataService').logException('AC_GenericControlList -> handlRefreshEvent ' + e.name, e.message);
		}
	},
	deleteRow: function(component, event) {
		component.set('v.showDeleteModal', true);
		var recordId = event.getSource().get('v.alternativeText');
		component.set('v.deleteRecordId', recordId);
	},
	unSchedule: function(component, event) {
		component.set('v.showUnScheduleModal', true);
		var recordId = event.getSource().get('v.alternativeText');
		component.set('v.unScheduleId', recordId);
		
	},
	cancelUnschedule: function(component) {
		component.set('v.showUnScheduleModal', false);
	},
	unScheduleTemplate: function(component, event, helper) {
		helper.showSpinner(component);
		var recordId = component.get('v.unScheduleId');
		var action = component.get("c.unScheduleJob");
		action.setParams({
			'templateId' : recordId
		});
		var dataService = component.find('dataService');
		dataService.fetch(action).then($A.getCallback(function (response) {
			component.set('v.showUnScheduleModal', false);
			$A.get('e.force:refreshView').fire();
			helper.doInitHelper(component, false);
			helper.hideSpinner(component);
		})).catch(function (error) {
			self.hideSpinner(component);
			component.find('dataService').logException('AC_GenericControlList -> doInitHelper ' + error.name, error.message);
		});
	},
	cancelDelete: function(component) {
		component.set('v.showDeleteModal', false);
	},
	deleteTemplate: function(component, event, helper) {
		helper.showSpinner(component);
		var recordId = component.get('v.deleteRecordId');
		helper.deleteRowHelper(component, event, recordId);
	}
})