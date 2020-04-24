({
    onChangeTemplateHelper : function( component, event, selectedId ) {
		try {
			component.set('v.displaySpinner', true);
			var dataService = component.find('dataService');
			var action = component.get('c.getDataTemplate');
			action.setParams({
				templateId: selectedId
			});
			dataService.fetch(action).then($A.getCallback(function (response) {
				console.log(response);
				if(! $A.util.isEmpty( response ) ) {
					component.set('v.selectedTemplateObject',  response.objectName  );
                    component.set('v.selectedFieldsList', JSON.parse( response.selectedFields ));
                    console.log('Sel :: '+ response.selectedFields );
				}
				component.set('v.displaySpinner', false);
			})).catch(function (error) {
				component.set('v.displaySpinner', false);
				component.find('dataService').logException('ImportData -> getFieldsHelper ' + error.name, error.message);
			});
		} catch(e) {
			component.set('v.displaySpinner', false);
			component.find('dataService').logException('ImportData -> getFieldsHelper ' + e.name, e.message);   
		}
    },
	readFile: function(component, helper, file) {
        var fileName = '';
        var self = this;
        if (!file) return;
        console.log('file'+file.name);
        fileName = file.name;
        if(!file.name.match(/\.(csv||CSV)$/)){
            return alert('only support csv files');
        }else{
            
            reader = new FileReader();
            reader.onerror =function errorHandler(evt) {
                switch(evt.target.error.code) {
                    case evt.target.error.NOT_FOUND_ERR:
                        alert('File Not Found!');
                        break;
                    case evt.target.error.NOT_READABLE_ERR:
                        alert('File is not readable');
                        break;
                    case evt.target.error.ABORT_ERR:
                        break; // noop
                    default:
                        alert('An error occurred reading this file.');
                };
            }
            //reader.onprogress = updateProgress;
            reader.onabort = function(e) {
                alert('File read cancelled');
            };
            reader.onloadstart = function(e) { 
                
                var output = '<ui type=\"disc\"><li><strong>'+file.name +'</strong> ('+file.type+')- '+file.size+'bytes, last modified: '+file.lastModifiedDate.toLocaleDateString()+'</li></ui>';
                
               
            };
            reader.onload = function(e) {
                var data=e.target.result;

                console.log("file data"+JSON.stringify(data));
                var allTextLines = data.split(/\r\n|\n/);
                component.set('v.actualTotalLength', allTextLines.length);
                
                var dataRows=allTextLines.length-1;
                var headers = allTextLines[0].split(',');

                var headersMap = component.get('v.headersMap');
                
                component.set('v.headers', headers);
                console.log("Rows headersMap::"+headersMap);
               
              
                var numOfRows=component.get("v.NumOfRecords");
                if(dataRows > numOfRows+1 || dataRows == 1 || dataRows== 0){
                
                    alert("File Rows between 1 to "+numOfRows+" .");
                    component.set("v.showMain",true);
                    
                } 
                else{
                    var lines = [];
                    var indices = [];
                    var indexWithRequired = {};
                    var indexWithLabel = {};
                    var headMapWithRequired =  component.get('v.headMapWithRequired');
                    console.log('headMapWithRequired updated :: '+headMapWithRequired);
                    var filecontentdata;
                    var content = "<div class=\"slds-p-horizontal_small slds-scrollable quoteTempConfigDiv \"><table class=\"table slds-table slds-table--bordered \">";
                    content += "<thead><tr class=\"slds-text-title--caps\">";
                    for(i=0;i<headers.length; i++){console.log('headersMap :: '+headersMap);
                        if( $A.util.isEmpty( headersMap ) ) {
                            content += '<th scope=\"col"\>'+headers[i]+'</th>';
                        }else {
                            if(! $A.util.isEmpty( headersMap[headers[i]] ) ) {
                                content += '<th scope=\"col"\>'+headersMap[headers[i]]+'</th>';
                                indices.push(i);
                                indexWithRequired[i] = headMapWithRequired[headers[i]];
                                indexWithLabel[i] = headersMap[headers[i]];
                            }
                        }
                    }
                    component.set('v.indices', indices);


                    //-----------------------------------------------------------------------------
                    var fileCompleteContentList = [];
                    var errorCSVString = component.get('v.errorCSVString');
                    var errorCSV = '';
                    var errorCount = 0;
                    if(! $A.util.isEmpty( indexWithRequired ) ) {
                        for( var all in allTextLines ) {
                            var indexValues = allTextLines[all].split(',');
                            var dataLst = '';
                            var missingFieldName = [];
                            var isBlank = false;
                            var isRequired = false;
                            
                            for(  var ind = 0; ind < indices.length; ind++  ) {
                                if( indexWithRequired[indices[ind]] == true ) {
                                    if( $A.util.isEmpty( indexValues[indices[ind]] ) ) {
                                        isRequired = true;
                                        isBlank =  true;
                                        errorCSV = 'Required Field Missing : '+indexWithLabel[indices[ind]];
                                        component.set('v.errorCSV', errorCSV);
                                        break;
                                    }
                                }
                            }

                            for(  var ind = 0; ind < indices.length; ind++  ) {
                                dataLst += indexValues[indices[ind]]+',';
                                if( indexWithRequired[indices[ind]] == true ) {
                                    if( $A.util.isEmpty( indexValues[indices[ind]] ) ) {
                                        isRequired = true;
                                        isBlank =  true;
                                        missingFieldName.push( indexWithLabel[indices[ind]] );
                                    }
                                }
                            }

                            if( isRequired && isBlank ) {
                                var missingFieldNames = '';
                                var indexT = 0;
                                for( var mis in missingFieldName ) {
                                    if( indexT == (missingFieldName.length-1) ) {
                                        missingFieldNames += missingFieldName[mis];
                                    }else {
                                        missingFieldNames += missingFieldName[mis]+';';
                                    }
                                    indexT++;
                                }
                                errorCSVString += dataLst+'Required Field Missing : "'+missingFieldNames+'"\n';
                                errorCount++;
                            }else {
                                fileCompleteContentList.push(allTextLines[all]);
                            }
                            
                        }
                        
                        allTextLines = fileCompleteContentList;
                        console.log('errorCSVString updated :: '+errorCSVString);
                        console.log('allTextLines updated :: '+allTextLines.length);
                        component.set('v.errorCSVString', errorCSVString);
                        component.set('v.errorRecordCount', errorCount );
                        var actualLength = component.get('v.actualTotalLength');
                        var progress = ( errorCount/actualLength ) * 100;
                        console.log('progress Count :: '+progress);
                        component.set('v.progress', progress );

                    }
                    
                    var fileContentList = [];
                    
                    var start = 0;
                    var end = (allTextLines.length > 500) ? 500 : allTextLines.length; 
                    component.set('v.totalLength', allTextLines.length);
                    console.log("end"+end);
                    console.log("allTextLines.length"+allTextLines.length);

                    
                    while( end < allTextLines.length ){
                        console.log("fileContentList.length : "+fileContentList.length);
                        fileContentList.push( self.getChunks( start, end, allTextLines ) );
                        start = start + 500;
                        end = end + 500;
                        if( end > allTextLines.length ) {
                            end = allTextLines.length;
                        }
                    } 
                        
                    if( end == allTextLines.length ){
                        fileContentList.push( self.getChunks( start, end, allTextLines ) );
                    }
                    
                     
                    console.log('fileContentList :: '+fileContentList.length);       
                     
                    component.set("v.fileContentData",fileContentList);

                    //-------------------------------------------------------------------------------

                    content += "</tr></thead>";
                    for (var i=1; i<10; i++) {
                        filecontentdata = allTextLines[i].split(',');
                        if(filecontentdata[0]!=''){
                            content +="<tr>";
                            if( $A.util.isEmpty( indices ) ) {
                                for(var j=0;j<filecontentdata.length;j++){
                                    content +='<td>'+filecontentdata[j]+'</td>';
                                }
                            }else {
                                for(var j=0;j<indices.length;j++){
                                    content +='<td>'+filecontentdata[indices[j]]+'</td>';
                                }
                            }
                            
                            content +="</tr>";
                        }
                    }
					content += "</table></div>";
					
                    console.log('Table headers :: '+component.get('v.headers'));
                    component.set("v.TableContent",content);
					component.set("v.showMain",false);                   
                }
            }
            reader.readAsText(file);

            
        }
        var reader = new FileReader();
        reader.onloadend = function() {
            if( component.get('v.onUpload') ) {
                self.onUploadHelper( component, event, fileName );
            }
           
        };
        reader.readAsDataURL(file);
    },
    getChunks : function( start, end, dataList ) {
        var dataString = '';
        for( var i = start; i < end; i++) {
            console.log('dataList[i] ::: '+dataList[i]);
            dataString += dataList[i]+'\n';
        }
        return dataString;
    },
    getListChunks : function( start, end, dataList ) {
        var data = [];
        for( var i = start; i < end; i++) {
            data.push( dataList[i] );
        }
        return data;
    },
    onUploadHelper : function( component, event, fileName ) {
        var self = this;
		try {

            if( component.get('v.allOrNone') == true && (! $A.util.isEmpty( component.get('v.errorCSVString') ) )) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Info!", 
                    "mode":"Sticky",
                    "message": 'Error occurred while uploading data from file - '+
                    fileName+' with Template of Data Loader - '+
                    component.get('v.templateName')+'. You will receive an email for the error message and rollback is proccessing in backgroud.'
                });
                toastEvent.fire();
                component.set('v.onUpload', false);
                component.set('v.toPreview', false);
                component.set('v.TableContent', '');
                component.set('v.selectedTemplateObject', '');
                component.set('v.indexToCheck', 0 );
                component.set('v.selectedFieldsList', []);
                component.set('v.file', {});
                component.set('v.headers', []);
                component.set('v.displaySpinner', false);
                component.set('v.isInProgress', false);
                var dataService = component.find('dataService');
                var action = component.get('c.sendMail');
                action.setParams({
                    errorCSVMessage: component.get('v.errorCSV'),
                    fileName : fileName,
                    templateName : component.get('v.templateName')
                });
                dataService.fetch(action).then($A.getCallback(function (response) {
                    console.log(response);
                    if(! $A.util.isEmpty( response ) ) {
                    //Sent Successfully!
                    }
                })).catch(function (error) {
                    component.set('v.displaySpinner', false);
                    component.find('dataService').logException('ImportData -> getFieldsHelper ' + error.name, error.message);
                });

            }else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Info!",
                    "mode":"Sticky",
                    "message": "UPLOAD IN PROCCESS! File - "+fileName+" is being uploaded and it takes some time. Wait until progress bar complete. "
                });
                toastEvent.fire();
                component.set('v.isInProgress', true);
                console.log('headers : '+ component.get('v.headersfieldNames'));
                component.set('v.displaySpinner', true);
                
                var successfulRecords = [];
                //var errorCSVStringList = [];
                var errorCSVString = '';
                var dataService = component.find('dataService');
                var action = component.get('c.onUploadData');
                
                var allTextLines = component.get('v.fileContentData');
                var fileContentList = [];
                var start = 0;
                var end = (allTextLines.length > 2) ? 2 : allTextLines.length; 
                var numberOfExecution = Math.ceil( allTextLines.length / end );
                
                self.onUploadHelperServerCall( component, event, action, dataService, fileName, allTextLines, start, end, successfulRecords, errorCSVString, numberOfExecution );
            }
		} catch(e) {
			component.set('v.displaySpinner', false);
			component.find('dataService').logException('ImportData -> getFieldsHelper ' + e.name, e.message);   
		}
    },

    deleteSuccessfulRecordsHelper :  function( component, event, successfulRecords ) {
        
        var dataService = component.find('dataService');
        var action = component.get('c.deleteSuccessfulRecords');
        action.setParams({
            recordIds: successfulRecords
        });
        dataService.fetch(action).then($A.getCallback(function (response) {
            console.log(response);
            if(! $A.util.isEmpty( response ) ) {
               //Successfully Deleted
            }
        })).catch(function (error) {
            component.set('v.displaySpinner', false);
            component.find('dataService').logException('ImportData -> getFieldsHelper ' + error.name, error.message);
        });
       /* window.setTimeout(
            $A.getCallback(function() {
                $A.get('e.force:refreshView').fire();
            }), 5000
        );*/
       
    },

    exportCSV :  function( component, event, errorCSVString ) {
        console.log('exportCSV :: '+errorCSVString);
        var headerFieldNames = component.get('v.headersfieldNames');
        var csvString = '';
        var index = 0;
        for( var fld in headerFieldNames ) {
            csvString += headerFieldNames[fld]+',';           
        }
        csvString += 'Error Message'+'\n';
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();

        today = mm + '/' + dd + '/' + yyyy;
        var errorFileName = component.get('v.templateName')+' - '+today;
        csvString += errorCSVString;
        if (csvString == null){return;} 
	    var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI( csvString );
        hiddenElement.target = '_self'; 
        hiddenElement.download = errorFileName+' Error.csv'; 
        document.body.appendChild(hiddenElement); 
        hiddenElement.click(); 
    },
    onUploadHelperServerCall : function( component, event, action, dataService, fileName, allTextLines, start, end, successfulRecords, errorCSVString, numberOfExecution ) {
        var self = this;
        console.log('exportCSV allTextLines '+allTextLines.length);
        var fileContentList = self.getListChunks( start, end, allTextLines );
        action.setParams({
            fileContentData : fileContentList,
            indices : component.get('v.indices'),
            headersfieldNames:  component.get('v.headersfieldNames'),
            headersfieldNamesWithType : component.get('v.headersfieldNamesWithType'),
            objectName : component.get('v.selectedTemplateObject'),
            allOrNone :  component.get('v.allOrNone'),
            templateName : component.get('v.templateName'),
            fileName : fileName
        });
        dataService.fetch(action).then($A.getCallback(function (response) {
            console.log(' getFieldsHelper '+response);
            /*component.set('v.selectedTemplateObject',  response.objectName  );
            component.set('v.selectedFieldsList', JSON.parse( response.selectedFields ));
            console.log('Sel :: '+ response.selectedFields );*/
            
            component.set('v.indexToCheck', ( component.get('v.indexToCheck') + 1 ) );
            var indexToCheck = component.get('v.indexToCheck');
            var actualLength = component.get('v.actualTotalLength');
            var errorRecordCount = component.get('v.errorRecordCount');
            var succesrecIds = response.successfulRecordIds;
            var successCount = 0;
            if(! $A.util.isEmpty(succesrecIds) ) {
                successCount = succesrecIds.length;
            }

            
            
           
            for(var sucs in succesrecIds ) {
                successfulRecords.push( succesrecIds[sucs] );
            }
            console.log(' allOrNone after :: '+component.get('v.allOrNone'));
            component.set('v.successfulRecords', successfulRecords);
            if( component.get('v.allOrNone') == false ) {
                console.log(' response.csvErrorString :: '+response.csvErrorString);
                console.log(' errorCSVString :: '+component.get('v.errorCSVString'));
                var errorCSVString = component.get('v.errorCSVString');
                errorCSVString += response.csvErrorString;
                component.set('v.errorCSVString', errorCSVString);
                console.log(' errorCSVString after :: '+errorCSVString.length);
                var errorCount = component.get('v.errorRecordCount');
                console.log('Error Count :: '+errorCount+response.csvErrorCount);
                component.set('v.errorRecordCount', (errorCount+response.csvErrorCount));
            }
            
            var updatedErrorCount = component.get('v.errorRecordCount');
            var progress = ( ((indexToCheck*successCount)+updatedErrorCount)/actualLength ) * 100;
            console.log('progress Count :: '+progress);
            component.set('v.progress', progress );

            var successRecordCount  = component.get('v.successRecordCount');
            if(! $A.util.isEmpty(response.successfulRecordIds) ) {
                console.log('Success Count :: '+successRecordCount+response.successfulRecordIds.length);
                component.set('v.successRecordCount', (successRecordCount+response.successfulRecordIds.length));
            }
           
            
            start = start + 2;


            if( end == allTextLines.length ) {
                end = end+1;
            }
            
            if( end < allTextLines.length  &&  (end + 2) > allTextLines.length ) {
                end = allTextLines.length;
            }else {
                end = end + 2;
            }
            console.log(' indexToCheck :: '+component.get('v.indexToCheck'));
                console.log(' numberOfExecution :: '+numberOfExecution);
                console.log(' errorCSVString :: '+errorCSVString);
            
            if( end <= allTextLines.length ) {
                console.log(' indexToCheck :: '+component.get('v.indexToCheck'));
                self.onUploadHelperServerCall( component, event, action, dataService, fileName, allTextLines, start, end, successfulRecords, errorCSVString, numberOfExecution );
            }else {
                console.log(' indexToCheck :: '+component.get('v.indexToCheck'));
                console.log(' numberOfExecution :: '+numberOfExecution);
                console.log(' errorCSVString :: '+errorCSVString);
                if( component.get('v.indexToCheck') == numberOfExecution ) {
                    if( ! $A.util.isEmpty( errorCSVString ) ) {
                        // Export CSV Here
                        self.exportCSV( component, event, errorCSVString );
                    }
                }
                
                component.set('v.onUpload', false);
                component.set('v.TableContent', '');
                component.set('v.selectedTemplateObject', '');
                component.set('v.indexToCheck', 0 );
                component.set('v.selectedFieldsList', []);
                component.set('v.file', {});
                component.set('v.headers', []);
                component.set('v.displaySpinner', false);
                component.set('v.isInProgress', false);
                $A.get('e.force:refreshView').fire();
            }
            
            
        })).catch(function (error) {
            console.log('successfulRecords :: '+component.get('v.successfulRecords').length);
            if(( component.get('v.allOrNone') ) && ( ! $A.util.isEmpty( component.get('v.successfulRecords') )  )) {
                // Delete Successful Records
                self.deleteSuccessfulRecordsHelper( component, event, successfulRecords );
            }
            
            component.set('v.onUpload', false);
            component.set('v.toPreview', false);
            component.set('v.TableContent', '');
            component.set('v.selectedTemplateObject', '');
            component.set('v.indexToCheck', 0 );
            component.set('v.selectedFieldsList', []);
            component.set('v.file', {});
            component.set('v.headers', []);
            component.set('v.displaySpinner', false);
            component.set('v.isInProgress', false);
            //component.find('dataService').logException('ImportData -> getFieldsHelper ' + error.name, error.message);
        }); 
    }
})