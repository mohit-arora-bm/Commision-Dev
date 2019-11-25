/* eslint-disable guard-for-in */
/* eslint-disable no-unused-vars */
/* eslint-disable vars-on-top */
/* eslint-disable no-unused-expressions */
({
    handleFieldChangeHelper : function(component, event, eventParamsObj) {
        let self = this;
        try {
            if( (! $A.util.isEmpty(eventParamsObj)) && (! $A.util.isEmpty(eventParamsObj.selectedOption) )  ) {
                self.showSpinner(component);
                let dataService = component.find('dataService');
                let action = component.get('c.returnFieldDataType');
                let objectAPIName = component.get('v.selectedTemplateObject');
                action.setParams({ 
                    selectedFieldJSON: JSON.stringify(eventParamsObj),
                    objectAPIName: objectAPIName
                });
                dataService.fetch(action).then($A.getCallback(function (response) {
                    console.log(response);
                    console.log(JSON.stringify(eventParamsObj));
                    response = JSON.parse(response);
                    let ind = eventParamsObj.index;
                    let data = component.get("v.data");
                    console.log(data);
                    if (eventParamsObj.type == 'Account') {
                        if(response.relatedObjectName != 'Account' && !( objectAPIName == 'Account' &&  !eventParamsObj.isFieldRelated && eventParamsObj.selectedOption == 'Id')) {
                            self.showToast(component, 'Error', 'error', 'The selected field has to be Account.');
                            
                            data.accountField.selectedField = null;
                            component.set("v.data",data);
                        }
                        self.hideSpinner(component);
                        return;
                    }
                    else if(eventParamsObj.type == 'Document') {
                        if(response.dataType != 'REFERENCE' && eventParamsObj.selectedOption != 'Id') {
                            self.showToast(component, 'Error', 'error', 'The selected field has to be a Lookup.');
                            data.documentField.selectedField = null;
                            component.set("v.data",data);
                        }
                        else {
                            data.documentField.relatedObjectName = response.relatedObjectName;
                        }
                        self.hideSpinner(component);
                        return;
                    }
                    
                    // let selectedFieldOptions = data.selectedFieldOptions;
                    let selectedFieldOptions = [];
                    if (eventParamsObj.type === 'selection') {
                        selectedFieldOptions = data.selectedFieldOptions;
                    }
                    else if (eventParamsObj.type === 'filter') {
                        selectedFieldOptions = data.selectedFilters;
                    }
                    let apexFieldType = response.dataType;
                    let fieldType = self.getFieldType(apexFieldType);
                    console.log('selectedFieldOptions',selectedFieldOptions);
                    selectedFieldOptions[ind].dataType = fieldType;
                    selectedFieldOptions[ind].apexDataType = apexFieldType;
                    if (!eventParamsObj.isFieldRelated) {
                        selectedFieldOptions[ind].customLabel = eventParamsObj.selectedOption;
                    }
                    selectedFieldOptions[ind].isFieldRelated = eventParamsObj.isFieldRelated;
                    selectedFieldOptions[ind].relatedObjectName = response.relatedObjectName;
                    console.log(JSON.stringify(selectedFieldOptions[ind]));
                    if (eventParamsObj.type === 'selection') {
                        data.selectedFieldOptions = selectedFieldOptions;
                    }
                    else if (eventParamsObj.type === 'filter') {
                        data.selectedFilters = selectedFieldOptions;
                        self.addFilterOperation(component, event, self, selectedFieldOptions , ind);
                    }
                    // data.selectedFieldOptions = selectedFieldOptions;
                    // data.filterOptions = filterOptions;
                    component.set("v.data",data);
                    self.hideSpinner(component);
                })).catch(function (error) {
                    self.logError(component, 'handleFieldChangeHelper', error.name, error.message);
                });
            }
        } catch(e) {
            self.logError(component, 'handleFieldChangeHelper', e.name, e.message);
        }
    },
    addFilterOperation: function(component, event, helper, selectedFilters , index) {
        try {
            let dataTypeMap = component.get("v.dataTypeMap");
            let data = component.get('v.data');
            let dataType = selectedFilters[index].apexDataType;
            selectedFilters[index].filterValue = null;
			let filterOptions = data.filterOptions;
			for(let i in dataTypeMap) {
				if (i.toUpperCase() == dataType.toUpperCase()) {
					selectedFilters[index].operations = dataTypeMap[i];
					break;
				}
			}
		} catch (e) {
			helper.logError(component, 'addFilterOperation', e.name, e.message);
		}
    },
    validateComponentHelper : function(component, event, helper) {
        console.log('validateComponentHelper');
        let data = component.get('v.data');
        let isValid = component.find('templateForm').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        console.log(isValid);
        
        if (isValid) {
            
            
            let mappingList = [];
            let selectedFields = [];
            let selectedFilters = data.selectedFilters;
            let selectedFieldOptions = data.selectedFieldOptions;
            for(let index in selectedFieldOptions) {
                if (selectedFieldOptions[index].mapping) {
                    if (mappingList.includes(selectedFieldOptions[index].mapping)) {
                        this.showToast(component, 'Error', 'error', 'Field mapping should be unique');
                        data.hasError = true;
                        break;
                    }
                    else {
                        mappingList.push(selectedFieldOptions[index].mapping);
                    }
                }
                let selectedFld;
                if (selectedFieldOptions[index].isFieldRelated) {
                    selectedFld = JSON.parse(selectedFieldOptions[index].selectedField).relatedField;
                }
                else {
                    selectedFld = selectedFieldOptions[index].selectedField;
                }
                if (selectedFields.includes(selectedFld)) {
                    this.showToast(component, 'Error', 'error', 'You can select a field once in a section.');
                    data.hasError = true;
                    break;
                }
                else {
                    selectedFields.push(selectedFld);
                }
            }
            let accountField;
            if (data.accountField && data.accountField.isFieldRelated) {
                accountField = JSON.parse(data.accountField.selectedField).relatedField;
            }
            else {
                accountField = data.accountField.selectedField;
            }
            if (accountField && !selectedFields.includes(accountField)) {
                this.showToast(component, 'Error', 'error', 'You have to select account split field in Select Fields section.');
                data.hasError = true;
            }
            let documentField;
            if (data.documentField && data.documentField.isFieldRelated) {
                documentField = JSON.parse(data.documentField.selectedField).relatedField;
            }
            else {
                documentField = data.documentField.selectedField;
            }
            if (!selectedFields.includes(documentField)) {
                this.showToast(component, 'Error', 'error', 'You have to select document split field in Select Fields section.');
                data.hasError = true;
            }
            let isContainsExtra = true;
            let isContainsLess = true;
            let combo =data.filterCombo;
            let comboList = [];
            let num = 0;
            let filterValue = data.selectedFilterCombo;
            if( filterValue === 'Custom' ) {
                var reg = new RegExp('^([()0-9]|AND|OR|\\s)+$');

                var match = reg.test(combo.toUpperCase());
                if(match) {
                    for( let index = 1; index <= selectedFilters.length; index++ ) {
                    
                        if(! combo.includes( index.toString() ) ) {
                            isContainsExtra = false;
                        }
                    }
                    comboList = combo.match(/\d+/g).map(Number);
                }
            }
            if( !$A.util.isEmpty( comboList ) ) {
                for( let i = 0; i < comboList.length; i++ ) {
                    isContainsLess = true;
                    for( let index = 1; index <= selectedFilters.length; index++ ) {
                        if( index === comboList[i]) {
                            isContainsLess = false;
                        }
                    }
    
                    if( isContainsLess === true ){
                        num = comboList[i];
                        break;
                    }
                    
                }
            }
            if( isContainsExtra === false ) {
                let message = 'Some filter conditions are defined but not referenced in your filter logic.';
                helper.showToast(component, 'Error', 'error', message);
                data.hasError = true;

            }else if( isContainsLess === true && num != 0) {
                let message = 'The filter logic references an undefined filter: '+num+'.';
                helper.showToast(component, 'Error', 'error', message);
                data.hasError = true;
            }
            
        }
        else {
            data.hasError = true;
        }
        if (!data.hasError) {
            let fieldsDataContainer = component.find('templateFieldSearch');
            let fieldsDataContainerArr = Array.isArray(fieldsDataContainer) ? fieldsDataContainer : [fieldsDataContainer];
            for(let index in fieldsDataContainerArr) { 
                fieldsDataContainerArr[index].validateComponent();
            }
        }
        if (!data.hasError) {
            data.isOpen = false;
        }
        console.log('&&&&&&&&&&&&&&',data);
        component.set('v.data', data);
        // }, 1000);
    },
    logError : function(component, methodName, errorName, errorMessage) {
		this.hideSpinner(component);
		console.error(methodName,errorName,errorMessage);
		component.find('dataService').logException('AC_SelectFieldsAndFilters -> ' + methodName + errorName, errorMessage);
    },
    hideSpinner : function( component ) {
        $A.util.addClass(component.find("spinner"), "slds-hide");
    },
    showSpinner : function( component ) {
        $A.util.removeClass(component.find("spinner"), "slds-hide");
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
    getFieldType : function(displayType) {
		switch(displayType) {
		  	case 'ADDRESS':
		    	return 'text';
		    	break;
	    	case 'ID':
		    	return 'text';
		    	break;
		    case 'DATE':
		    	return 'date';
		    	break;
		    case 'DOUBLE':
		    	return 'number';
		    	break;
		    case 'PERCENT':
		    	return 'number';
		    	break;
		    case 'PHONE':
		    	return 'tel';
		    	break;
		    case 'TEXTAREA':
		    	return 'text';
		    	break;
		    case 'STRING':
		    	return 'text';
		    	break;
		    case 'URL':
		    	return 'url';
		    	break;
		    case 'INTEGER':
		    	return 'number';
		    	break;
		    case 'CURRENCY':
		    	return 'number';
		    	break;
	    	case 'DATETIME':
		    	return 'datetime';
		    	break;
		    case 'BOOLEAN':
		    	return 'boolean';
		    	break;
		    case 'REFERENCE':
		    	return 'text';
		    	break;
		    case 'EMAIL':
		    	return 'email';
		    	break;
		    case 'PICKLIST':
		    	return 'text';
		    	break;
		    case 'MULTIPICKLIST':
		    	return 'text';
		    	break;
		  	default:
		    	return null;
		}
	},
})