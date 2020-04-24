public class TemplateDataLoaderController {

    @AuraEnabled
	public static List<RecordWrapper> fetchRecords(String objectAPIName, String fieldsListJSON) {
		try {
			String queryBefore = 'SELECT ';
			String fieldsString = '';
			List<RecordWrapper> recordsList = new List<RecordWrapper>();
			List<FieldsWrapper> fieldsList = (List<FieldsWrapper>) JSON.deserialize(fieldsListJSON, List<FieldsWrapper>.class);

			Boolean isSortByName = false;
			for(FieldsWrapper fieldWrapper : fieldsList) {
				fieldsString += fieldWrapper.fieldAPIName + ',';
				if( fieldWrapper.fieldAPIName == 'Name') {
					isSortByName = true; 
				}
			}
			fieldsString += 'Id ';
			String queryAfter = '';
			if( isSortByName == true ) {
				queryAfter = ' FROM ' + objectAPIName + ' ORDER BY Name ASC';
			}
			else {
				queryAfter = ' FROM ' + objectAPIName;
			}
			 
			// check Read FLS
			//AQ_SecurityUtils.checkRead( Schema.getGlobalDescribe().get(objectAPIName).getDescribe().getSobjectType(), fieldsString.split(',') );
			List<sObject> sobjectList = Database.query(queryBefore + fieldsString + queryAfter);
			List<FieldsWrapper> fieldsWrapperList = new List<FieldsWrapper>();
			for(sObject sobj : sobjectList) {
				fieldsWrapperList = new List<FieldsWrapper>();
				for(FieldsWrapper fieldWrapper : fieldsList) {
					fieldsWrapperList.add(new FieldsWrapper(fieldWrapper.fieldAPIName, fieldWrapper.fieldLabel, (String)sobj.get(fieldWrapper.fieldAPIName)));
				}
				recordsList.add(new RecordWrapper((String)sobj.get('Id'), fieldsWrapperList));
			}
			return recordsList;
		} catch(Exception ex) {
			throw new AuraHandledException(ex.getMessage() + Label.AQ_Error_Separator + ex.getStackTraceString());
		}
	}
	

	@AuraEnabled
	public static List<FieldsWrapper> getFields( String objectAPIName ) {
		try{

			Map<String, Schema.SObjectField > mapOfAllFields = Schema.getGlobalDescribe().get( objectAPIName ).getDescribe().fields.getMap();
			List<FieldsWrapper> fieldWrapperList = new List<FieldsWrapper>();
			for( String fldName : mapOfAllFields.keySet() ) {
				if( mapOfAllFields.get( fldName ).getDescribe().isCreateable() || mapOfAllFields.get( fldName ).getDescribe().isUpdateable() ) {
					FieldsWrapper fldWrap = new FieldsWrapper( fldName, mapOfAllFields.get( fldName ).getDescribe().getLabel(), 
															String.valueOf( mapOfAllFields.get( fldName ).getDescribe().getType() ), 
															( (! mapOfAllFields.get( fldName ).getDescribe().isNillable() ) && (!mapOfAllFields.get( fldName ).getDescribe().isDefaultedOnCreate())), 
															( (! mapOfAllFields.get( fldName ).getDescribe().isNillable() ) && (!mapOfAllFields.get( fldName ).getDescribe().isDefaultedOnCreate())), '' );

					fieldWrapperList.add( fldWrap );
				}

			}	

			return fieldWrapperList;
		} catch(Exception ex) {
			throw new AuraHandledException(ex.getMessage() + Label.AQ_Error_Separator + ex.getStackTraceString());
		}
	}

	@AuraEnabled
	public static void saveTemplateData( String templateName, String objectAPIName, String fieldListJSON, String templateId ) {
		try{	
			System.debug('@@@ templateName '+templateName);
			AQ_Data_Loader_Template__c dataloader = new AQ_Data_Loader_Template__c();
			if( String.isNotBlank( templateId ) ) {
				dataloader.Id = templateId;
			}
			dataloader.Name = templateName;
			dataloader.AQ_Object_Name__c = objectAPIName;
			dataloader.AQ_Field_List_JSON__c = fieldListJSON;
			upsert dataloader;
		}catch( Exception ex ) {
			throw new AuraHandledException(ex.getMessage() + Label.AQ_Error_Separator + ex.getStackTraceString());
		}
	}

	@AuraEnabled
	public static DataLoaderWrapper getDataTemplate( String templateId ){
		try{
			DataLoaderWrapper dtLoadWrap = new DataLoaderWrapper();	
			if( String.isNotBlank( templateId ) ) {
				AQ_Data_Loader_Template__c dtLoadObj = [SELECT Id, AQ_Object_Name__c, AQ_Field_List_JSON__c FROM AQ_Data_Loader_Template__c WHERE Id =: templateId LIMIT 1]; 
				dtLoadWrap.objectName = dtLoadObj.AQ_Object_Name__c;
				dtLoadWrap.selectedFields = dtLoadObj.AQ_Field_List_JSON__c;
				dtLoadWrap.fields = JSON.serialize( getFields( dtLoadObj.AQ_Object_Name__c ) );
			}
			return dtLoadWrap;
		}catch( Exception ex ) {
			throw new AuraHandledException(ex.getMessage() + Label.AQ_Error_Separator + ex.getStackTraceString());
		}
	}

	@AuraEnabled
	public static void deleteRowApex(String recordId) {
		try {
			SObject sobj = Id.valueOf(recordId).getSobjectType().newSobject(recordId);
			delete new List<SObject> { sobj };
		} catch(Exception ex) {
			throw new AuraHandledException(ex.getMessage() + Label.AQ_Error_Separator + ex.getStackTraceString());
		}
	}

	@AuraEnabled
	public static void deleteSuccessfulRecords( List<String> recordIds ) {
		try {
			if(! recordIds.isEmpty() ) {
				//Database.delete( recordIds, false );
				Database.executeBatch(new BatchToDeleteUploadedRecordsOnError( recordIds ) , 200);
			}
		} catch(Exception ex) {
			throw new AuraHandledException(ex.getMessage() + Label.AQ_Error_Separator + ex.getStackTraceString());
		}
	}

	@AuraEnabled
	public static CSVInfo onUploadData(List<String> fileContentData, List<Integer> indices, 
									List<String> headersfieldNames, 
									Map<String, String> headersfieldNamesWithType, 
									String objectName, Boolean allOrNone,
									String templateName, String fileName ) {
		
		String errorMessage = '';
		try {
			CSVInfo csvInUpdated = new CSVInfo();	
			csvInUpdated.csvErrorCount = 0;
			csvInUpdated.csvErrorString = '';
			csvInUpdated.successfulRecordIds = new List<String>();
			//System.debug('fileContentData :: '+fileContentData);
			System.debug('headersfieldNamesWithType :: '+headersfieldNamesWithType);
			List<String> fileContentDataLines = new List<String>();
			System.debug('fileContentData size :: '+fileContentData.size());
			List<String> fileContentDataUpdated = new List<String>();
			fileContentDataUpdated = fileContentData;
			for( String filedata : fileContentDataUpdated ) {
				List<String> tempList = new List<String>();
				
				tempList = filedata.split('\n');
				System.debug('tempList size :: '+tempList.size());
				fileContentDataLines.addAll( tempList ); 
				System.debug('fileContentDataLines size :: '+fileContentDataLines.size());
			}
           
            SObjectType objectType  = Schema.getGlobalDescribe().get(objectName);
			List<sObject> sObjects = new List<sObject>();
			System.debug('objectName :: '+objectName);
			System.debug('objectType :: '+objectType);
           for(Integer i=0;i<fileContentDataLines.size();i++){	

               SObject obj = objectType.newSObject();
			   
               List<string> csvRecordData = fileContentDataLines[i].split(',');
			  
			   Integer intVal = 0;            
               for( Integer indexVal : indices ) {      
				   if(  headersfieldNamesWithType.get( headersfieldNames[intVal] ) == 'DECIMAL'  || 
				   	    headersfieldNamesWithType.get( headersfieldNames[intVal] ) == 'DOUBLE'   ||
					    headersfieldNamesWithType.get( headersfieldNames[intVal] ) == 'CURRENCY' || 
					    headersfieldNamesWithType.get( headersfieldNames[intVal] ) == 'PERCENT' ) {
					   if( String.isNotBlank( csvRecordData[indexVal] ) ) {
						   obj.put( headersfieldNames[intVal], Decimal.valueOf( csvRecordData[indexVal] )  );
					   }else {
						   obj.put( headersfieldNames[intVal], null );
					   }
				   }else if( headersfieldNamesWithType.get( headersfieldNames[intVal] ) == 'INTEGER' ||
				   			 headersfieldNamesWithType.get( headersfieldNames[intVal] ) == 'NUMBER' ){
					   if( String.isNotBlank( csvRecordData[indexVal] ) ) {
						   obj.put( headersfieldNames[intVal], Integer.valueOf( csvRecordData[indexVal] )  );
					   }else {
						   obj.put( headersfieldNames[intVal], null );
					   }
				   }else if( headersfieldNamesWithType.get( headersfieldNames[intVal] ) == 'DATETIME' ){
					   if( String.isNotBlank( csvRecordData[indexVal] ) ) {
						   obj.put( headersfieldNames[intVal], Datetime.valueOf( csvRecordData[indexVal] )  );
					   }else {
						   obj.put( headersfieldNames[intVal], null );
					   }
				   }else if( headersfieldNamesWithType.get( headersfieldNames[intVal] ) == 'DATE' ){
					   if( String.isNotBlank( csvRecordData[indexVal] ) ) {
						   obj.put( headersfieldNames[intVal], Date.valueOf( csvRecordData[indexVal] )  );
					   }else {
						   obj.put( headersfieldNames[intVal], null );
					   }
				   }else if( headersfieldNamesWithType.get( headersfieldNames[intVal] ) == 'BOOLEAN' ){
					   if( String.isNotBlank( csvRecordData[indexVal] ) ) {
						   obj.put( headersfieldNames[intVal], Boolean.valueOf( csvRecordData[indexVal] )  );
					   }else {
						   obj.put( headersfieldNames[intVal], null );
					   }
				   }else {
					   obj.put( headersfieldNames[intVal], csvRecordData[indexVal] );
				   }
					
					intVal++; 
			   }                                                                          
               sObjects.add(obj);   
           }
			System.debug('sObjects size '+sObjects.size());
			//Database.executeBatch(new BatchToUploadRecords(sObjects, headersfieldNames, allOrNone, templateName, fileName) , 200);		
			try{
				
				Type sObjectListType = Type.ForName('List<' + objectName + '>');
				
				List<SObject> records = (List<SObject>) sObjectListType.newInstance();
				records.addAll(sObjects);

				Boolean isUpdate = headersfieldNames.contains('Id') || headersfieldNames.contains('id') || headersfieldNames.contains('ID');

				if(! isUpdate ) {
					Database.SaveResult[] srList = Database.insert( records, allOrNone );
					CSVInfo csvIn = buildCSV( srList, records, headersfieldNames );
					csvInUpdated.csvErrorString += csvIn.csvErrorString;
					csvInUpdated.csvErrorCount += csvIn.csvErrorCount; 

					//if( allOrNone ) {
						csvInUpdated.successfulRecordIds.addAll( csvIn.successfulRecordIds );
					//} 
					
				}else {
					List<sObject> recordsToInsert = (List<SObject>) sObjectListType.newInstance();
					List<sObject> recordsToUpdate = (List<SObject>) sObjectListType.newInstance();

					for(sObject sOb : records ) {
						if(String.isBlank( String.valueOf( sOb.get('Id') )) ) {
							recordsToInsert.add( sOb );
						}else {
							recordsToUpdate.add( sOb );
						}
					}

					if(! recordsToInsert.isEmpty() ) {
						Database.SaveResult[] srList = Database.insert( records, allOrNone );
						CSVInfo csvIn = buildCSV( srList, records, headersfieldNames );
						csvInUpdated.csvErrorString += csvIn.csvErrorString; 
						csvInUpdated.csvErrorCount += csvIn.csvErrorCount; 
						
						//if( allOrNone ) {
							csvInUpdated.successfulRecordIds.addAll( csvIn.successfulRecordIds );
						//}
					}

					if(! recordsToUpdate.isEmpty() ) {
						Database.SaveResult[] srList = Database.update( records, allOrNone );
						CSVInfo csvIn = buildCSV( srList, records, headersfieldNames );
						csvInUpdated.csvErrorString += csvIn.csvErrorString;
						csvInUpdated.csvErrorCount += csvIn.csvErrorCount;  
						//if( allOrNone ) {
							csvInUpdated.successfulRecordIds.addAll( csvIn.successfulRecordIds );
						//}
					}
				}     
			}catch( Exception ex ) {
				// Error message send to another batch to delete inserted records
					String htmlBodyOnError = 'Error occurred while uploading data from file - '+
											fileName+' with Template of Data Loader - '+
											templateName+'. Here are the exceptions occurred on Upload : <br><br>'+
											'&nbsp;&nbsp; * &nbsp;'+ex.getMessage()+ '<br>' ;
				
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
				String[] toAddresses = new list<string> { UserInfo.getUserEmail() };
				String subject ='Error CSV';
				email.setSubject(subject);
				email.setToAddresses( toAddresses );
				email.setHtmlBody( htmlBodyOnError );
				Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
				errorMessage = 'Error occurred while uploading data from file - '+
											fileName+' with Template of Data Loader - '+
											templateName+'. You will receive an email for the error message and rollback is proccessing in backgroud.';
				throw new AuraHandledException(ex.getMessage()+ Label.AQ_Error_Separator + ex.getStackTraceString());
			}	
			return csvInUpdated;
		} catch(Exception ex) {
			if( String.isNotBlank( errorMessage ) ) {
				throw new AuraHandledException(errorMessage + Label.AQ_Error_Separator + ex.getStackTraceString());
			}else {
				throw new AuraHandledException(ex.getMessage() + Label.AQ_Error_Separator + ex.getStackTraceString());
			}
			
		}
	}

	
	@AuraEnabled
	public static void sendMail( String errorCSVMessage, String fileName, String templateName) {
		if( String.isNotBlank( errorCSVMessage ) ) {
			String htmlBodyOnError = 'Error occurred while uploading data from file - '+
											fileName+' with Template of Data Loader - '+
											templateName+'. Here are the exceptions occurred on Upload : <br><br>'+
											'&nbsp;&nbsp; * &nbsp;'+errorCSVMessage+ '<br>' ;
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			String[] toAddresses = new list<string> { UserInfo.getUserEmail() };
			String subject ='Error CSV';
			email.setSubject(subject);
			email.setToAddresses( toAddresses );
			email.setHtmlBody( htmlBodyOnError );
			Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
		}
	}

	// Insert Records
   private static CSVInfo buildCSV( Database.SaveResult[] srList, List<sObject> records, List<String> headersfieldNames ) {
      List<String> successfulRecordIds = new List<String>();
	  String csvStringForError = '';
	  Integer csvErrorCount = 0;
      for (Integer ind = 0; ind < srList.size(); ind++) {
         if(! srList[ind].isSuccess()) {
			 csvErrorCount++;
            for( String fld : headersfieldNames ) {
               csvStringForError += String.valueOf( records[ind].get(fld) ) + ',';
            }
            
            for( Database.Error err : srList[ind].getErrors() ) {
               csvStringForError += err.getMessage()+' and fields that affected this error: '+err.getFields()+'\n';
            }

         }else {
            successfulRecordIds.add( srList[ind].getId() );
            
         }
      }

	  CSVInfo csvIn = new CSVInfo();
	  csvIn.csvErrorCount = csvErrorCount;
	  csvIn.csvErrorString = csvStringForError;
	  csvIn.successfulRecordIds = successfulRecordIds;
	  return csvIn;
   }

	public class CSVInfo {
		@AuraEnabled public String csvErrorString;
		@AuraEnabled public Integer csvErrorCount;
		@AuraEnabled public List<String> successfulRecordIds;

	}

	public class DataLoaderWrapper {
		@AuraEnabled public String objectName;
		@AuraEnabled public String fields;
		@AuraEnabled public String selectedFields;

	}
    public class RecordWrapper {
		@AuraEnabled public String recordId;
		@AuraEnabled public List<FieldsWrapper> fieldsList;

		public RecordWrapper(String recordId, List<FieldsWrapper> fieldsList ) {
			this.recordId = recordId;
			this.fieldsList = fieldsList;
		}
	}

	public class FieldsWrapper {
		@AuraEnabled public String fieldAPIName;
		@AuraEnabled public String fieldLabel;
		@AuraEnabled public String fieldValue;
		@AuraEnabled public String fieldType;
		@AuraEnabled public Boolean isRequired;
		@AuraEnabled public Boolean isDisabled;
		@AuraEnabled public String mappedHeader;

		public FieldsWrapper(String fieldAPIName, String fieldLabel, String fieldValue) {
			this.fieldAPIName = fieldAPIName;
			this.fieldLabel = fieldLabel;
			this.fieldValue = fieldValue;
		}
		public FieldsWrapper(String fieldAPIName, String fieldLabel, String fieldType, Boolean isRequired, Boolean isDisabled, String mappedHeader) {
			this.fieldAPIName = fieldAPIName;
			this.fieldLabel = fieldLabel;
			this.fieldType = fieldType;
			this.isRequired = isRequired;
			this.isDisabled = isDisabled;
			this.mappedHeader = mappedHeader;
		}

		
	}
}