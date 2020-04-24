({
    doInit : function(component, event, helper) {
        helper.showSpinner(component);
        let action = component.get("c.checkConfig");
        let dataService = component.find('dataService');
        dataService.fetch(action)
        .then($A.getCallback(function (response) {
            let message = 'You can uninstall this package there is no dependency';
            let needDeConfigure = false;
            if(response) {
                message = 'There is some dependency please deconfigure first';
                needDeConfigure = true;
            }
            component.set('v.message',message);
            component.set('v.needDeConfigure',needDeConfigure);
            helper.hideSpinner(component);

        })).catch(function (error) {
            helper.logError(component, 'doInit', error.name, error.message);
        });
    },
    deConfigure : function(component, event, helper) {
        helper.showSpinner(component);
        let action = component.get("c.deleteClass");
        let dataService = component.find('dataService');
        dataService.fetch(action)
        .then($A.getCallback(function (response) {
            helper.postAction(component, helper, response);
        })).catch(function (error) {
            helper.logError(component, 'deConfigure', error.name, error.message);
        });
    },
    
})