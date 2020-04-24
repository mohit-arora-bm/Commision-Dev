({
    // doInit : function(component, event, helper) {
    //     helper.initHelper(component); 
    // },
    addDataRow : function(component, event, helper) {
        let index = event.getSource().get('v.name');
        let row = helper.getAdjRow();
        let adjList = component.get("v.adjList");
        adjList.splice(index+1,0,row);
        console.log(adjList.length);
        component.set("v.adjList",adjList);
    },
    doInit : function(component, event, helper) {
        component.set('v.adjList',[helper.getAdjRow()]);
        let action = component.get("c.getEmployees"); 
        // action.setParams({
        //     "periodId" : component.get("v.period").Id
        // });
        let dataService = component.find('dataService');
		dataService.fetch(action)
		.then($A.getCallback(function (response) {
            if (response && response.length > 0) {
                component.set('v.periodId',response[0].agileComp__Commission_Period__c);
                component.set('v.periodName',response[0].agileComp__Commission_Period__r.Name);
                let employees = [];
                for(let key in response) {
                    employees.push({
                        "label": response[key].agileComp__Commission_Sales_Rep__r.Name,
                        "value": response[key].Id
                    });
                }
                component.set("v.employees",employees);
            }
        })).catch(function (error) { 
			// self.logError(component, 'initHelper', error.name, error.message);
		});
    },
    removeDataRow : function (component, event, helper) {
        let index = event.getSource().get('v.name');
        let adjList = component.get('v.adjList');
        let removedFld = adjList.splice(index, 1);
        component.set('v.adjList', adjList);
    },
    post : function (component, event, helper) {
        let adjList = component.get("v.adjList");
        for(let i in adjList) {
            for(let key in adjList[i]) {
                if (!adjList[i][key]) {
                    helper.showToast(component, 'Error', 'error', 'All fields are required');
                    return;
                }
            }
        }
        let action = component.get("c.saveAdjustments"); 
        action.setParams({
            "adjs" : adjList
        });
        let dataService = component.find('dataService');
		dataService.fetch(action)
		.then($A.getCallback(function (response) {
            $A.get('e.force:refreshView').fire();
        })).catch(function (error) { 
			helper.logError(component, 'post', error.name, error.message);
		});
        console.log(adjList);
    }
})