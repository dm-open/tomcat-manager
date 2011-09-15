Tomcat Manager
==============

What?
-----

A simple skin for the XML view of the manager status page included with tomcat, compromising an XSLT stylesheet and a CSS file.

Why?
----

Visit http://localhost:8080/manager/status for one of your tomcat instances. Not pretty is it? What I was after was something more useful.

Installation
------------
Copy xform.xsl and the css folder to your tomcat manager webapp root (e.g webapps/manager) and visit:
http://localhost:8080/manager/status?XML=true



