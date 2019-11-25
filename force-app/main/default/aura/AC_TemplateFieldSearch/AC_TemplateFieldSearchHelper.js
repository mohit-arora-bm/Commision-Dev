({
    filterCriteriaFieldChange: function(component, event, helper, isSelected, selectedField) {
		var self = this;
		try {
			var value = $A.util.isEmpty(event.getSource().get("v.value")) ? selectedField : event.getSource().get("v.value");
			var filterOption = [];
			var productOptionBasedOnDataType = [];
			var fieldOptions = component.get('v.fieldOptions');
			var dataType;
			if(!$A.util.isEmpty(value)) {
				var selectedOption = {};
				if(!$A.util.isEmpty(fieldOptions)) {
					for(var i in fieldOptions){
						if(fieldOptions[i].value === value) {
							selectedOption = fieldOptions[i];
							break;
						}
					}
                }
                component.set('v.selectedOption', value);
                component.set('v.isFieldRelated', false);
				if(!value.includes('-') || isSelected) {
					var fieldsList = component.get('v.fieldsList');
					if(isSelected) {
						var selectedField = fieldsList.filter(obj => {
							return obj.value === value
						});
						selectedOption.dataType = selectedField.displayType.toLowerCase();
					}
					var eventParamsObj = {
						isFieldRelated: component.get('v.isFieldRelated'),
						selectedOption: value,
						selectedOptionObj: component.get('v.selectedOptionObj')
					};
					self.fireFieldSelectedEvent(component, event, eventParamsObj);
				} else {
					var fieldMeta = {
						fieldLabel        : selectedOption.label,
						fieldAPIName      : selectedOption.value,
						relatedObjectName : selectedOption.relatedObjectName,
						relationshipName  : selectedOption.relationshipName,
						isRelated         : selectedOption.isRelated,
						dataType          : selectedOption.dataType,
						isUpdateable      : selectedOption.isUpdateable
					};
					var eventAdditionalParam = {
						type : 'Field',
						index : null,
					};
                    self.createRelationComponent(component, event, fieldMeta, eventAdditionalParam);
				}
            } else {
				component.set('v.selectedOption', value);
			}
		} catch(e) {
			console.log(e);
			// component.find('dataService').logException('AQ_ProductFilterCriteria -> filterCriteriaFieldChange ' + e.name, e.message);
		}
    },
    createRelationComponent: function(component, event, fieldMetaArg, eventAdditionalParam) {
        try {
            var self = this;
            $A.createComponent(
                'c:AC_SelectLookUpField',
                {
                    "aura:id": 'selectLookUpComponent',
                    "fieldMeta" : fieldMetaArg,
                    "eventAdditionalParam" : eventAdditionalParam,
                    "showCancelButton": true
                },
                function(newComponent, status, errorMessage){
                    if(status === "SUCCESS") {
                    	component.find('LookUpSelectionComponent').set("v.body", newComponent);
                    }else if (status === "ERROR") {
                      
                    }
                }
            );
        } catch(e) {
            component.find('dataService').logException('AC_ProductFilterCriteria -> createRelationComponent ' + e.name, e.message);
        }
	},
	fireFieldSelectedEvent: function(component, event, eventParamsObj) {
		eventParamsObj.index = component.get('v.indexVar');
		eventParamsObj.type = component.get('v.type');
		component.getEvent('AC_FieldSelectedEvt').setParams({
			eventParamsObj: eventParamsObj
		}).fire();
	},
	validateCompHelper: function(component, event) {
		let fieldSearchInput = component.find('fieldSearchInput');
		let fieldSearchInputArr = Array.isArray(fieldSearchInput) ? fieldSearchInput : [fieldSearchInput];
		let isValid = fieldSearchInputArr.reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
		component.set('v.hasError', !isValid);
	}
})