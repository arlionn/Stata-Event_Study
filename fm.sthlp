{smcl}
{* *! version 1.0 21 Aug 2016}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "fm##syntax"}{...}
{viewerjumpto "Description" "fm##description"}{...}
{viewerjumpto "Options" "fm##options"}{...}
{viewerjumpto "Remarks" "fm##remarks"}{...}
{viewerjumpto "Examples" "fm##examples"}{...}
{title:Title}
{phang}
{bf:fm} {hline 2} <insert title here>

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:fm}
[if]
[{help in}]
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt first(string)}} .{p_end}
{synopt:{opt lags(#)}} Default value is 0.{p_end}
{synopt:{opt file(string)}} .{p_end}
{synopt:{opt replace}} .{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
{cmd:fm} does ... <insert description>

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt first(string)}  

{phang}
{opt lags(#)}  Default value is 0

{phang}
{opt file(string)}  

{phang}
{opt replace}  


{marker examples}{...}
{title:Examples}

{phang} <insert example command>

{title:Author}
{p}

<insert name>, <insert institution>.

Email {browse "mailto:firstname.givenname@domain":firstname.givenname@domain}

{title:See Also}

NOTE: this part of the help file is old style! delete if you don't like

Related commands:

{help command1} (if installed)
{help command2} (if installed)   {stata ssc install command2} (to install this command)
