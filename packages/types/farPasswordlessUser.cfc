<cfcomponent displayname="Passwordless UD User" extends="farcry.core.packages.types.types">

	<cfproperty name="mobile" type="string" default="" required="true"
		ftSeq="1" ftFieldset="User" ftLabel="Mobile Phone" bLabel="true"
		ftType="string">

	<cfproperty name="email" type="string" default="" required="true"
		ftSeq="2" ftFieldset="User" ftLabel="Email" bLabel="true"
		ftType="string">

	<cfproperty name="aGroups" type="array" default=""
		ftSeq="31" ftFieldset="Permissions" ftLabel="Groups" 
		ftType="array" ftJoin="farPasswordlessGroup"
		hint="The groups this member is a member of">

	<cfproperty name="lGroups" type="longchar" default="" 
		ftType="arrayList" ftArrayField="aGroups" ftJoin="farPasswordlessGroup"
		hint="The groups this member is a member of (list generated automatically)">


	<!--- TODO: autosetlabel --->


	<cffunction name="getProfile" access="public" output="false" returntype="struct" hint="Returns profile data available through the user directory">
		<cfargument name="userid" type="string" required="true" hint="The user directory specific user id" />
		
		<cfset var stUser = structNew()>
		<cfset var stUserProfile = structNew()>
		<cfset stUserProfile.override = false>
		
		<cfif isValid("uuid", arguments.userid)>
			<cfset stUser = getData(objectid=arguments.userid)>
		<cfelseif isValid("email", arguments.userid)>
			<cfset stUser = getByEmail(arguments.userid)>
		<cfelse>	
			<cfset stUser = getByMobile(arguments.userid)>
		</cfif>

		<cfif NOT structIsEmpty(stUser)>
			<cfset stUserProfile.override = true>
			<cfif len(stUser.label)>
				<cfset stUserProfile.label = stUser.label>
			</cfif>
			<cfif len(stUser.mobile)>
				<cfset stUserProfile.phone = stUser.mobile>
			</cfif>
			<cfif len(stUser.email)>
				<cfset stUserProfile.emailaddress = stUser.email>
			</cfif>
			<cfset stUserProfile.username = arguments.userid & "_passwordlessUD">
		</cfif>

		<cfreturn stUserProfile>
	</cffunction>


	<cffunction name="getByUserID" access="public" output="false" returntype="struct" hint="Returns the data struct for the specified user mobile">
		<cfargument name="userid" type="string" required="true" hint="The userid which could be a mobile number or an email address" />
		
		<cfset var stUser = structNew()>
		
		<cfif isValid("uuid", arguments.userid)>
			<cfset stUser = getData(objectid=arguments.userid)>
		<cfelseif isValid("email", arguments.userid)>
			<cfset stUser = getByEmail(arguments.userid)>
		<cfelse>	
			<cfset stUser = getByMobile(arguments.userid)>
		</cfif>

		<cfif NOT structIsEmpty(stUser)>
			<cfset stUser.userid = arguments.userid>
		</cfif>

		<cfreturn stUser />
	</cffunction>

	<cffunction name="getByMobile" access="public" output="false" returntype="struct" hint="Returns the data struct for the specified user mobile">
		<cfargument name="mobile" type="string" required="true" hint="The mobile phone number" />
		
		<cfset var stResult = structnew() />
		<cfset var qUser = "" />
		
		<cfquery datasource="#application.dsn#" name="qUser">
			select	*
			from	#application.dbowner#farPasswordlessUser
			where	lower(mobile)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.mobile)#" />
		</cfquery>
		
		<cfif qUser.recordcount>
			<cfset stResult = getData(qUser.objectid) />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>

	<cffunction name="getByEmail" access="public" output="false" returntype="struct" hint="Returns the data struct for the specified user email">
		<cfargument name="email" type="string" required="true" hint="The email address" />
		
		<cfset var stResult = structnew() />
		<cfset var qUser = "" />
		
		<cfquery datasource="#application.dsn#" name="qUser">
			select	*
			from	#application.dbowner#farPasswordlessUser
			where	lower(email)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.email)#" />
		</cfquery>
		
		<cfif qUser.recordcount>
			<cfset stResult = getData(qUser.objectid) />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>


	<cffunction name="addGroup" access="public" output="false" returntype="void" hint="Adds this user to a group">
		<cfargument name="user" type="string" required="true" hint="The user to add" />
		<cfargument name="group" type="string" required="true" hint="The group to add to" />
		
		<cfset var stUser = structnew() />
		<cfset var stGroup = structnew() />
		<cfset var oGroup = createObject("component", application.stcoapi["farPasswordlessGroup"].packagePath) />
		<cfset var i = 0 />
		
		<!--- Get the user by objectid or userid --->
		<cfif isvalid("uuid",arguments.user)>
			<cfset stUser = getData(arguments.user) />
		<cfelseif isValid("email", arguments.user)>
			<cfset stUser = getByEmail(arguments.user)>
		<cfelse>	
			<cfset stUser = getByMobile(arguments.user)>
		</cfif>

	
		<cfif not isvalid("uuid",arguments.group)>
			<cfset arguments.group = oGroup.getID(arguments.group) />
		</cfif>
		
		<!--- Check to see if they are already a member of the group --->
		<cfparam name="stUser.aGroups" default="#arraynew(1)#" />
		<cfloop from="1" to="#arraylen(stUser.aGroups)#" index="i">
			<cfif stUser.aGroups[i] eq arguments.group>
				<cfset arguments.group = "" />
			</cfif>
		</cfloop>
		
		<cfif len(arguments.group)>
			<cfset arrayappend(stUser.aGroups,arguments.group) />
			<cfset setData(stProperties=stUser) />
		</cfif>
	</cffunction>

	<cffunction name="removeGroup" access="public" output="false" returntype="void" hint="Removes this user from a group">
		<cfargument name="user" type="string" required="true" hint="The user to add" />
		<cfargument name="group" type="string" required="true" hint="The group to add to" />
		
		<cfset var stUser = structnew() />
		<cfset var i = 0 />
		<cfset var oGroup = createObject("component", application.stcoapi["farPasswordlessGroup"].packagePath) />
		
		<!--- Get the user by objectid or userid --->
		<cfif isvalid("uuid",arguments.user)>
			<cfset stUser = getData(arguments.user) />
		<cfelseif isValid("email", arguments.user)>
			<cfset stUser = getByEmail(arguments.user)>
		<cfelse>	
			<cfset stUser = getByMobile(arguments.user)>
		</cfif>
		
		<cfif not isvalid("uuid",arguments.group)>
			<cfset arguments.group = oGroup.getID(arguments.group) />
		</cfif>
		
		<!--- Check to see if they are a member of the group --->
		<cfparam name="stUser.aGroups" default="#arraynew(1)#" />
		<cfloop from="#arraylen(stUser.aGroups)#" to="1" index="i" step="-1">
			<cfif stUser.aGroups[i] eq arguments.group>
				<cfset arraydeleteat(stUser.aGroups,i) />
			</cfif>
		</cfloop>
		
		<cfset setData(stProperties=stUser) />
	</cffunction>
	
</cfcomponent>