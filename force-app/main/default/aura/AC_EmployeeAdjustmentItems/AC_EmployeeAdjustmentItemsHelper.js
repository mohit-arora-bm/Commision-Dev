({
    initHelper : function(component) {
        let self = this;
        self.showSpinner(component);
        let actions = [{ label: 'Delete', name: 'Delete' },{ label : 'Edit', name : 'Edit'}];
        component.set('v.adjColumns', [
            {label: 'Name', fieldName: 'Name', type: 'text', typeAttributes: { required: true },cellAttributes: { alignment: 'left' }},
            {label: 'Adjustment Type', fieldName: 'agileComp__Adjustment_Type__c', type: 'text', typeAttributes: { required: true },cellAttributes: { alignment: 'left' }},
            {label: 'Amount', fieldName: 'agileComp__Adjustment_Amount__c', type: 'currency', typeAttributes: { currencyCode: 'USD',required: true },cellAttributes: { alignment: 'left' }},
            {label: 'Note', fieldName: 'agileComp__Adjustment_Description__c', type: 'text' , typeAttributes: { required: true },cellAttributes: { alignment: 'left' }},
            { type: 'action', typeAttributes: { rowActions: actions } }
        ]);
        component.set('v.teamAdjColumns', [
            {label: 'Name', fieldName: 'Name', type: 'text', typeAttributes: { required: true },cellAttributes: { alignment: 'left' }},
            {label: 'Adjustment Type', fieldName: 'agileComp__Adjustment_Type__c', type: 'text', typeAttributes: { required: true },cellAttributes: { alignment: 'left' }},
            {label: 'Amount', fieldName: 'agileComp__Adjustment_Amount__c', type: 'currency', typeAttributes: { currencyCode: 'USD',required: true },cellAttributes: { alignment: 'left' }},
            {label: 'Note', fieldName: 'agileComp__Adjustment_Description__c', type: 'text' , typeAttributes: { required: true },cellAttributes: { alignment: 'left' }},
            {label: 'Sales Rep Eav', fieldName: 'agileComp__Commission_Employee_Attained_Value_Recor__c', type: 'text' ,cellAttributes: { alignment: 'left' }},
            {label: 'Created Date', fieldName: 'CreatedDate', type: 'date' , cellAttributes: { alignment: 'left' }}
            
        ]);
        let action = component.get("c.getData");
        let dataService = component.find('dataService');
		dataService.fetch(action)
		.then($A.getCallback(function (response) {
            
            component.set("v.employeeList",response.salesReps); 
            component.set("v.periodList",response.periods);
            
            self.hideSpinner(component);
        })).catch(function (error) {
			self.logError(component, 'initHelper', error.name, error.message);
		});
    },
    getRecHelper : function(component) {
        let self = this;
        self.showSpinner(component);
        let isValid = component.find('templateForm').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        console.log(isValid);
        
        if (!isValid) {
            return;
        }
        let action = component.get("c.getEmployeeAttains"); 
        action.setParams({
            "periodId" : component.get("v.period"),
            "salesRepId" : component.get("v.employee")
        });
        let dataService = component.find('dataService');
		dataService.fetch(action)
		.then($A.getCallback(function (response) {
            console.log(response);
            if(!response) {
                self.showToast(component, '', 'info', 'No record found.');
                component.set("v.eavList",[]);
                component.set("v.teamId","");
                component.set("v.eadList",[]);
                component.set("v.adjList",[]);
                self.hideSpinner(component);
                return;
            }
            if (!response.isActive) {
                $A.util.addClass(component.find("mainDiv"), "inActive");
            }
            else {
                $A.util.removeClass(component.find("mainDiv"), "inActive");
            }
            
            let eavMainColumns = [];
            var mainEavList = {};
            for(let key in response.eavFieldSet) {
                let col = {};
                col.label = response.eavFieldSet[key].label;
                col.fieldName = response.eavFieldSet[key].api;
                col.type = self.getFieldType(response.eavFieldSet[key].dataType);
                col.cellAttributes = { alignment: 'left' };
                eavMainColumns.push(col);
                mainEavList[response.eavFieldSet[key].api] = response.eavRecords[0][response.eavFieldSet[key].api];
            }
            mainEavList['Name'] =  response.eavRecords[0]['Name'];
            component.set('v.eavColumns', eavMainColumns);
            component.set('v.eavList', mainEavList);

            var totalEavTables = Math.ceil(response.eavExtraFieldSet.length/10);
            var allEavData = [];
            var prevCount = 0
            for(var i = 0 ; i < totalEavTables ; i++){
                var dataList = [];
                var count = 0
                let eavColumns = [];
                var endPoint = 0; 
                if(prevCount+10 <= response.eavExtraFieldSet.length){
                    endPoint = prevCount+9;
                }else{
                    endPoint = response.eavExtraFieldSet.length
                }
                 
                var dataObj= {};
				for(var j = prevCount; j < endPoint; j++){
					var result = response.eavExtraFieldSet[j];
					if(count < 10){
						let col = {};
						col.label = result.label;
						col.fieldName = result.api;
						col.type = self.getFieldType(result.dataType);
						col.cellAttributes = { alignment: 'left' };
						eavColumns.push(col);
						var apiName = result.api;
						dataObj[ apiName ] = response.eavRecords[0][result.api];
						count++;
						prevCount++;
					}else{
						break;
                    }
                }
                
                dataList.push(dataObj);
                var obj = {coloum:eavColumns,eavDataList:dataList}
                allEavData.push(obj);
            }
            component.set('v.allEavDataList', allEavData);
            let eadColumns = [];
            for(let key in response.eadFieldSet) {
                let col = {};
                col.label = response.eadFieldSet[key].label;
                col.fieldName = response.eadFieldSet[key].api;
                if(col.fieldName == 'agileComp__Override_Percent__c') {
                    col.editable = true;
                }
                col.type = self.getFieldType(response.eadFieldSet[key].dataType);
                col.cellAttributes = { alignment: 'left' };
                eadColumns.push(col);
            }
            component.set('v.eadColumns', eadColumns);
            component.set("v.eavList",response.eavRecords);
            component.set("v.teamId",response.eavRecords[0].agileComp__Commission_Team__c);
            if(response.eavRecords[0].agileComp__Commission_Employee_Attained_Detail__r) {
                component.set("v.eadList",response.eavRecords[0].agileComp__Commission_Employee_Attained_Detail__r);
            }
            else {
                component.set("v.eadList",[]);
            }
            console.log(JSON.stringify(response.eavRecords[0].agileComp__Commission_Adjustment_Details__r));
            if(response.eavRecords[0].agileComp__Commission_Adjustment_Details__r) {

                var adjustArray = response.eavRecords[0].agileComp__Commission_Adjustment_Details__r;
                var indAdjustList = [];
                var teamAdjustList = [];
                adjustArray.forEach(function(currentValue, index, arr){
                    if(currentValue.agileComp__Team_Adjustment__c){
                         var value = currentValue['agileComp__Commission_Employee_Attained_Value_Recor__r']['Name'];
                        currentValue['agileComp__Commission_Employee_Attained_Value_Recor__c'] = value;
                        teamAdjustList.push(currentValue);
                    }else{
                        indAdjustList.push(currentValue);
                    }
                });

                for(let key in response.extraAdjustmentDetails) {
                    var value = response.extraAdjustmentDetails[key]['agileComp__Commission_Employee_Attained_Value_Recor__r']['Name'];
         
                    response.extraAdjustmentDetails[key]['agileComp__Commission_Employee_Attained_Value_Recor__c'] = value;
                    teamAdjustList.push(response.extraAdjustmentDetails[key]);
                }
                component.set("v.adjList",indAdjustList);
                component.set("v.teamAdjList",teamAdjustList);
            }
            else {
                component.set("v.adjList",[]);
            }
            component.set("v.deleteAdjList",[]);
            self.hideSpinner(component);
        })).catch(function (error) {
			self.logError(component, 'initHelper', error.name, error.message);
		});
    },
    removeAdj : function(component,row) {
        component.set("v.hasChanges",true);
        let rows = component.get('v.adjList');
        let rowIndex = rows.indexOf(row);
        let deleteAdjList = component.get("v.deleteAdjList");
        let deleteAdj = rows.splice(rowIndex, 1);
        console.log(deleteAdj[0].Id);
        deleteAdjList.push(deleteAdj[0].Id);
        component.set('v.adjList', rows);
    },
    removeTeamAdj : function(component,row) {
        var self = this;
        let action = component.get("c.deleteTeamAdjustmentRecords"); 
        action.setParams({
            "teamAdjJsonString" : JSON.stringify(row)
        });
        let dataService = component.find('dataService');
		dataService.fetch(action)
		.then($A.getCallback(function (response) {
            self.getRecHelper(component);
        })).catch(function (error) {
			self.logError(component, 'initHelper', error.name, error.message);
		});
    },
    editAdj : function(component,row) {
        let recordId;
        console.log(row);
        if(row && row.Id) {
            if(row.Id.length > 10) {
                recordId = row.Id;
            }
        }
        console.log(recordId);
        $A.createComponent(
            "c:AC_CreateEditCommAdjustment",
            {
                record : component.getReference('v.newAdj'),
                oldRecord : row,
                recordId : recordId
            },
            function(newCmp){
                if (component.isValid()) {
                    component.find('recordForm').set("v.body", newCmp);
                }
            }
        );
    },
    editTeamAdj : function(component,row) {
        let recordId;
        console.log(row);
        if(row && row.Id) {
            if(row.Id.length > 10) {
                recordId = row.Id;
            }
        }
        console.log(recordId);
        $A.createComponent(
            "c:AC_CreateTeamAdjustment",
            {
                teamId : component.get('v.teamId'),
                periodId : component.get('v.period'),
                oldRecord : row,
                teamAdjRecordId : recordId
            },
            function(newCmp){
                if (component.isValid()) {
                    component.find('recordForm').set("v.body", newCmp);
                }
            }
        );
    },
    saveRecord : function(component) {
        let self = this;
        self.showSpinner(component);
        component.set("v.showError",false);
        let eadDraftValues = component.find( "eadTable" ).get( "v.draftValues");
        // let adjDraftValues = component.find( "adjTable" ).get( "v.draftValues");
        let deleteAdjList = component.get( "v.deleteAdjList");
        let adjList = component.get("v.adjList");
        // let adjToUpdate = [];
        // let eavId = component.get("v.eavList")[0].Id;
        // console.log(adjDraftValues);
        console.log(adjList);
        console.log(deleteAdjList);
        let dataService = component.find('dataService');
        let action = component.get("c.saveRecords");
        action.setParams({
            eadDraftValues : eadDraftValues,
            adjDraftValues : adjList,
            deleteAdjList : deleteAdjList,
            teamId : component.get("v.teamId"),
            periodId : component.get("v.period")
        });
		dataService.fetch(action)
		.then($A.getCallback(function (response) {
            component.set("v.hasChanges",false);
            self.getRecHelper(component);
        })).catch(function (error) {
            self.logError(component, 'saveRecord', error.name, error.message);
            self.hideSpinner(component);
		});;
    },
    logError : function(component, methodName, errorName, errorMessage) {
		console.error(methodName,errorName,errorMessage);
        component.find('dataService').logException('AC_EmployeeAdjustmentItems -> ' + methodName + errorName, errorMessage);
        $A.util.addClass(component.find("Spinner"), "slds-hide");
    },
    hideSpinner : function( component ) {
        $A.util.addClass(component.find("Spinner"), "slds-hide");
    },
    showSpinner : function( component ) {
        $A.util.removeClass(component.find("Spinner"), "slds-hide");
    },
    showToast : function(component, title, type, message) {
		$A.get('e.force:showToast').setParams({
			title: title,
			message: message,
			type: type
		}).fire();
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