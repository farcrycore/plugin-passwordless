<cfcomponent displayname="Passwordless UD Group" extends="farcry.core.packages.types.types">

	<cfproperty name="title" type="string" default="" 
		ftSeq="1" ftFieldset="" ftLabel="Title" 
		ftType="string">

	<cfproperty name="description" type="longchar" default=""
		ftSeq="2" ftFieldset="" ftLabel="Description" 
		ftType="longchar">

	<cfproperty name="bStickyGroup" type="boolean" default="false" 
		ftSeq="3" ftFieldset="" ftLabel="Sticky Group" 
		ftType="boolean"
		ftHint="Check this box to make this group sticky, meaning users will not be automatically removed from this group if their description changes. This is useful for group/role mappings like SiteAdmin.">



	<cffunction name="getID" access="public" output="false" returntype="string" hint="Returns the objectid for the specified object (name can be the objectid or the title)">
		<cfargument name="name" type="string" required="true" hint="Pass in a role name and the objectid will be returned" />
		
		<cfset var qItem = "" />
		
		<cfif isvalid("uuid",arguments.name)>
			<cfreturn arguments.name />
		<cfelse>
			<cfquery datasource="#application.dsn#" name="qItem">
				select	*
				from	#application.dbOwner#farPasswordlessGroup
				where	lower(title)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.name)#" />
			</cfquery>
			
			<cfreturn qItem.objectid[1] />
		</cfif>
	</cffunction>
	
	<cffunction name="delete" access="public" hint="Removes any corresponding entries in farPasswordlessUser" returntype="struct" output="false">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="">
		
		<cfset var stUser = structnew() />
		<cfset var qUser = "" />
		<cfset var oUser = createObject("component", application.stcoapi["farPasswordlessUser"].packagePath) />
		
		<cfquery datasource="#application.dsn#" name="qUser">
			select	*
			from	#application.dbowner#farPasswordlessUser_aGroups
			where	data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
		</cfquery>
		
		<cfloop query="qUser">
			<cfset stUser = oUser.getData(parentid) />
			<cfset arraydeleteat(stUser.aGroups,seq) />
			<cfset oUser.setData(stProperties=stUser) />
		</cfloop>
		
		<cfreturn super.delete(objectid=arguments.objectid,user=arguments.user,auditNote=arguments.auditNote) />
	</cffunction>
	
	<cffunction name="afterSave" access="public" output="false" returntype="struct" hint="Processes new type content">
		<cfargument name="stProperties" type="struct" required="true" hint="The properties that have been saved" />
		
		<cfset application.security.initCache() />
		
		<cfreturn arguments.stProperties />
	</cffunction>
	
</cfcomponent>