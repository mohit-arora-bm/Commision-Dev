({
    doInit : function(component, event, helper) {
        helper.initHelper(component);
    },
    getRec : function(component, event, helper) {
        helper.getRecHelper(component);
    },
    save : function(component, event, helper) {
        helper.saveRecord(component);
        
    }, 
     
    oncellchange : function(component, event, helper) {
        component.set("v.hasChanges",true);handleRowAction
    },
    cancel : function(component, event, helper) {
        component.find( "eadTable" ).set( "v.draftValues",null);
        component.find( "adjTable" ).set( "v.draftValues",null);
        helper.getRecHelper(component);
        component.set("v.hasChanges",false);
    },
    addRow : function(component, event, helper) {
        let row = {};
        // let adjList = component.get('v.adjList');
        // let lIndex = component.get('v.adjList').length - 1;
        // if(lIndex >= 0 && adjList[lIndex].Id.length < 10) {
        //     row.Id = parseInt(adjList[lIndex].Id) + 1;
        //     row.Id += '';
        // }
        // else {
        //     row.Id = '0';
        // }
        helper.editAdj(component, row);
        // component.set("v.hasChanges",true);
    },
    addTeamAdjustment : function(component, event, helper) {
        try{
        let periodList = component.get('v.periodList');
        let periodName;
        let period = component.get('v.period');
        for(let key in periodList) {
            if (periodList[key].Id == period) {
                periodName = periodList[key].Name;
                break;
            }
        }
        $A.createComponent(
            "c:AC_CreateTeamAdjustment",
            {
                teamId : component.get('v.teamId'),
                period : periodName,
                periodId : period
            },
            function(newCmp){
                console.log(newCmp);
                if (component.isValid()) {
                    component.find('recordForm').set("v.body", newCmp);
                }
            }
        );
        }catch(e){
            console.log(e);
        }
    },
    handleRowAction : function (component, event, helper) {
        let action = event.getParam('action');
        let row = event.getParam('row');
        if(row.agileComp__System_Generated__c) {
            helper.showToast(component, 'Error', 'error', 'This is System generated Adjustment and you don\'t have access to Edit/delete.');
            return;
        }
        console.log(JSON.stringify(row));
        switch (action.name) {
            case 'Delete':
                helper.removeAdj(component, row);
                break;
            case 'Edit':
                helper.editAdj(component, row);
                break;
        }
    },
    handleTeamAdjRowAction : function (component, event, helper) {
        try{
        let action = event.getParam('action');
        let row = event.getParam('row');
        if(row.agileComp__System_Generated__c) {
            helper.showToast(component, 'Error', 'error', 'This is System generated Adjustment and you don\'t have access to Edit/delete.');
            return;
        }
        console.log(JSON.stringify(row));
        switch (action.name) {
            case 'Delete':
                helper.removeTeamAdj(component, row);
                break;
            case 'Edit':
                console.log(JSON.stringify(row));
                helper.editTeamAdj(component, row);
                break;
        }
    }catch(e){
        console.log(e);
    }
    },

    generatePDF : function (component, event, helper) {
        let pageReference = {
            type: 'standard__webPage',
            attributes: {
                url: '/apex/AC_EmployeePDF?id='+component.get("v.eavList")[0].Id  
            },

        };
        var navService = component.find("navService");
        navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                console.log(url);
                window.open(url,'_blank');
                // navService.navigate(pageReference);


            }), $A.getCallback(function(error) {
                console.log(error); 
            }));
    },
    adjRowEdit : function (component, event, helper) {
        component.set("v.hasChanges",true);
        let newAdj = component.get("v.newAdj");
        if(!newAdj) {
            return;
        }
        newAdj.agileComp__Commission_Employee_Attained_Value_Recor__c = component.get("v.eavList")[0].Id;
        // let name = component.get("v.eavList")[0].Name + '-'; 
        // let newIndex = 0;
        // let lName;
        let adjList = component.get( "v.adjList");
        if(!adjList || adjList.length == 0) {
            
            adjList = [];
        }
        // else {
        //     let lIndex = adjList.length - 1;
        //     // let lName = adjList[lIndex].Name;
        //     newIndex = parseInt(lName.substring(lName.lastIndexOf('-')+1))+1;
        // }
        
        console.log(adjList);
        console.log(newAdj);
        if (newAdj.Id) {
            for(let key in adjList) {
                if(adjList[key].Id == newAdj.Id) {
                    adjList[key] = newAdj;
                    component.set( "v.adjList",adjList);
                    return;
                }
            }  
        }
        else {
            newAdj.Id = adjList.length;
            adjList.push(newAdj);
        }
        // if(!newAdj.Name) {
        //     newAdj.Name =  component.get("v.eavList")[0].Name + '-' + newAdj.agileComp__Adjustment_Type__c + '-' + newIndex;
        // }
        
        component.set( "v.adjList",adjList);
        component.set( "v.newAdj",null);
    },

    import : function (component, event, helper) {
        let pageReference = {
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'agileComp__Import_Data' 
            },

        };
        var navService = component.find("navService");
        navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                console.log(url);
                // window.open(url,'_blank');
                navService.navigate(pageReference);


            }), $A.getCallback(function(error) {
                console.log(error); 
            }));
    }
})