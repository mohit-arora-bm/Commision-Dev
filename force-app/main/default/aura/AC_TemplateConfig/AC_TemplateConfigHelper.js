/* eslint-disable no-undef */
/* eslint-disable no-unreachable */
/* eslint-disable no-else-return */
/* eslint-disable guard-for-in */
/* eslint-disable no-unused-vars */
/* eslint-disable vars-on-top */
/* eslint-disable no-unused-expressions */
({
	fetchSobjectFields : function(component, sObjectName) {
		var self = this;
		self.showSpinner(component);
		component.set('v.initCompleted',false);
		var dataService = component.find('dataService');
		var action = component.get('c.fetchDescribedFields');
		action.setParams({'sObjectName': sObjectName});
		dataService.fetch(action)
		.then($A.getCallback(function (response) {
			console.log(response);
			if(!$A.util.isEmpty(response)) {
				component.set('v.fieldOptions', response);
				component.set('v.allFieldOptions',response);
				let onlyReferenceField = [];
				for(let key in response) {
					if (!response[key].value.includes('-') && (response[key].displayType == "REFERENCE" || response[key].displayType == "ID")) {
						onlyReferenceField.push(response[key]);
					}
				}
				component.set('v.onlyReferenceField',onlyReferenceField);
			}
			
			component.set('v.initCompleted',true);
			self.hideSpinner(component);
		})).catch(function (error) {
			component.set('v.initCompleted',true);
			self.logError(component, 'fetchSobjectFields', error.name, error.message);
		});
	},


	commitDataHelper : function(component, helper, recordSelectEvent) {
		try{
			helper.showSpinner(component);
			let templateConfigObject = component.get('v.templateConfigObject');
			let dataList = component.get("v.dataList");
			let templateNames = component.get('v.templateNames');
			console.log('templateNames '+templateNames);
			let isDuplicate = false;

			for(let tempName in templateNames) {
				let templateNameId = templateNames[tempName].includes('#') ? templateNames[tempName].split('#') : templateNames[tempName];
				if( Array.isArray(templateNameId) ) {
					if( ( (! $A.util.isEmpty(component.get('v.recordId')) ) && templateNameId[1].trim() != component.get('v.recordId') && templateNameId[0].trim().toLowerCase() == templateConfigObject.templateName.trim().toLowerCase() ) 
					|| ( $A.util.isEmpty(component.get('v.recordId')) && templateNameId[0].trim().toLowerCase() == templateConfigObject.templateName.trim().toLowerCase()) ) {
						isDuplicate = true;
					}
				}
			}
			if( isDuplicate ) {
				helper.showToast(component, 'Error', 'error', 'Template Names cannot be same.');
				helper.hideSpinner(component);
				return;
			}
				
			templateConfigObject.dataList = dataList;
			console.log(templateConfigObject);
		
			var dataService = component.find('dataService');
			var templateId = component.get('v.recordId');
			var action = component.get('c.saveTemplateData');
			let className = templateConfigObject.templateName.replace(/[^a-zA-Z]/g, "");
			className += new Date().getTime();
			console.log('AC_BatchClassName= ',className);
			action.setParams({
				templateId : templateId,
				templateName: templateConfigObject.templateName,
				objectName : component.get("v.selectedTemplateObject"),
				dataJson: JSON.stringify(templateConfigObject.dataList),
				className : className
			});

			dataService.fetch(action).then($A.getCallback(function (response) {
				let recordId = component.get('v.recordId');
				component.set('v.recordId', response);
				
				if(!$A.util.isEmpty(recordId)) {
					helper.showToast(component, 'Success', 'success', 'Template record updated successfully');
	
					helper.refreshComponent(component,recordSelectEvent,helper);
					
				} else {
					helper.showToast(component, 'Success', 'success', 'Template record created successfully');
					let vfOrigin = component.get("v.vfHost");
					let vfWindow = component.find("vfFrame").getElement().contentWindow;
					vfWindow.postMessage(className, vfOrigin);
				}
				
			})).catch(function (error) {
				helper.logError(component, 'commitDataHelper', error.name, error.message);
			});
		}catch(e){
			self.logError(component, 'commitDataHelper', e.name, e.message);
		}
	},
	refreshComponent: function(component,recordSelectEvent,helper) {
		let eventParamsObj = {
			type: 'refresh',
			recordId: component.get('v.recordId')
		};
		recordSelectEvent.setParams({
			eventParamsObj: eventParamsObj
		}).fire();
		helper.hideSpinner(component);
	},
	validateDataHelper: function(component, event, dataList) {
		let sectionDescription = component.find('sectionDescription');
		let sectionDescriptionArr = Array.isArray(sectionDescription) ? sectionDescription : [sectionDescription];
		for(let index in dataList) {
			sectionDescriptionArr[index].showHelpMessageIfInvalid();
		}
		return dataList;
	},
	logError : function(component, methodName, errorName, errorMessage) {
		this.hideSpinner(component);
		console.error(methodName,errorName,errorMessage);
		component.find('dataService').logException('AC_AgileQuoteTemplateConfig -> ' + methodName + errorName, errorMessage);
	},
	showToast : function(component, title, type, message) {
		$A.get('e.force:showToast').setParams({
			title: title,
			message: message,
			type: type
		}).fire();
	},
	getFieldPayload : function(component) {
		var fieldPayload = {
			customLabel : '',
			selectedField : 'none',
			dataType: '',
			func : '',
			apexDataType: '',
			isFieldRelated: false,
			selectedFieldObj: {} 
		};
		return fieldPayload;
	},
	getFilterPayload : function(component) {
		var filterPayload = {
			operations : [],
			label : '', 
			fieldType : 'text',
			filterValue : '',
			operation : '',

		};
		return filterPayload;
	},
	getDataPayload : function(component) {
		var dataPayload = {
			selectedFieldOptions : [this.getFieldPayload(component)],
			selectedFilters : [this.getFilterPayload(component)],
			description : '',
			documentField : {
				isFieldRelated : false,
				selectedField : ''
			},
			accountField : {
				isFieldRelated : false,
				selectedField : ''
			},
			isOpen : true,
			filterOptions : [],
			selectedFilterCombo : 'AND',
			filterCombo : '',
			isCustom : false
		};
		return dataPayload;
	},
	getOjectPayload : function(component) {
		var templateConfigObject = {
			templateName : '',
			objectName : '',
            fieldList : []
        };
		return templateConfigObject;
	},
	hideSpinner : function( component ) {
        $A.util.addClass(component.find("Spinner"), "slds-hide");
    },
    showSpinner : function( component ) {
        $A.util.removeClass(component.find("Spinner"), "slds-hide");
	},
})