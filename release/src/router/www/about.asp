<title>About</title>
<content>
	<div class="fluid-grid x3">
		<div class="box"><div class="heading">RipeTomato Firmware</div>
			<div class="content">
				<strong><% version(1); %></strong>
				<ul>
					<li>Built: <% build_time(); %></li>
					<li>More stuff!</li>
					<li><em>Made possible by all the projects on this page!</em></li>
				</ul>
			       Copyright &copy; 2014 Jeffrey Clark<br/>
			</div>
	       </div>

		<div class="box"><div class="heading">Tomato Firmware</div>
			<div class="content">
				<!-- USB-BEGIN -->
				USB support integration and GUI,<br>
				<!-- USB-END -->
				<!-- IPV6-BEGIN -->
				IPv6 support,
				<!-- IPV6-END -->
				<br>
				Linux kernel <% version(2); %> and Broadcom Wireless Driver <% version(3); %> updates,<br>
				support for additional router models, dual-band and Wireless-N mode.<br>
				Copyright (C) 2008-2011 Fedor Kozhevnikov, Ray Van Tassle, Wes Campaigne<br>
				<a href='http://www.tomatousb.org/' target='_new'>http://www.tomatousb.org</a><br>
				<!-- / / / -->
			</div>
		</div>

		<div class="box"><div class="heading">AdvancedTomato</div>
			<div class="content">
				- Full interface re-design<br />
				- GUI improvements and changes<br />
				- Based on Tomato by Shibby <br />
				Copyright (C) 2014 <a href="http://prahec.com/">Jacky</a>
			</div>
		</div>

		<!-- OPENVPN-BEGIN -->
		<div class="box"><div class="heading">OpenVPN integration and GUI</div>
			<div class="content">
				Copyright (C) 2010 Keith Moyer,<br>
				<a href='mailto:tomatovpn@keithmoyer.com'>tomatovpn@keithmoyer.com</a><br>
			</div>
		</div>
		<!-- OPENVPN-END -->

		<div class="box"><div class="heading">"Shibby" features</div>
			<div class="content">
				<!-- BBT-BEGIN -->
				- Transmission 2.81 integration<br>
				<!-- BBT-END -->
				<!-- BT-BEGIN -->
				- GUI for Transmission<br>
				<!-- BT-END -->
				<!-- NFS-BEGIN -->
				- NFS utils integration and GUI<br>
				<!-- NFS-END -->
				- Custom log file path<br>
				<!-- LINUX26-BEGIN -->
				- SD-idle tool integration for kernel 2.6<br>
				<!-- USB-BEGIN -->
				- 3G Modem support (big thanks for @LDevil)<br>
				<!-- USB-END -->
				<!-- LINUX26-END -->
				<!-- SNMP-BEGIN -->
				- SNMP integration and GUI<br>
				<!-- SNMP-END -->
				<!-- UPS-BEGIN -->
				- APCUPSD integration and GUI (implemented by @arrmo)<br>
				<!-- UPS-END -->
				<!-- DNSCRYPT-BEGIN -->
				- DNScrypt-proxy 1.4.0 integration and GUI<br>
				<!-- DNSCRYPT-END -->
				<!-- TOR-BEGIN -->
				- TOR Project integration and GUI<br>
				<!-- TOR-END -->
				- TomatoAnon project integration and GUI<br>
				- TomatoThemeBase project integration and GUI<br>
				- Ethernet Ports State<br>
				- Extended MOTD (written by @Monter, modified by @Shibby)<br>
				- Webmon Backup Script<br>
				Copyright (C) 2011-2013 Michał Rupental<br>
				<a href='http://openlinksys.info' target='_new'>http://openlinksys.info</a><br>
			</div>
		</div>

		<!-- VPN-BEGIN -->
		<div class="box"><div class="heading">"JYAvenard" features</div>
			<div class="content">
				<!-- OPENVPN-BEGIN -->
				- OpenVPN enhancements &amp; username/password only authentication<br>
				<!-- OPENVPN-END -->
				<!-- PPTPD-BEGIN -->
				- PPTP VPN Client integration and GUI<br>
				<!-- PPTPD-END -->
				Copyright (C) 2010-2012 Jean-Yves Avenard<br>
				<a href='mailto:jean-yves@avenard.org'>jean-yves@avenard.org</a><br>
			</div>
		</div>
		<!-- VPN-END -->

		<div class="box"><div class="heading">"Victek" features</div>
			<div class="content">
				- Extended Sysinfo<br>
				<!-- NOCAT-BEGIN -->
				- Captive Portal. (Based in NocatSplash)<br>
				<!-- NOCAT-END -->
				<!-- NGINX-BEGIN -->
				- Web Server. (NGinX)<br>
				<!-- NGINX-END -->
				<!-- HFS-BEGIN -->
				- HFS / HFS+ filesystem integration<br>
				<!-- HFS-END -->
				Copyright (C) 2007-2011 Ofer Chen & Vicente Soriano<br>
				<a href='http://victek.is-a-geek.com' target='_new'>http://victek.is-a-geek.com</a><br>
			</div>
		</div>

		<div class="box"><div class="heading">"Teaman" features</div>
			<div class="content">
				- QOS-detailed & ctrate filters<br>
				- Realtime bandwidth monitoring of LAN clients<br>
				- Static ARP binding<br>
				- VLAN administration GUI<br>
				- Multiple LAN support integration and GUI<br>
				- Multiple/virtual SSID support (experimental)<br>
				- UDPxy integration and GUI<br>
				<!-- PPTPD-BEGIN -->
				- PPTP Server integration and GUI<br>
				<!-- PPTPD-END -->
				Copyright (C) 2011 Augusto Bott<br>
				<a href='http://code.google.com/p/tomato-sdhc-vlan/' target='_new'>Tomato-sdhc-vlan Homepage</a><br>
			</div>
		</div>

		<div class="box"><div class="heading">"Lancethepants" features</div>
			<div class="content">
				<!-- DNSSEC-BEGIN -->
				- DNSSEC integration and GUI<br>
				<!-- DNSSEC-END -->
				<!-- DNSCRYPT-BEGIN -->
				- DNSCrypt-Proxy selectable/manual resolver<br>
				<!-- DNSCRYPT-END -->
				- Comcast DSCP Fix GUI<br>
				Copyright (C) 2014 Lance Fredrickson<br>
				<a href='mailto:lancethepants@gmail.com'>lancethepants@gmail.com</a><br>
			</div>
		</div>

		<div class="box"><div class="heading">"Toastman" features</div>
			<div class="content">
				- Configurable QOS class names<br>
				- Comprehensive QOS rule examples set by default<br>
				- TC-ATM overhead calculation - patch by tvlz<br>
				- GPT support for HDD by Yaniv Hamo<br>
				- Tools-System refresh timer<br>
				Copyright (C) 2011 Toastman<br>
				<a href='http://www.linksysinfo.org/index.php?threads/using-qos-tutorial-and-discussion.28349/' target='_new'>Using QoS - Tutorial and discussion</a><br>
			</div>
		</div>

		<div class="box"><div class="heading">"Tiomo" features</div>
			<div class="content">
				- IMQ based QOS Ingress<br>
				- Incoming Class Bandwidth pie chart<br>
				Copyright (C) 2012 Tiomo<br>
			</div>
		</div>

		<!-- SDHC-BEGIN -->
		<div class="box"><div class="heading">"Slodki" feature</div>
			<div class="content">
				- SDHC integration and GUI<br>
				Copyright (C) 2009 Tomasz Słodkowicz<br>
				<a href='http://gemini.net.pl/~slodki/tomato-sdhc.html' target='_new'>tomato-sdhc</a><br>
			</div>
		</div>
		<!-- SDHC-END -->

		<div class="box"><div class="heading">"Victek/PrinceAMD/Phykris/Shibby" feature</div>
			<div class="content">
				- Revised IP/MAC Bandwidth Limiter<br>
			</div>
		</div>
	</div>

</content>