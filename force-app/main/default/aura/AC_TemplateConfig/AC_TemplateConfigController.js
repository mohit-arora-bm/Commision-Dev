/* eslint-disable no-unreachable */
/* eslint-disable no-else-return */
/* eslint-disable guard-for-in */
/* eslint-disable no-unused-vars */
/* eslint-disable vars-on-top */
/* eslint-disable no-unused-expressions */
({
	doInit: function (component, event, helper) {
		var recordSelectEvent = $A.get('e.c:AC_GenericControlRecordSelectEvt');
		let totalPageURL = window.location.toString();
		let protocalType= totalPageURL.split("//")[0];
		let tempbaseURL = totalPageURL.split("//")[1].split("/");
		let finalBaseURL = protocalType+'//'+tempbaseURL[0];
		finalBaseURL = finalBaseURL.replace('.lightning.force.com', '--agilecomp.visualforce.com');
		component.set("v.vfHost",finalBaseURL);
		window.addEventListener("message", function(ev) {
            if (ev.origin !== finalBaseURL) {
                // Not the expected origin: Reject the message!
                return;
			}
			helper.refreshComponent(component,recordSelectEvent,helper);
        }, false);
		component.set("v.templateConfigObject",{});
		let action = component.get("c.getTemplateConfigData");
		action.setParams({
			'templateId' : component.get("v.recordId")
		});
		let dataService = component.find('dataService');
		dataService.fetch(action)
		.then($A.getCallback(function (response) {
			console.log(response);
			if(!$A.util.isEmpty(response)) {
				component.set('v.mappingFields', response.mappingFields);
				component.set("v.dataTypeMap",response.dataTypeOptionMap);
				if (!response.templateConfigObject.Id) {
					component.set('v.initCompleted',true);
					helper.hideSpinner(component);
					return;
				}
				component.set("v.lastSuccessDate",response.lastSuccessDate)
				component.set('v.fieldOptions', response.fieldsList);
				component.set('v.allFieldOptions',response.fieldsList);
				let onlyReferenceField = [];
				for(let key in response.fieldsList) {
					if (!response.fieldsList[key].value.includes('-') && (response.fieldsList[key].displayType == "REFERENCE" || response.fieldsList[key].displayType == "ID")) {
						onlyReferenceField.push(response.fieldsList[key]);
					}
				}
				component.set('v.onlyReferenceField',onlyReferenceField);
				component.set('v.isScheduled',response.isScheduled);
				component.set('v.selectedTemplateObject',response.templateConfigObject.agileComp__AC_Object__c);
				let templateConfigObject = response.templateConfigObject;
				templateConfigObject.templateName = templateConfigObject.agileComp__AC_Name__c;
				component.set('v.templateConfigObject',templateConfigObject);
				let dataList = JSON.parse(response.templateConfigObject.agileComp__AC_TemplateDataJson__c);
				component.set('v.dataList', dataList);
				component.find("dynamicObjectLookup").reload();
			}
			component.set('v.initCompleted',true);
			helper.hideSpinner(component);
		})).catch(function (error) {
			component.set('v.initCompleted',true);
			helper.logError(component, 'doInit', error.name, error.message);
		});
	},
	addDataRow : function (component, event, helper) {
		let dataList = component.get("v.dataList");
		let eventParamsObj = event.getParam('eventParamsObj');
		if(eventParamsObj.addDataRow === true) {
			for(let key in dataList) {
				dataList[key].isOpen = false;
			}
			dataList.push(helper.getDataPayload(component));
			
		} else if(eventParamsObj.addDataRow === false) {
			let removeIndex = eventParamsObj.rowNo;
			dataList.splice(removeIndex, 1);
		}
		component.set("v.dataList", dataList);
	},
	handleObjectChange: function (component, event, helper) {
		try {
			let objectName = component.get('v.selectedTemplateObject');
			if (!$A.util.isEmpty(objectName)) {
				component.set('v.dataList', [helper.getDataPayload(component)]);
				helper.fetchSobjectFields(component, objectName);
			}
		} catch (e) {
			helper.logError(component, 'handleObjectChange', e.name, e.message);
		}
	},
	runNow: function (component, event, helper) {
		try {
			let recordId = component.get("v.recordId");
			let action = component.get("c.testNow");
			action.setParams({
				'recordId' : recordId
			});
			let dataService = component.find('dataService');
			dataService.fetch(action)
			.then($A.getCallback(function (response) {
				helper.showToast(component, 'Success', 'success', 'Your template batch is successfully scheduled.');
			})).catch(function (error) {
				helper.logError(component, 'runNow', error.name, error.message);
			});
		} catch (e) {
			helper.logError(component, 'runNow', e.name, e.message);
		}
	},
	
	saveTemplateRecord: function (component, event, helper) {
		try {
			let selectedTemplateObject = component.get("v.selectedTemplateObject");
			if ($A.util.isEmpty(selectedTemplateObject)) {
				helper.showToast(component, 'Error', 'error', 'Please select an Object');
				return;
			}
			if(!component.get('v.templateConfigObject').templateName) {
				helper.showToast(component, 'Error', 'error', 'Please select Template Name');
				return;
			}
			let fieldsDataContainer = component.find('fieldsDataContainer');
			let fieldsDataContainerArr = Array.isArray(fieldsDataContainer) ? fieldsDataContainer : [fieldsDataContainer];
			let hasError = false;
			let dataList = [];
			let dList = component.get("v.dataList");
			for(let key in dList) {
				dList[key].isOpen = true;
				dList[key].hasError = false;
			}
			component.set("v.dataList",dList);
			let recordSelectEvent = $A.get('e.c:AC_GenericControlRecordSelectEvt');
			setTimeout(function() {
				for(let index in fieldsDataContainerArr) { 
					fieldsDataContainerArr[index].validateComponent();
					dataList.push(fieldsDataContainerArr[index].get('v.data'));
					console.log(JSON.stringify(fieldsDataContainerArr[index].get('v.data')));
					if (fieldsDataContainerArr[index].get('v.data').hasError) {
						hasError = true;
					}
				}
				component.set("v.dataList",dataList);
				console.log(hasError, '*********');
				if (!hasError) {
					helper.commitDataHelper(component, helper, recordSelectEvent);
				} else {
					helper.showToast(component, 'Error', 'error', 'Please review errors on this page.');
				}
			}, 1000);
			/*let dataList = component.get("v.dataList");
			console.log(dataList);
			for(let key in dataList) {
				dataList[key].isOpen = true;
			}
			component.set("v.dataList", dataList);
			dataList = helper.validateDataHelper(component, event, dataList);
			component.set('v.dataList', dataList);
			let erroredItems = dataList.filter(obj => {
				return obj.hasError
			});
			if(!$A.util.isEmpty(erroredItems) && erroredItems.length > 0) {
				return;
			}*/
			//helper.showSpinner(component);
			// let recordSelectEvent = $A.get('e.c:AC_GenericControlRecordSelectEvt');
			//setTimeout(function(){ helper.commitDataHelper(component, helper,recordSelectEvent) }, 1000);
		} catch(e) {
			helper.logError(component, 'saveTemplateRecord', e.name, e.message);
		}
	},
	cloneDataRow: function(component, event, helper) {
		try {
			let dataList = component.get('v.dataList');
			let eventParamsObj = event.getParam('eventParamsObj');
			let dataItem = eventParamsObj.data;
			dataList.splice(dataList.length, 0, dataItem);
			component.set('v.dataList', dataList);
		} catch(e) {
			helper.logError(component, 'cloneDataRow', e.name, e.message);
		}
	}
})