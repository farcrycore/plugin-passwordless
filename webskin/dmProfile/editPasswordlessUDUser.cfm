<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit passwordlessUD User --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<!--- check permissions --->
<cfif NOT application.security.checkPermission(permission="SecurityManagement")>
	<skin:view typename="farCOAPI" webskin="webtopBodyNotFound" />
	<cfexit method="exittemplate">
</cfif>

<cfset oUser = createobject("component",application.stCOAPI.farPasswordlessUser.packagepath) />


<!----------------------------- 
ACTION	
------------------------------>
<ft:serverSideValidation />

<ft:processform action="Save Profile" exit="true">
	<ft:processformobjects typename="farPasswordlessUser" lArrayListGenerate="lgroups" />
	
	<!--- track whether we have saved a farPasswordlessUser record--->
	<cfset savedUserID = lsavedobjectids />
	
	<ft:processformobjects typename="dmProfile">
		
		<!--- We only check the profile/farPasswordlessUser relationship if we saved a passwordlessUD user --->
		<cfif len(savedUserID)>
			<cfset stUser = oUser.getData(objectid=savedUserID) />
			
			<!--- If the current username is not the same one we saved (ie. new user) --->
			<cfif stProperties.username NEQ "#stUser.objectid#_passwordlessUD"><!--- New user --->
				<cfset stProperties.username = "#stUser.objectid#_passwordlessUD" />
				<cfset stProperties.userdirectory = "passwordlessUD" />
			</cfif>
		</cfif>			
		
	</ft:processformobjects>
</ft:processform>

<ft:processform action="Cancel" exit="true" />


<!----------------------------- 
VIEW	
------------------------------>
<cfoutput>
	<h2>User <cfif listlen(stObj.username,"_")> #listdeleteat(stObj.username,listlen(stObj.username,"_"),"_")#<cfelse>#stObj.username#</cfif> <small>Directory #stObj.userdirectory#</small></h2>
</cfoutput>

<ft:form>
	<ft:object objectid="#stObj.objectid#" typename="dmProfile" 
		lfields="firstname,lastname,avatar,emailaddress,phone,breceiveemail"
		lhiddenFields="username,userdirectory"
		legend="Profile Details" />
	<ft:object objectid="#stObj.objectid#" typename="dmProfile" 
		lfields="locale,overviewHome"
		legend="Webtop Settings" />
	<ft:object objectid="#stObj.objectid#" typename="dmProfile" 
		lFields="username,userdirectory,lastLogin" format="display"
		legend="Login Details" />

	<!--- passwordlessUD: user directory options only for FarCry Directory profiles --->
	<cfif stObj.userdirectory eq "passwordlessUD" or stObj.userdirectory eq "">
		<cfset userID = application.factory.oUtils.listSlice(stObj.username,1,-2,"_") />
		<cfset stUser = oUser.getByUserID(userID) />

		<cfif NOT structIsEmpty(stUser) AND stUser.userid neq "">
			<ft:object stObject="#stUser#" typename="farPasswordlessUser" lfields="aGroups" legend="FarCry User Directory Settings" />
		</cfif>		
	</cfif>
	
	<ft:buttonPanel>
		<ft:button value="Save Profile" />
		<ft:button value="Cancel" validate="false" />
	</ft:buttonPanel>
</ft:form>

<cfsetting enablecfoutputonly="false" />