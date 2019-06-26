<cfcomponent extends="farcry.core.packages.formtools.field" name="string" displayname="string" hint="Field component to liase with all string types"> 
	
	<cfproperty name="ftInitialCountry" required="false" default="AU" hint="The initial country to select by default">
	<cfproperty name="ftPreferredCountries" required="false" default="AU" hint="A list of the preferred countries to show at the top of the dropdown list">
	<cfproperty name="ftFormatOnDisplay" required="false" default="true" hint="Set to true to dynamically format the number as the user enters it">
	<cfproperty name="ftNationalMode" required="false" default="true" hint="Set to true to display national style phone numbers or false to display full international numbers">
	<cfproperty name="ftPlaceholder" required="false" default="" hint="A placeholder string for an example phone number">
	<cfproperty name="ftAutoPlaceholder" required="false" default="polite" hint="Set the inputs placeholder to an example number for the selected country and update it if the country changes, or turn it off">
	<cfproperty name="ftUtilsScript" required="false" default="/passwordless/js/utils.js?1549804213570" hint="Path to the required utils script for formatting and validating phone numbers">


	<cffunction name="init" access="public" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>


	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="inputClass" required="false" type="string" default="" hint="This is the class value that will be applied to the input field.">

		<cfset var html = "">

		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">

		<skin:loadJS id="intltelinputJS" />
		<skin:loadJS id="intltelinputUtilJS" />
		<skin:loadCSS id="intltelinputCSS" />

		<cfsavecontent variable="html">
			<cfoutput>
				<input id="#arguments.fieldname#_display" name="#arguments.fieldname#_display" type="tel" class="textInput #arguments.inputClass# #arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" value="#application.fc.lib.esapi.encodeForHTMLAttribute(arguments.stMetadata.value)#" placeholder="#arguments.stMetadata.ftPlaceholder#"><br>
				<input id="#arguments.fieldname#" name="#arguments.fieldname#" type="hidden" value="#application.fc.lib.esapi.encodeForHTMLAttribute(arguments.stMetadata.value)#">

				<script>
					var telInput#arguments.fieldname# = document.querySelector("###arguments.fieldname#_display");

					var iti#arguments.fieldname# = window.intlTelInput(telInput#arguments.fieldname#, {
						initialCountry: "#arguments.stMetadata.ftInitialCountry#",
						preferredCountries: [#listQualify(arguments.stMetadata.ftPreferredCountries,"""", ",")#],
						formatOnDisplay: #arguments.stMetadata.ftFormatOnDisplay#,
						nationalMode: #arguments.stMetadata.ftNationalMode#,
						autoPlaceholder: "#arguments.stMetadata.ftAutoPlaceholder#",
						utilsScript: "#arguments.stMetadata.ftUtilsScript#"
					});

					var itiUpdate#arguments.fieldname# = function() {
						if (typeof intlTelInputUtils !== 'undefined') {
							var currentText = iti#arguments.fieldname#.getNumber(intlTelInputUtils.numberFormat.E164);
							if (typeof currentText === 'string') {
								iti#arguments.fieldname#.setNumber(currentText);
								var telInputIntl = document.querySelector("###arguments.fieldname#");
								telInputIntl.value = currentText;
							}
						}
					};
					telInput#arguments.fieldname#.addEventListener('change', itiUpdate#arguments.fieldname#);
					telInput#arguments.fieldname#.addEventListener('keyup', itiUpdate#arguments.fieldname#);
				</script>

			</cfoutput>
		</cfsavecontent>

		<cfreturn html>
	</cffunction>


</cfcomponent> 