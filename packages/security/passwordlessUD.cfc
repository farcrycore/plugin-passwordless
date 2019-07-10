<cfcomponent displayname="Passwordless User Directory" extends="farcry.core.packages.security.UserDirectory" output="false" seq="1000"
	key="passwordlessUD">

	<cffunction name="getLoginForm" access="public" output="false" returntype="string" hint="Returns the form component to use for login">
		<cfreturn "farPasswordlessLogin" />	
	</cffunction>

	<cffunction name="getProfile" access="public" output="false" returntype="struct" hint="Returns profile data available through the user directory">
		<cfargument name="userid" type="string" required="true" hint="The user directory specific user id" />
		<cfargument name="currentprofile" type="struct" default="#structNew()#" hint="The current user profile; from user directory." />
		<cfargument name="stCurrentProfile" type="struct" default="#structNew()#" hint="The current user profile; according to session." />

		<cfset var stUserProfile = application.fapi.getContentType(typename="farPasswordlessUser").getProfile(arguments.userid)>
		<cfset var stCurrentProfile = duplicate(arguments.currentprofile)>
		<cfset structAppend(stUserProfile, stCurrentProfile, true) />

		<cfreturn stUserProfile />
	</cffunction>


	<cffunction name="generateToken" output="false" hint="Returns a random token">
		<cfargument name="length" type="numeric" default="6" required="false">

		<cfset var token = "">
		<cfset var i = 0>

		<cfset var pool = "A,C,D,E,F,G,H,J,K,M,N,P,Q,R,T,U,V,W,X,Y,Z,2,3,4,6,7,9">

		<cfloop from="1" to="#arguments.length#" index="i">
			<cfset var offset = randRange(1, listLen(pool))>
			<cfset token &= listGetAt(pool, offset)>
		</cfloop>

		<cfreturn token>
	</cffunction>

	<cffunction name="createSessionToken" output="false" returntype="string">
		<cfargument name="mobile" type="string" default="">
		<cfargument name="email" type="string" default="">

		<cfset var token = generateToken(length=application.fapi.getConfig("passwordless", "tokenLength", 6))>
		<cfset var key = generateCacheKey(token)>

		<cfset var stData = {
			mobile: arguments.mobile,
			email: arguments.email
		}>

		<cfset application.fc.lib.objectbroker.cacheAdd(key=key, data=stData, timeout=application.fapi.getConfig("passwordless", "tokenTimeout", 900))>

		<cfreturn token>
	</cffunction>

	<cffunction name="lookupSessionToken" output="false" returntype="struct">
		<cfargument name="token" type="string" required="true">

		<cfset var key = generateCacheKey(arguments.token)>
		<cfset var stResult = application.fc.lib.objectbroker.cachePull(key=key)>

		<cfreturn stResult>
	</cffunction>


	<cffunction name="generateCacheKey" output="false">
		<cfargument name="token" type="string" required="true">

		<cfset var salt = application.fapi.getConfig("passwordless", "salt", "")>
		<cfset var key = "#application.applicationname#_farPasswordlessLogin_#hash(salt & arguments.token, "SHA")#">

		<cfreturn key>		
	</cffunction>


	<cffunction name="authenticate" access="public" output="true" returntype="struct" hint="Attempts to process a user. Runs every time the login form is loaded.">

		<cfset var stResult = structnew() />
		<cfset var oUser = application.fapi.getContentType("farPasswordlessUser") />
		<cfset var oGroup = application.fapi.getContentType("farPasswordlessGroup") />
		<cfset var stUser = structnew() />
		<cfset var stGroup = structnew() />
		<cfset var item = "">
		<cfset var i = 0>


		<cfif structKeyExists(url, "token") and len(url.token)>

			<!--- lookup session token to validate login --->
			<cfset stResult = lookupSessionToken(token=url.token)>

			<cfif structIsEmpty(stResult)>
				<cfset stResult.authenticated = false />
				<cfset stResult.message = "Your login token was not found or has expired. Please try again." />
				<cfset stResult.userid = "" />
				<cfset stResult.ud = "passwordlessUD" />

			<cfelse>

				<cfparam name="stResult.mobile" default="">
				<cfparam name="stResult.email" default="">

				<!--- set a userid --->
				<cfset stResult.userid = stResult.mobile>
				<cfif NOT len(trim(stResult.userid))>
					<cfset stResult.userid = stResult.email>
				</cfif>

				<!--- look up user --->
				<cfif stResult.userid eq stResult.mobile>
					<cfset stUser = oUser.getByMobile(stResult.mobile)>
				</cfif>
				<cfif stResult.userid eq stResult.email>
					<cfset stUser = oUser.getByEmail(stResult.email)>
				</cfif>
				
				<!--- if there is no user record create one --->
				<cfif structIsEmpty(stUser)>
					<cfset stUser = oUser.getData(createUUID())>
				</cfif>

				<cfif len(stResult.mobile)>
					<cfset stUser.mobile = stResult.mobile>
				</cfif>
				<cfif len(stResult.email)>
					<cfset stUser.email = stResult.email>
				</cfif>
				<cfset stUser.label = trim(stResult.email & " " & stResult.mobile)>

				<!--- save user object --->
				<cfset oUser.setData(stProperties=stUser, bAudit=false)>

				<!--- set up result --->
				<cfset stResult.authenticated = true />
				<cfset stResult.userid = stUser.objectid>
				<cfset stResult.ud = "passwordlessUD" />					

			</cfif>

		</cfif>

		<cfreturn stResult />
	</cffunction>

	<cffunction name="getUserGroups" access="public" output="false" returntype="array" hint="Returns the groups that the specified user is a member of">
		<cfargument name="userid" type="string" required="true" hint="The user being queried">
		
		<cfset var qGroups = "" />
		<cfset var aGroups = arraynew(1) />
		
		<cfquery datasource="#application.dsn#" name="qGroups">
			SELECT g.title
			FROM	
				#application.dbowner#farPasswordlessUser u
				INNER JOIN #application.dbowner#farPasswordlessUser_aGroups ug on u.objectid = ug.parentid
				INNER JOIN #application.dbowner#farPasswordlessGroup g on ug.data = g.objectid
			WHERE
				u.objectid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userid#">
		</cfquery>
		
		<cfloop query="qGroups">
			<cfset arrayappend(aGroups,title)>
		</cfloop>
		
		<cfreturn aGroups />
	</cffunction>
	
	<cffunction name="getAllGroups" access="public" output="false" returntype="array" hint="Returns all the groups that this user directory supports">
		<cfset var qGroups = "" />
		<cfset var aGroups = arraynew(1) />
		
		<cfquery datasource="#application.dsn#" name="qGroups">
			select		*
			from		#application.dbowner#farPasswordlessGroup
			order by	title
		</cfquery>
		
		<cfloop query="qGroups">
			<cfset arrayappend(aGroups,title) />
		</cfloop>

		<cfreturn aGroups />
	</cffunction>

	<cffunction name="getGroupUsers" access="public" output="false" returntype="array" hint="Returns all the users in a specified group">
		<cfargument name="group" type="string" required="true" hint="The group to query">

		<cfset var qUsers = "">

		<cfquery datasource="#application.dsn#" name="qUsers">
			SELECT	u.objectid AS userid
			FROM
				#application.dbowner#farPasswordlessUser u
				INNER JOIN #application.dbowner#farPasswordlessUser_aGroups ug on u.objectid = ug.parentid
				INNER JOIN #application.dbowner#farPasswordlessGroup g on ug.data = g.objectid
			WHERE
				g.title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.group#">
				AND u.userstatus=<cfqueryparam cfsqltype="cf_sql_varchar" value="active">
		</cfquery>

		<cfreturn listToArray(valueList(qUsers.userid))>
	</cffunction>


</cfcomponent>