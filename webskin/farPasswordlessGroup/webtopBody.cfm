<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Passwordless Group Webtop Body --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft">

<ft:objectAdmin
	typename="#stObj.name#"
	columnList="label,status,bStickyGroup,datetimecreated,datetimelastupdated"
	sortableColumns="label,status,bStickyGroup,datetimecreated,datetimelastupdated"
	lFilterFields="label"
	sqlOrderBy="label ASC" />


<cfsetting enablecfoutputonly="false">