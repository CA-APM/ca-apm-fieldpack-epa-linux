#Windows WMI Monitoring (1.0)

Description
This EPAgent field pack provides a mechanism to monitor linux based system. This is a framework where it provides the certain routine metrics out of the box and for others provides an easy mechanism to extend either using config file and providing your own script


##APM version

Tested on 9.1 and Java 1.5+ 



##Limitations

What the field pack will not do.

##License

[Apache License 2.0](LICENSE).

##Installation Instructions

standard plugin installation. Add the plugin as stateful EPA plugin

introscope.epagent.plugins.stateful.names=LINUX

introscope.epagent.stateful.LINUX.command=perl /opt/EPAgent/epaplugins/linux/EPAgentMain.pl
 

##Prerequisites

Plugin requires Perl 5.8 or higher. with following perl modules
o       XML::Simple
o       Data::Dumper;
o       File::Basename
o       FindBin


##Dependencies


##Configuration

Refer to the config.txt under docs

##Debugging and Troubleshooting

1. look for error msg in the agent log

Support

This document and associated tools are made available from CA Technologies as examples and provided at no charge as a courtesy to the CA APM Community at large. This resource may require modification for use in your environment. However, please note that this resource is not supported by CA Technologies, and inclusion in this site should not be construed to be an endorsement or recommendation by CA Technologies. These utilities are not covered by the CA Technologies software license agreement and there is no explicit or implied warranty from CA Technologies. They can be used and distributed freely amongst the CA APM Community, but not sold. As such, they are unsupported software, provided as is without warranty of any kind, express or implied, including but not limited to warranties of merchantability and fitness for a particular purpose. CA Technologies does not warrant that this resource will meet your requirements or that the operation of the resource will be uninterrupted or error free or that any defects will be corrected. The use of this resource implies that you understand and agree to the terms listed herein.

Although these utilities are unsupported, please let us know if you have any problems or questions by adding a comment to the CA APM Community Site area where the resource is located, so that the Author(s) may attempt to address the issue or question.

Unless explicitly stated otherwise this field pack is only supported on the same platforms as the APM core agent. See APM Compatibility Guide.

Contributing
The CA APM Community is the primary means of interfacing with other users and with the CA APM product team. The developer subcommunity is where you can learn more about building APM-based assets, find code examples, and ask questions of other developers and the CA APM product team.

If you wish to contribute to this or any other project, please refer to easy instructions available on the CA APM Developer Community.

Change log
Changes for each version of the field pack.

Version	Author		Comment
1.0	srikant Noorani	First version of the field pack.
