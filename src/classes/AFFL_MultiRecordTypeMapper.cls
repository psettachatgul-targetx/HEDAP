/*
    Copyright (c) 2014, Salesforce.com Foundation
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Salesforce.com Foundation nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
 
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.
*/
public with sharing class AFFL_MultiRecordTypeMapper {

	//Map of Contact field names to Contact field labels.
	public Map<String, String> contactLabelNames;
		
    //Affiliation Account-record-type-to-Contact-field mappings.
    public Map<String, String> mappingsRecTypesToLabels;
    
    //List of primary affiliation lookup fields names on Contact.
    public List<String> primaryAfflFieldNames;
    
    public AFFL_MultiRecordTypeMapper() {
    	//List of Contact field names.
		List<SObjectField> contactFields = Contact.sObjectType.getDescribe().fields.getMap().values();
		
		//Map of Contact field labels to Contact field Names.
		contactLabelNames = getContactLabelsNamesMap(contactFields);
		
		//List of primary affiliation lookup fields names.
		List<String> contactFieldNames = contactLabelNames.values();
		
		//Affiliation Account-record-type-to-Contact-field mappings.
		mappingsRecTypesToLabels = getPrimaryAfflMappings();
		UTIL_Debug.debug('****MRT: primaryAfflMappings: ' + JSON.serializePretty(mappingsRecTypesToLabels)); 
		
		//List of primary affiliation lookup fields names.
		List<String> primaryAfflFieldLabels = mappingsRecTypesToLabels.values();
		UTIL_Debug.debug('****MRT: primaryAfflFieldLabels: ' + JSON.serializePretty(primaryAfflFieldLabels));
		
		//List of primary affiliation Contact fields.
		List<SObjectField> primaryAfflFields = getPrimaryAfflFields(contactFields, primaryAfflFieldLabels);
		UTIL_Debug.debug('****MRT: primaryAfflFieldNames: ' + JSON.serializePretty(primaryAfflFieldNames));
    }
    
    private Map<String, String> getContactLabelsNamesMap(List<SObjectField> cf) {
    	Map<String, String> labelsnames = new Map<String, String>();
		for(SObjectField field : cf) {
			labelsnames.put(field.getDescribe().getLabel(), field.getDescribe().getName());
		}
		return labelsnames;
    }
    
    private Map<String, String> getPrimaryAfflMappings() {
		Map<String, String> mappings = new Map<String, String>();
		//Get the affiliation Account-record-type-to-Contact-field mappings.
		List<Affl_Mappings__c> primaryAfflMappings = [select Account_Record_Type__c, Primary_Affl_Field__c from Affl_Mappings__c];
		//Put them in a map.
		for(Affl_Mappings__c mapping : primaryAfflMappings) {
			if(!String.isBlank(mapping.Account_Record_Type__c) && !String.isBlank(mapping.Primary_Affl_Field__c)) {
				mappings.put(mapping.Account_Record_Type__c, mapping.Primary_Affl_Field__c);
			}
		}
		return mappings;
	}
	
	private List<SObjectField> getPrimaryAfflFields(List<SObjectField> cf, List<String> primaryAfflFieldLabels) {
		Set<String> primaryAfflFieldLabelsSet = new Set<String>(primaryAfflFieldLabels);
		List<SObjectField> primaryFields = new List<SObjectField>();
		primaryAfflFieldNames = new List<String>();
		for(SObjectField field : cf) {
			if(primaryAfflFieldLabelsSet.contains(field.getDescribe().getLabel())) {
				primaryAfflFieldNames.add(field.getDescribe().getName());
				primaryFields.add(field);
			}
		}
		return primaryFields;
	}
	
	public String getKeyAfflFieldByAccRecordType(ID recordTypeId) {
		for(String recTypeName : mappingsRecTypesToLabels.keySet()) {
    		ID rcId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
    		if(rcId == recordTypeId) {
    			String fieldLabel = mappingsRecTypesToLabels.get(recTypeName);
    			String fieldName = contactLabelNames.get(fieldLabel);
    			return fieldName;
    		}
		}
		return null;
    }
}